﻿using System;
using System.Threading;
using Shared.resources;
using Shared;
using System.Collections.Concurrent;
using GameServer.networking;
using System.Threading.Tasks;
using System.Linq;
using GameServer.logic;
using NLog;
using GameServer.realm.commands;
using GameServer.realm.entities.vendors;
using GameServer.realm.setpieces;
using GameServer.realm.worlds;
using GameServer.realm.worlds.logic;

namespace GameServer.realm
{
    public struct RealmTime
    {
        public long TickCount;
        public long TotalElapsedMs;
        public int TickDelta;
        public int ElapsedMsDelta;
    }

    public enum PendingPriority
    {
        Emergent,
        Destruction,
        Normal,
        Creation,
    }

    public class RealmManager
    {
        private static readonly Logger Log = LogUtil.GetLogger(typeof(RealmManager));

        private readonly bool _initialized;
        public string InstanceId { get; private set; }
        public bool Terminating { get; private set; }

        public Resources Resources { get; private set; }
        public Database Database { get; private set; }
        public ServerConfig Config { get; private set; }
        public int TPS { get; private set; }

        public ConnectManager ConMan { get; private set; }
        public BehaviorDb Behaviors { get; private set; }
        public ISManager InterServer { get; private set; }
        public ISControl ISControl { get; private set; }
        public ChatManager Chat { get; private set; }
        public CommandManager Commands { get; private set; }
        public PortalMonitor Monitor { get; private set; }
        public DbEvents DbEvents { get; private set; }

        private Thread _network;
        private Thread _logic;
        public NetworkTicker Network { get; private set; }
        public FLLogicTicker Logic { get; private set; }

        public readonly ConcurrentDictionary<int, World> Worlds = new();

        public readonly ConcurrentDictionary<Client, PlayerInfo> Clients =
            new();

        private int _nextWorldId = 0;
        private int _nextClientId = 0;

        public RealmManager(Resources resources, Database db, ServerConfig config)
        {
            Log.Info("Initializing Realm Manager...");

            InstanceId = Guid.NewGuid().ToString();
            Database = db;
            Resources = resources;
            Config = config;
            Config.serverInfo.instanceId = InstanceId;
            TPS = config.serverSettings.tps;

            // all these deal with db pub/sub... probably should put more thought into their structure... 
            InterServer = new ISManager(Database, config);
            ISControl = new ISControl(this);
            Chat = new ChatManager(this);
            DbEvents = new DbEvents(this);

            // basic server necessities
            ConMan = new ConnectManager(this,
                config.serverSettings.maxPlayers,
                config.serverSettings.maxPlayersWithPriority);
            Behaviors = new BehaviorDb(this);
            Commands = new CommandManager(this);

            var serverMode = config.serverSettings.mode;
            switch (serverMode)
            {
                case ServerMode.Double:
                case ServerMode.Single:
                case ServerMode.Nexus:
                case ServerMode.Realm:
                    InitializeGlobalWorlds();
                    AddWorld("Realm", true);
                    break;
            }

            // add portal monitor to nexus and initialize worlds
            if (Worlds.ContainsKey(World.Realm))
                Monitor = new PortalMonitor(this, Worlds[World.Realm]);
            foreach (var world in Worlds.Values)
                OnWorldAdded(world);

            _initialized = true;

            Log.Info("Realm Manager initialized.");
        }

        private void InitializeGlobalWorlds()
        {
            // load world data
            foreach (var wData in Resources.Worlds.Data.Values)
                if (wData.id < 0)
                    AddWorld(wData);
        }

        public void Run()
        {
            Log.Info("Starting Realm Manager...");

            // start server logic management
            Logic = new FLLogicTicker(this);
            var logic = new Task(() => Logic.TickLoop(), TaskCreationOptions.LongRunning);
            logic.ContinueWith(Program.Stop, TaskContinuationOptions.OnlyOnFaulted);
            logic.Start();

            // start received packet processor
            Network = new NetworkTicker(this);
            var network = new Task(() => Network.TickLoop(), TaskCreationOptions.LongRunning);
            network.ContinueWith(Program.Stop, TaskContinuationOptions.OnlyOnFaulted);
            network.Start();

            Log.Info("Realm Manager started.");
        }

        public void Stop()
        {
            Log.Info("Stopping Realm Manager...");

            Terminating = true;
            InterServer.Dispose();
            Resources.Dispose();
            Network.Shutdown();

            Log.Info("Realm Manager stopped.");
        }

        public bool TryConnect(Client client)
        {
            if (client?.Account == null)
                return false;

            if (Clients.Keys.Contains(client))
                Disconnect(client);

            client.Id = Interlocked.Increment(ref _nextClientId);
            var plrInfo = new PlayerInfo()
            {
                AccountId = client.Account.AccountId,
                GuildId = client.Account.GuildId,
                Name = client.Account.Name,
                WorldInstance = -1
            };
            Clients[client] = plrInfo;

            // recalculate usage statistics
            Config.serverInfo.players = ConMan.GetPlayerCount();
            Config.serverInfo.maxPlayers = Config.serverSettings.maxPlayers;
            Config.serverInfo.queueLength = ConMan.QueueLength();
            Config.serverInfo.playerList.Add(plrInfo);
            return true;
        }

        public void Disconnect(Client client)
        {
            var player = client.Player;
            player?.Owner?.LeaveWorld(player);

            PlayerInfo plrInfo;
            Clients.TryRemove(client, out plrInfo);

            // recalculate usage statistics
            Config.serverInfo.players = ConMan.GetPlayerCount();
            Config.serverInfo.maxPlayers = Config.serverSettings.maxPlayers;
            Config.serverInfo.queueLength = ConMan.QueueLength();
            Config.serverInfo.playerList.Remove(plrInfo);
        }

        private void AddWorld(string name, bool actAsHub = false)
        {
            AddWorld(Resources.Worlds.Data[name], actAsHub);
        }

        private void AddWorld(ProtoWorld proto, bool actAsHub = false)
        {
            int id;
            if (actAsHub)
            {
                id = World.Realm;
            }
            else
            {
                id = (proto.id < 0)
                    ? proto.id
                    : Interlocked.Increment(ref _nextWorldId);
            }

            World world;
            DynamicWorld.TryGetWorld(proto, null, out world);
            if (world != null)
            {
                if (world is Marketplace && !Config.serverSettings.enableMarket)
                    return;

                AddWorld(id, world);
                return;
            }

            AddWorld(id, new World(proto));
        }

        private void AddWorld(int id, World world)
        {
            if (world.Manager != null)
                throw new InvalidOperationException("World already added.");
            world.Id = id;
            Worlds[id] = world;
            if (_initialized)
                OnWorldAdded(world);
        }

        public World AddWorld(World world)
        {
            if (world.Manager != null)
                throw new InvalidOperationException("World already added.");
            world.Id = Interlocked.Increment(ref _nextWorldId);
            Worlds[world.Id] = world;
            if (_initialized)
                OnWorldAdded(world);
            return world;
        }

        public World GetWorld(int id)
        {
            World ret;
            if (!Worlds.TryGetValue(id, out ret)) return null;
            if (ret.Id == 0) return null;
            return ret;
        }

        public bool RemoveWorld(World world)
        {
            if (world.Manager == null)
                throw new InvalidOperationException("World is not added.");
            if (Worlds.TryRemove(world.Id, out world))
            {
                OnWorldRemoved(world);
                return true;
            }
            else
                return false;
        }

        void OnWorldAdded(World world)
        {
            world.Manager = this;
            if (world.Proto.overseer != null)
            {
                world.Overseer = new Overseer(world, world.Proto.overseer);
                world.Overseer.Init();
            }

            if (world.Proto.spawnSetpieces != null)
            {
                SetPieces.ApplySetPieces(world, world.Proto.spawnSetpieces);
            }
            
            Log.Info("World {0}({1}) added. {2} Worlds existing.", world.Id, world.Name, Worlds.Count);
        }

        void OnWorldRemoved(World world)
        {
            //world.Manager = null;
            Monitor.RemovePortal(world.Id);
            Log.Info("World {0}({1}) removed.", world.Id, world.Name);
        }

        public World GetGameWorld(Client client)
        {
            return Worlds[World.Realm];
        }
    }
}