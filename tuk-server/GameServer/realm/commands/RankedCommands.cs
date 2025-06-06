﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime;
using System.Text;
using System.Text.RegularExpressions;
using Shared;
using Shared.resources;
using Shared.terrain;
using DungeonGen;
using NLog;
using Newtonsoft.Json;
using GameServer.logic;
using GameServer.networking.packets.outgoing;
using GameServer.realm.setpieces;
using GameServer.realm.entities;
using GameServer.realm.worlds;
using GameServer.realm.worlds.logic;

namespace GameServer.realm.commands
{
    class SpawnCommand : Command
    {
        static readonly Logger log = LogUtil.GetLogger(typeof(SpawnCommand));

        private struct JsonSpawn
        {
            public string notif;
            public SpawnProperties[] spawns;
        }

        private struct SpawnProperties
        {
            public string name;
            public int? hp;
            public int? size;
            public int? count;
            public int[] x;
            public int[] y;
            public bool? target;
        }

        private const int Delay = 3; // in seconds

        public SpawnCommand() : base("spawn", 90, true, "s", "devspawn", "ds")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            args = args.Trim();
            return args.StartsWith("{") ? SpawnJson(player, args) : SpawnBasic(player, args);
        }

        private bool SpawnJson(Player player, string json)
        {
            var gameData = player.Manager.Resources.GameData;

            JsonSpawn props;
            try
            {
                props = JsonConvert.DeserializeObject<JsonSpawn>(json);
            }
            catch (Exception)
            {
                player.SendError("JSON not formatted correctly!");
                return false;
            }

            if (props.spawns != null)
                foreach (var spawn in props.spawns)
                {
                    if (spawn.name == null)
                    {
                        player.SendError("No mob specified. Every entry needs a name property.");
                        return false;
                    }

                    var objType = GetSpawnObjectType(gameData, spawn.name);
                    if (objType == null)
                    {
                        player.SendError("Unknown entity!");
                        return false;
                    }

                    var desc = gameData.ObjectDescs[objType.Value];

                    if (player.Client.Account.Rank < 100 &&
                        desc.ObjectId.Contains("Fountain"))
                    {
                        player.SendError("Insufficient rank.");
                        return false;
                    }

                    var hp = desc.MaxHP;
                    if (spawn.hp > hp && spawn.hp < int.MaxValue)
                        hp = spawn.hp.Value;

                    var size = desc.MinSize;
                    if (spawn.size >= 25 && spawn.size <= 500)
                        size = spawn.size.Value;

                    var count = 1;
                    if (spawn.count > count && spawn.count <= 500)
                        count = spawn.count.Value;

                    int[] x = null;
                    int[] y = null;

                    if (spawn.x != null)
                        x = new int[spawn.x.Length];

                    if (spawn.y != null)
                        y = new int[spawn.y.Length];

                    if (x != null)
                    {
                        for (int i = 0; i < x.Length && i < count; i++)
                        {
                            if (spawn.x[i] > 0 && spawn.x[i] <= player.Owner.Map.Width)
                            {
                                x[i] = spawn.x[i];
                            }
                        }
                    }

                    if (y != null)
                    {
                        for (int i = 0; i < y.Length && i < count; i++)
                        {
                            if (spawn.y[i] > 0 && spawn.y[i] <= player.Owner.Map.Height)
                            {
                                y[i] = spawn.y[i];
                            }
                        }
                    }

                    bool target = false;
                    if (spawn.target != null)
                        target = spawn.target.Value;

                    QueueSpawnEvent(player, count, objType.Value, hp, size, x, y, target);
                }

            if (props.notif != null)
            {
                NotifySpawn(player, props.notif);
            }


            return true;
        }

        private bool SpawnBasic(Player player, string args)
        {
            var gameData = player.Manager.Resources.GameData;

            // split argument
            var index = args.IndexOf(' ');
            int num;
            var name = args;
            if (args.IndexOf(' ') > 0 && int.TryParse(args.Substring(0, args.IndexOf(' ')), out num)) //multi
                name = args.Substring(index + 1);
            else
                num = 1;

            var objType = GetSpawnObjectType(gameData, name);
            if (objType == null)
            {
                player.SendError("Unknown entity!");
                return false;
            }

            if (num <= 0)
            {
                player.SendInfo($"Really? {num} {name}? I'll get right on that...");
                return false;
            }

            var id = player.Manager.Resources.GameData.ObjectTypeToId[objType.Value];
            if (player.Client.Account.Rank < 100 &&
                id.Contains("Fountain"))
            {
                player.SendError("Insufficient rank.");
                return false;
            }

            NotifySpawn(player, id, num);
            QueueSpawnEvent(player, num, objType.Value);
            return true;
        }

        private ushort? GetSpawnObjectType(XmlData gameData, string name)
        {
            ushort objType;
            if (!gameData.IdToObjectType.TryGetValue(name, out objType) ||
                !gameData.ObjectDescs.ContainsKey(objType))
            {
                // no match found, try to get partial match
                var mobs = gameData.IdToObjectType
                    .Where(m => m.Key.ContainsIgnoreCase(name) && gameData.ObjectDescs.ContainsKey(m.Value))
                    .Select(m => gameData.ObjectDescs[m.Value]);

                if (!mobs.Any())
                    return null;

                var maxHp = mobs.Max(e => e.MaxHP);
                objType = mobs.First(e => e.MaxHP == maxHp).ObjectType;
            }

            return objType;
        }

        private void NotifySpawn(Player player, string mob, int? num = null)
        {
            var w = player.Owner;

            var notif = mob;
            if (num != null)
                notif = $"{(CommandTag == "ds" || CommandTag == "devspawn" ? "Devs" : "S")}pawning " + ((num > 1) ? num + " " : "") + mob + "...";

            w.BroadcastPacket(new Notification
            {
                Color = new ARGB(0xffff0000),
                ObjectId = (player.IsControlling) ? player.SpectateTarget.Id : player.Id,
                Message = notif
            }, null);

            if (player.IsControlling)
                w.BroadcastPacket(new Text
                {
                    Name = $"#{player.SpectateTarget.ObjectDesc.DisplayId}",
                    NumStars = -1,
                    BubbleTime = 0,
                    Txt = notif
                }, null);
            else
                w.BroadcastPacket(new Text
                {
                    Name = $"#{player.Name}",
                    NumStars = player.Stars,
                    Admin = player.Admin,
                    BubbleTime = 0,
                    Txt = notif
                }, null);
        }

        private void QueueSpawnEvent(
            Player player,
            int num,
            ushort mobObjectType, int? hp = null, int? size = null,
            int[] x = null, int[] y = null,
            bool? target = false)
        {
            var pX = player.X;
            var pY = player.Y;

            player.Owner.Timers.Add(new WorldTimer(Delay * 1000, (world, t) => // spawn mob in delay seconds
            {
                for (var i = 0; i < num && i < 500; i++)
                {
                    Entity entity;
                    try
                    {
                        entity = Entity.Resolve(world.Manager, mobObjectType);
                    }
                    catch (Exception e)
                    {
                        log.Error(e.ToString());
                        return;
                    }

                    entity.Spawned = CommandTag == "s" || CommandTag == "spawn";
                    entity.DevSpawned = !entity.Spawned;

                    var enemy = entity as Enemy;
                    if (enemy != null)
                    {
                        if (hp != null)
                        {
                            enemy.HP = hp.Value;
                            enemy.MaximumHP = enemy.HP;
                        }

                        if (size != null)
                            enemy.SetDefaultSize(size.Value);

                        if (target == true)
                            enemy.AttackTarget = player;

                        if (!entity.DevSpawned)
                            enemy.ApplyConditionEffect(new ConditionEffect()
                            {
                                Effect = ConditionEffectIndex.Invisible,
                                DurationMS = -1
                            });
                    }

                    var sX = (x != null && i < x.Length) ? x[i] : pX;
                    var sY = (y != null && i < y.Length) ? y[i] : pY;

                    entity.Move(sX, sY);

                    if (!world.Deleted)
                        world.EnterWorld(entity);
                }
            }));
        }
    }

    class ClearSpawnsCommand : Command
    {
        public ClearSpawnsCommand() : base("clearspawn", permLevel: 90, true, "cs", "cleardevspawn", "cds")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var iterations = 0;
            var lastKilled = -1;
            var removed = 0;
            var devSpawned = CommandTag == "cleardevspawn" || CommandTag == "cds";
            while (removed != lastKilled)
            {
                lastKilled = removed;
                foreach (var entity in player.Owner.Enemies.Values.Where(e => devSpawned ? e.DevSpawned : e.Spawned).ToList())
                {
                    entity.Death(time);
                    removed++;
                }

                foreach (var entity in player.Owner.StaticObjects.Values.Where(e => devSpawned ? e.DevSpawned : e.Spawned).ToList())
                {
                    player.Owner.LeaveWorld(entity);
                    removed++;
                }

                if (++iterations >= 5)
                    break;
            }

            player.SendInfo($"{removed} {(devSpawned ? "dev " : "")}spawned entities removed!");
            return true;
        }
    }

    class ClearGravesCommand : Command
    {
        public ClearGravesCommand() : base("cleargraves", permLevel: 80, aliases: "cgraves")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var removed = 0;
            foreach (var entity in player.Owner.StaticObjects.Values)
            {
                if (entity is Container || entity.ObjectDesc == null)
                    continue;

                if (entity.ObjectDesc.ObjectId.StartsWith("Gravestone") && entity.Dist(player) < 15)
                {
                    player.Owner.LeaveWorld(entity);
                    removed++;
                }
            }

            player.SendInfo($"{removed} gravestones removed!");
            return true;
        }
    }

    class ToggleEffCommand : Command
    {
        public ToggleEffCommand() : base("eff", permLevel: 90)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            ConditionEffectIndex effect;
            if (!Enum.TryParse(args, true, out effect))
            {
                player.SendError("Invalid effect!");
                return false;
            }

            var target = player.IsControlling ? player.SpectateTarget : player;
            if ((target.ConditionEffects & (ConditionEffects)((ulong)1 << (int)effect)) != 0)
            {
                //remove
                target.ApplyConditionEffect(new ConditionEffect()
                {
                    Effect = effect,
                    DurationMS = 0
                });
            }
            else
            {
                //add
                target.ApplyConditionEffect(new ConditionEffect()
                {
                    Effect = effect,
                    DurationMS = -1
                });
            }

            return true;
        }
    }

    class GuildRankCommand : Command
    {
        public GuildRankCommand() : base("grank", permLevel: 95)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player == null)
                return false;

            // verify argument
            var index = args.IndexOf(' ');
            if (string.IsNullOrWhiteSpace(args) || index == -1)
            {
                player.SendInfo("Usage: /grank <player name> <guild rank>");
                return false;
            }

            // get command args
            var playerName = args.Substring(0, index);
            var rank = args.Substring(index + 1).IsInt()
                ? args.Substring(index + 1).ToInt32()
                : RankNumberFromName(args.Substring(index + 1));
            if (rank == -1)
            {
                player.SendError("Unknown rank!");
                return false;
            }
            else if (rank % 10 != 0)
            {
                player.SendError("Valid ranks are multiples of 10!");
                return false;
            }

            // get player account
            if (Database.GuestNames.Contains(playerName))
            {
                player.SendError("Cannot rank the unnamed...");
                return false;
            }

            var id = player.Manager.Database.ResolveId(playerName);
            var acc = player.Manager.Database.GetAccount(id);
            if (id == 0 || acc == null)
            {
                player.SendError("Account not found!");
                return false;
            }

            // change rank
            acc.GuildRank = rank;
            acc.FlushAsync();

            // send out success notifications
            player.SendInfo($"You changed the guildrank of player {acc.Name} to {rank}.");
            var target = player.Manager.Clients.Keys.SingleOrDefault(p => p.Account.AccountId == acc.AccountId);
            if (target?.Player == null) return true;
            target.Player.GuildRank = rank;
            target.Player.SendInfo("Your guild rank was changed");
            return true;
        }

        private int RankNumberFromName(string val)
        {
            switch (val.ToLower())
            {
                case "initiate":
                    return 0;
                case "member":
                    return 10;
                case "officer":
                    return 20;
                case "leader":
                    return 30;
                case "founder":
                    return 40;
            }

            return -1;
        }
    }

    class GimmeCommand : Command
    {
        public GimmeCommand() : base("gimme", permLevel: 80, aliases: "give")
        {
        }

        private string[] BannedItems =
        {
            "Boshy Gun",
            "Boshy Shotgun",
            "Oryx's Arena Key",
        };

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var gameData = player.Manager.Resources.GameData;

            ushort objType;

            // allow both DisplayId and Id for query, prioritize Id
            if (!gameData.IdToObjectType.TryGetValue(args, out objType))
            {
                if (!gameData.DisplayIdToObjectType.TryGetValue(args, out objType))
                {
                    player.SendError("Unknown item type!");
                    return false;
                }
            }

            if (!gameData.Items.ContainsKey(objType))
            {
                player.SendError("Not an item!");
                return false;
            }

            var item = gameData.Items[objType];
            if (player.Client.Account.Rank < 100 && BannedItems.Contains(item.ObjectId))
            {
                player.SendError("Insufficient rank to give yourself this item.");
                return false;
            }

            var inventory = player.Inventory;
            var slot = inventory.GetAvailableInventorySlot(item);
            if (slot != -1)
            {
                inventory[slot] = ItemData.GenerateData(item);
                inventory[slot].Soulbound = true;
                if (item.SlotType != 10 && item.SlotType != 26)
                {
                    inventory[slot].Quality = 1;
                    inventory[slot].Runes = new ushort[4];
                }

                player.ForceUpdate(slot);
                return true;
            }

            player.SendError("Not enough space in inventory!");
            return false;
        }
    }

    class TpPosCommand : Command
    {
        public TpPosCommand() : base("tpPos", permLevel: 90, aliases: "goto")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            string[] coordinates = args.Split(' ');
            if (coordinates.Length != 2)
            {
                player.SendError("Invalid coordinates!");
                return false;
            }

            int x, y;
            if (!int.TryParse(coordinates[0], out x) ||
                !int.TryParse(coordinates[1], out y))
            {
                player.SendError("Invalid coordinates!");
                return false;
            }

            player.SetNewbiePeriod();
            player.TeleportPosition(time, x + 0.5f, y + 0.5f, true);
            return true;
        }
    }

    class TpRelativePosCommand : Command
    {
        public TpRelativePosCommand() : base("move", permLevel: 90)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            string[] coordinates = args.Split(' ');
            if (coordinates.Length != 2)
            {
                player.SendError("Invalid coordinates!");
                return false;
            }

            int x, y;
            if (!int.TryParse(coordinates[0], out x) ||
                !int.TryParse(coordinates[1], out y))
            {
                player.SendError("Invalid coordinates!");
                return false;
            }

            player.SetNewbiePeriod();
            player.TeleportPosition(time, player.X + x, player.Y + y, true);
            return true;
        }
    }

    class SetpieceCommand : Command
    {
        public SetpieceCommand() : base("setpiece", permLevel: 90)
        {
        }

        protected override bool Process(Player player, RealmTime time, string setPiece)
        {
            var worldData = player.Manager.Resources.Worlds;
            if (string.IsNullOrWhiteSpace(setPiece) || !worldData.Setpieces.Contains(setPiece))
            {
                player.SendInfo($"Valid setpieces: {string.Join(", ", worldData.Setpieces)}.");
                return false;
            }

            if (!player.Owner.Name.Equals("Realm"))
            {
                SetPieces.RenderFromProto(player.Owner, new IntPoint((int)player.X + 1, (int)player.Y + 1), worldData[setPiece]);
                return true;
            }
            else
            {
                player.SendInfo("/setpiece not allowed in Realm.");
                return false;
            }
        }
    }

    class DebugCommand : Command
    {
        class Locater : Enemy
        {
            Player player;

            public Locater(Player player)
                : base(player.Manager, 0x0d5d)
            {
                this.player = player;
                Move(player.X, player.Y);
                ApplyConditionEffect(new ConditionEffect()
                {
                    Effect = ConditionEffectIndex.Invincible,
                    DurationMS = -1
                });
            }

            public override void Tick(RealmTime time)
            {
                Move(player.X, player.Y);
                base.Tick(time);
            }
        }

        public DebugCommand() : base("debug", permLevel: 90, listCommand: false)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var debugything = new Locater(player) { Spawned = true };
            player.Owner.EnterWorld(debugything);
            return true;
        }
    }

    class KillAllCommand : Command
    {
        public KillAllCommand() : base("killAll", permLevel: 90, aliases: "ka")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var iterations = 0;
            var lastKilled = -1;
            var killed = 0;
            while (killed != lastKilled)
            {
                lastKilled = killed;
                foreach (var i in player.Owner.Enemies.Values.Where(e =>
                    e.ObjectDesc != null && e.ObjectDesc.ObjectId != null
                                         && e.ObjectDesc.Enemy && e.ObjectDesc.ObjectId != "Tradabad Nexus Crier"
                                         && e.ObjectDesc.ObjectId.ContainsIgnoreCase(args)))
                {
                    i.Spawned = true;
                    i.Death(time);
                    killed++;
                }

                if (++iterations >= 5)
                    break;
            }

            player.SendInfo($"{killed} enemy killed!");
            return true;
        }
    }

    class KickCommand : Command
    {
        public KickCommand() : base("kick", permLevel: 80)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            foreach (var i in player.Manager.Clients.Keys)
            {
                if (i.Account.Name.EqualsIgnoreCase(args))
                {
                    // probably if someone is hidden doesn't want to be kicked, so we leave it as before
                    if (i.Account.Hidden)
                        break;

                    i.Disconnect();
                    player.SendInfo("Player disconnected!");
                    return true;
                }
            }

            player.SendError($"Player '{args}' could not be found!");
            return false;
        }
    }

    class GetQuestCommand : Command
    {
        public GetQuestCommand() : base("getQuest", permLevel: 90)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player.Quest == null)
            {
                player.SendError("Player does not have a quest!");
                return false;
            }

            player.SendInfo("Quest location: (" + player.Quest.X + ", " + player.Quest.Y + ")");
            return true;
        }
    }

    class OryxSayCommand : Command
    {
        public OryxSayCommand() : base("oryxSay", permLevel: 80, aliases: "osay")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Manager.Chat.Oryx(player.Owner, args);
            return true;
        }
    }

    class AnnounceCommand : Command
    {
        public AnnounceCommand() : base("announce", permLevel: 80)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Manager.Chat.Announce(args);
            return true;
        }
    }

    class SummonCommand : Command
    {
        public SummonCommand() : base("summon", permLevel: 90)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            foreach (var i in player.Owner.Players)
            {
                if (i.Value.Name.EqualsIgnoreCase(args))
                {
                    // probably someone hidden doesn't want to be summoned, so we leave it as before here
                    if (i.Value.HasConditionEffect(ConditionEffects.Hidden))
                        break;

                    i.Value.Teleport(time, player.Id, true);
                    i.Value.SendInfo($"You've been summoned by {player.Name}.");
                    player.SendInfo("Player summoned!");
                    return true;
                }
            }

            player.SendError($"Player '{args}' could not be found!");
            return false;
        }
    }

    class SummonAllCommand : Command
    {
        public SummonAllCommand() : base("summonall", permLevel: 90)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            foreach (var i in player.Owner.Players)
            {
                // probably someone hidden doesn't want to be summoned, so we leave it as before here
                if (i.Value.HasConditionEffect(ConditionEffects.Hidden))
                    break;

                i.Value.Teleport(time, player.Id, true);
                i.Value.SendInfo($"You've been summoned by {player.Name}.");
            }

            player.SendInfo("All players summoned!");
            return true;
        }
    }

    class KillPlayerCommand : Command
    {
        public KillPlayerCommand() : base("killPlayer", permLevel: 100)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            foreach (var i in player.Manager.Clients.Keys)
            {
                if (i.Account.Name.EqualsIgnoreCase(args))
                {
                    i.Player.HP = 0;
                    i.Player.Death(player.Name);
                    player.SendInfo("Player killed!");
                    return true;
                }
            }

            player.SendError($"Player '{args}' could not be found!");
            return false;
        }
    }

    class SizeCommand : Command
    {
        public SizeCommand() : base("size", permLevel: 20)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (string.IsNullOrEmpty(args))
            {
                player.SendError(
                    "Usage: /size <positive integer>. Using 0 will restore the default size for the sprite.");
                return false;
            }

            var size = Utils.FromString(args);
            var min = player.Rank < 80 ? 75 : 0;
            var max = player.Rank < 80 ? 125 : 500;
            if (size < min && size != 0 || size > max)
            {
                player.SendError(
                    $"Invalid size. Size needs to be within the range: {min}-{max}. Use 0 to reset size to default.");
                return false;
            }

            var acc = player.Client.Account;
            acc.Size = size;
            acc.FlushAsync();

            var target = player.IsControlling ? player.SpectateTarget : player;
            if (size == 0)
                target.RestoreDefaultSize();
            else
                target.Size = size;

            return true;
        }
    }

    class RebootCommand : Command
    {
        // Command actually closes the program.
        // An external program is used to monitor the world server existance.
        // If !exist it automatically restarts it.

        public RebootCommand() : base("reboot", permLevel: 80)
        {
        }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            var manager = player.Manager;
            var servers = manager.InterServer.GetServerList();

            // display help if no argument supplied
            if (string.IsNullOrEmpty(name))
            {
                var sb = new StringBuilder("Current servers available for rebooting:\n");
                for (var i = 0; i < servers.Length; i++)
                {
                    if (i != 0)
                        sb.Append(", ");

                    sb.Append($"{servers[i].name} [{servers[i].type}]");
                }

                player.SendInfo("Usage: /reboot < server name | $all | $wserver | $account >");
                player.SendInfo(sb.ToString());
                return true;
            }

            // attempt to find server match
            foreach (var server in servers)
            {
                if (!server.name.Equals(name, StringComparison.InvariantCultureIgnoreCase))
                    continue;

                RebootServer(player, 0, server.instanceId);
                player.SendInfo("Reboot command sent.");
                return true;
            }

            // no match found, attempt to match special cases
            switch (name.ToLower())
            {
                case "$all":
                    RebootServer(player, 29000, servers
                        .Select(s => s.instanceId)
                        .ToArray());
                    player.SendInfo("Reboot command sent.");
                    return true;
                case "$wserver":
                    RebootServer(player, 0, servers
                        .Where(s => s.type == ServerType.World)
                        .Select(s => s.instanceId)
                        .ToArray());
                    player.SendInfo("Reboot command sent.");
                    return true;
                case "$account":
                    RebootServer(player, 0, servers
                        .Where(s => s.type == ServerType.Account)
                        .Select(s => s.instanceId)
                        .ToArray());
                    player.SendInfo("Reboot command sent.");
                    return true;
            }

            player.SendInfo("Server not found.");
            return false;
        }

        private void RebootServer(Player issuer, int delay, params string[] instanceIds)
        {
            foreach (var instanceId in instanceIds)
            {
                issuer.Manager.InterServer.Publish(Channel.Control, new ControlMsg()
                {
                    Type = ControlType.Reboot,
                    TargetInst = instanceId,
                    Issuer = issuer.Name,
                    Delay = delay
                });
            }
        }
    }

    class ReSkinCommand : Command
    {
        public ReSkinCommand() : base("reskin", permLevel: 70)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var skins = player.Manager.Resources.GameData.Skins
                .Where(d => d.Value.PlayerClassType == player.ObjectType)
                .Select(d => d.Key)
                .ToArray();

            if (String.IsNullOrEmpty(args))
            {
                var choices = skins.ToCommaSepString();
                player.SendError("Usage: /reskin <positive integer>");
                player.SendError("Choices: " + choices);
                return false;
            }

            var skin = (ushort)Utils.FromString(args);

            if (skin != 0 && !skins.Contains(skin))
            {
                player.SendError(
                    "Error setting skin. Either the skin type doesn't exist or the skin is for another class.");
                return false;
            }

            var skinDesc = player.Manager.Resources.GameData.Skins[skin];
            var playerExclusive = skinDesc.PlayerExclusive;
            var size = skinDesc.Size;
            if (playerExclusive != null && !player.Name.Equals(playerExclusive) && player.Rank < 100)
            {
                skin = 0;
                size = 100;
            }

            player.SetDefaultSkin(skin);
            player.PrevSkin = skin;
            player.SetDefaultSize(size);
            player.PrevSize = size;
            return true;
        }
    }

    class MaxCommand : Command
    {
        public MaxCommand() : base("max", permLevel: 80)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var pd = player.Manager.Resources.GameData.Classes[player.ObjectType];

            player.Stats.Base[0] = pd.Stats[0].MaxValue;
            player.Stats.Base[1] = pd.Stats[1].MaxValue;
            player.Stats.Base[2] = pd.Stats[2].MaxValue;
            player.Stats.Base[3] = pd.Stats[3].MaxValue;
            player.Stats.Base[4] = pd.Stats[4].MaxValue;
            player.Stats.Base[5] = pd.Stats[5].MaxValue;
            player.Stats.Base[6] = pd.Stats[6].MaxValue;
            player.Stats.Base[7] = pd.Stats[7].MaxValue;
            player.Stats.Base[19] = pd.Stats[19].MaxValue;
            player.Stats.Base[20] = pd.Stats[20].MaxValue;

            player.SendInfo("Your character stats have been maxed.");
            return true;
        }
    }

    /*class ResetServerFame : Command
    {
        public ResetServerFame() : base("resetFame", permLevel: 100) { }

        // resets leaderboards, account stars, and account fame to 0
        protected override bool Process(Player player, RealmTime time, string args)
        {
            // needed to make sure characters connected have fame reset properly
            foreach (var client in player.Manager.Clients.Values)
            {
                client.Player.Experience = 0;
                client.Player.Fame = 0;
                client.Character.Experience = 0;
                client.Character.Fame = 0;
            }

            Program.Stop();

            player.Manager.Database.ResetFame();
            return true;
        }
    }*/

    /*
    class WipeServer : Command
    {
        public WipeServer() : base("wipeServer", permLevel: 100) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            // close all worlds / disconnect all players
            foreach (var w in player.Manager.Worlds.Values)
            {
                w.Closed = true;
                foreach (var p in w.Players.Values)
                    p.Client.Disconnect();
            }

            player.Manager.Database.Wipe(player.Manager.Resources.GameData);

            Program.Stop();
            return true;
        }
    }
    */

    class TpQuestCommand : Command
    {
        public TpQuestCommand() : base("tq", permLevel: 90)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player.Quest == null)
            {
                player.SendError("Player does not have a quest!");
                return false;
            }

            player.SetNewbiePeriod();
            player.TeleportPosition(time, player.Quest.RealX, player.Quest.RealY, true);
            player.SendInfo("Teleported to Quest Location: (" + player.Quest.X + ", " + player.Quest.Y + ")");
            return true;
        }
    }

    class RankCommand : Command
    {
        public RankCommand() : base("rank", permLevel: 100)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var index = args.IndexOf(' ');
            if (string.IsNullOrEmpty(args) || index == -1)
            {
                player.SendInfo("Usage: /rank <player name> <rank>");
                return false;
            }

            var name = args.Substring(0, index);
            var rank = int.Parse(args.Substring(index + 1));

            if (Database.GuestNames.Contains(name))
            {
                player.SendError("Cannot rank unnamed accounts.");
                return false;
            }

            var id = player.Manager.Database.ResolveId(name);
            if (id == player.AccountId)
            {
                player.SendError("Cannot rank self.");
                return false;
            }

            var acc = player.Manager.Database.GetAccount(id);
            if (id == 0 || acc == null)
            {
                player.SendError("Account not found!");
                return false;
            }

            // kick player from server to set rank
            foreach (var i in player.Manager.Clients.Keys)
                if (i.Account.Name.EqualsIgnoreCase(name))
                    i.Disconnect();

            if (acc.Admin && rank < 80)
            {
                // reset account
                player.Manager.Database.WipeAccount(
                    acc, player.Manager.Resources.GameData, player.Name);
                acc.Reload();
            }

            acc.Admin = rank >= 80;
            acc.LegacyRank = rank;
            acc.Hidden = false;
            acc.FlushAsync();

            player.SendInfo(
                $"{acc.Name} given legacy rank {acc.LegacyRank}{((acc.Admin) ? " and now has admin status" : "")}.");
            return true;
        }
    }

    class MuteCommand : Command
    {
        private static readonly Regex CmdParams = new(@"^(\w+)( \d+)?$", RegexOptions.IgnoreCase);

        private readonly RealmManager _manager;

        public MuteCommand(RealmManager manager) : base("mute", permLevel: 80)
        {
            _manager = manager;
            _manager.DbEvents.Expired += HandleUnMute;
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var match = CmdParams.Match(args);
            if (!match.Success)
            {
                player?.SendError("Usage: /mute <player name> <time out in minutes>\\n" +
                                  "Time parameter is optional. If left out player will be muted until unmuted.");
                return false;
            }

            // gather arguments
            var name = match.Groups[1].Value;
            var id = _manager.Database.ResolveId(name);
            var acc = _manager.Database.GetAccount(id);
            int timeout;
            if (string.IsNullOrEmpty(match.Groups[2].Value))
            {
                timeout = -1;
            }
            else
            {
                int.TryParse(match.Groups[2].Value, out timeout);
            }

            // run through checks
            if (id == 0 || acc == null)
            {
                player?.SendError("Account not found!");
                return false;
            }

            if (acc.IP == null)
            {
                player?.SendError(
                    "Account has no associated IP address. Player must login at least once before being muted.");
                return false;
            }

            if (acc.IP.Equals(player?.Client.Account.IP))
            {
                player?.SendError("Mute failed. That action would cause yourself to be muted (IPs are the same).");
                return false;
            }

            if (acc.Admin)
            {
                player?.SendError("Cannot mute other admins.");
                return false;
            }

            // mute player if currently connected
            foreach (var client in _manager.Clients.Keys
                .Where(c => c.Player != null && c.IP.Equals(acc.IP) && !c.Player.Client.Account.Admin))
            {
                client.Player.Muted = true;
                client.Player.ApplyConditionEffect(ConditionEffectIndex.Muted);
            }

            if (player != null)
            {
                if (timeout > 0)
                    _manager.Chat.SendInfo(id,
                        "You have been muted by " + player.Name + " for " + timeout + " minutes.");
                else
                    _manager.Chat.SendInfo(id, "You have been muted by " + player.Name + ".");
            }

            // mute ip address
            if (timeout < 0)
            {
                _manager.Database.Mute(acc.IP);
                player?.SendInfo(name + " successfully muted indefinitely.");
            }
            else
            {
                _manager.Database.Mute(acc.IP, TimeSpan.FromMinutes(timeout));
                player?.SendInfo(name + " successfully muted for " + timeout + " minutes.");
            }

            return true;
        }

        private void HandleUnMute(object entity, DbEventArgs expired)
        {
            var key = expired.Message;

            if (!key.StartsWith("mutes:"))
                return;

            foreach (var client in _manager.Clients.Keys.Where(c =>
                c.Player != null && c.IP.Equals(key.Substring(6)) && !c.Player.Client.Account.Admin))
            {
                client.Player.Muted = false;
                client.Player.ApplyConditionEffect(ConditionEffectIndex.Muted, 0);
                client.Player.SendInfo("You are no longer muted. Please do not spam. Thank you.");
            }
        }
    }

    class UnMuteCommand : Command
    {
        public UnMuteCommand() : base("unmute", permLevel: 80)
        {
        }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                player.SendError("Usage: /unmute <player name>");
                return false;
            }

            // gather needed info
            var id = player.Manager.Database.ResolveId(name);
            var acc = player.Manager.Database.GetAccount(id);

            // run checks
            if (id == 0 || acc == null)
            {
                player.SendError("Account not found!");
                return false;
            }

            if (acc.IP == null)
            {
                player.SendError(
                    "Account has no associated IP address. Player must login at least once before being unmuted.");
                return false;
            }

            // unmute ip address
            player.Manager.Database.IsMuted(acc.IP).ContinueWith(t =>
            {
                if (!t.IsCompleted)
                {
                    player.SendInfo("Db access error while trying to unmute.");
                    return;
                }

                if (t.Result)
                {
                    player.Manager.Database.Mute(acc.IP, TimeSpan.FromSeconds(1));
                    player.SendInfo(name + " successfully unmuted.");
                }
                else
                {
                    player.SendInfo(name + " wasn't muted...");
                }
            });

            // expire event will handle unmuting of connected players
            return true;
        }
    }

    class BanAccountCommand : Command
    {
        public BanAccountCommand() : base("ban", permLevel: 80)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            BanInfo bInfo;
            if (args.StartsWith("{"))
            {
                bInfo = Utils.FromJson<BanInfo>(args);
            }
            else
            {
                bInfo = new BanInfo();

                // validate command
                var rgx = new Regex(@"^(\w+) (.+)$");
                var match = rgx.Match(args);
                if (!match.Success)
                {
                    player.SendError("Usage: /ban <account id or name> <reason>");
                    return false;
                }

                // get info from args
                bInfo.Name = match.Groups[1].Value;
                if (!int.TryParse(bInfo.Name, out bInfo.accountId))
                {
                    bInfo.accountId = player.Manager.Database.ResolveId(bInfo.Name);
                }

                bInfo.banReasons = match.Groups[2].Value;
                bInfo.banLiftTime = -1;
            }

            // run checks
            if (Database.GuestNames.Contains(bInfo.Name))
            {
                player.SendError("If you specify a player name to ban, the name needs to be unique.");
                return false;
            }

            if (bInfo.accountId == 0)
            {
                player.SendError("Account not found...");
                return false;
            }

            if (string.IsNullOrWhiteSpace(bInfo.banReasons))
            {
                player.SendError("A reason must be provided.");
                return false;
            }

            var acc = player.Manager.Database.GetAccount(bInfo.accountId);
            if (player.AccountId != acc.AccountId && player.Rank <= acc.Rank)
            {
                player.SendError("Cannot ban players of equal or higher rank than yourself.");
                return false;
            }

            // ban player + disconnect if currently connected
            player.Manager.Database.Ban(bInfo.accountId, bInfo.banReasons, bInfo.banLiftTime);
            var target = player.Manager.Clients.Keys
                .SingleOrDefault(c => c.Account != null && c.Account.AccountId == bInfo.accountId);
            target?.Disconnect();

            player.SendInfo(
                !string.IsNullOrEmpty(bInfo.Name) ? $"{bInfo.Name} successfully banned." : "Ban successful.");
            return true;
        }

        private class BanInfo
        {
            public int accountId;
            public string Name;
            public string banReasons;
            public int banLiftTime;
        }
    }

    class BanIPCommand : Command
    {
        public BanIPCommand() : base("banip", permLevel: 80, aliases: "ipban")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var manager = player.Manager;
            var db = manager.Database;

            // validate command
            var rgx = new Regex(@"^(\w+) (.+)$");
            var match = rgx.Match(args);
            if (!match.Success)
            {
                player.SendError("Usage: /banip <account id or name> <reason>");
                return false;
            }

            // get info from args
            int id;
            var idstr = match.Groups[1].Value;
            if (!int.TryParse(idstr, out id))
            {
                id = db.ResolveId(idstr);
            }

            var reason = match.Groups[2].Value;

            // run checks
            if (Database.GuestNames.Contains(idstr))
            {
                player.SendError("If you specify a player name to ban, the name needs to be unique.");
                return false;
            }

            if (id == 0)
            {
                player.SendError("Account not found...");
                return false;
            }

            if (string.IsNullOrWhiteSpace(reason))
            {
                player.SendError("A reason must be provided.");
                return false;
            }

            var acc = db.GetAccount(id);
            if (string.IsNullOrEmpty(acc.IP))
            {
                player.SendError("Failed to ip ban player. IP not logged...");
                return false;
            }

            if (player.AccountId != acc.AccountId && acc.IP.Equals(player.Client.Account.IP))
            {
                player.SendError("IP ban failed. That action would cause yourself to be banned (IPs are the same).");
                return false;
            }

            if (player.AccountId != acc.AccountId && player.Rank <= acc.Rank)
            {
                player.SendError("Cannot ban players of equal or higher rank than yourself.");
                return false;
            }

            // ban
            db.Ban(acc.AccountId, reason);
            db.BanIp(acc.IP, reason);

            // disconnect currently connected
            var targets = manager.Clients.Keys.Where(c => c.IP.Equals(acc.IP));
            foreach (var t in targets)
                t.Disconnect();

            // send notification
            player.SendInfo($"Banned {acc.Name} (both account and ip).");
            return true;
        }
    }

    class UnBanAccountCommand : Command
    {
        public UnBanAccountCommand() : base("unban", permLevel: 80)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var db = player.Manager.Database;

            // validate command
            var rgx = new Regex(@"^(\w+)$");
            if (!rgx.IsMatch(args))
            {
                player.SendError("Usage: /unban <account id or name>");
                return false;
            }

            // get info from args
            int id;
            if (!int.TryParse(args, out id))
                id = db.ResolveId(args);

            // run checks
            if (id == 0)
            {
                player.SendError("Account doesn't exist...");
                return false;
            }

            var acc = db.GetAccount(id);

            // unban
            var banned = db.UnBan(id);
            var ipBanned = acc.IP != null && db.UnBanIp(acc.IP);

            // send notification
            if (!banned && !ipBanned)
            {
                player.SendInfo($"{acc.Name} wasn't banned...");
                return true;
            }

            if (banned && ipBanned)
            {
                player.SendInfo($"Success! {acc.Name}'s account and IP no longer banned.");
                return true;
            }

            if (banned)
            {
                player.SendInfo($"Success! {acc.Name}'s account no longer banned.");
                return true;
            }

            player.SendInfo($"Success! {acc.Name}'s IP no longer banned.");
            return true;
        }
    }

    class ClearInvCommand : Command
    {
        public ClearInvCommand() : base("clearinv", permLevel: 80)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            for (int i = 4; i < 12; i++)
                player.Inventory[i] = new ItemData();
            player.SendInfo("Inventory Cleared.");
            return true;
        }
    }

    class MusicCommand : Command
    {
        public MusicCommand() : base("music", permLevel: 70)
        {
        }

        protected override bool Process(Player player, RealmTime time, string music)
        {
            var owner = player.Owner;
            owner.Music = music;

            foreach (var plr in owner.Players.Values)
                plr.SendInfo($"World music changed to {music}.");

            var i = 0;
            foreach (var plr in owner.Players.Values)
            {
                owner.Timers.Add(new WorldTimer(100 * i, (w, t) =>
                {
                    if (plr == null)
                        return;

                    plr.Client.SendPacket(new SwitchMusic()
                    {
                        Music = music
                    });
                }));
                i++;
            }

            return true;
        }
    }

    class QuakeCommand : Command
    {
        public QuakeCommand() : base("quake", permLevel: 80)
        {
        }

        protected override bool Process(Player player, RealmTime time, string worldName)
        {
            var worldProtoData = player.Manager.Resources.Worlds.Data;

            if (String.IsNullOrWhiteSpace(worldName))
            {
                var msg = worldProtoData.Aggregate(
                    "Valid World Names: ", (c, p) => c + ((!p.Value.setpiece) ? (p.Key + ", ") : ""));
                player.SendInfo(msg.Substring(0, msg.Length - 2) + ".");
                return false;
            }

            if (player.Owner is Realm)
            {
                player.SendError("Cannot use /quake in Realm.");
                return false;
            }

            var worldNameProper =
                player.Manager.Resources.Worlds.Data.FirstOrDefault(
                    p => p.Key.Equals(worldName, StringComparison.InvariantCultureIgnoreCase)).Key;

            ProtoWorld proto;
            if (worldNameProper == null || (proto = worldProtoData[worldNameProper]).setpiece)
            {
                player.SendError("Invalid world.");
                return false;
            }

            World world;
            {
                DynamicWorld.TryGetWorld(proto, player.Client, out world);
                world = player.Manager.AddWorld(world ?? new World(proto));
            }

            player.Owner.QuakeToWorld(world);
            return true;
        }
    }

    class VisitCommand : Command
    {
        public VisitCommand() : base("visit", permLevel: 80)
        {
        }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                player.SendInfo("Usage: /visit <player name>");
                return true;
            }

            var target = player.Manager.Clients.Keys
                .SingleOrDefault(c => c.Account != null &&
                                      c.Account.Name.Equals(name, StringComparison.InvariantCultureIgnoreCase));

            if (target?.Player?.Owner == null ||
                !target.Player.CanBeSeenBy(player))
            {
                player.SendError("Player not found!");
                return false;
            }

            var owner = target.Player.Owner;
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                GameId = owner.Id,
                Name = owner.SBName
            });
            return true;
        }
    }

    class HideCommand : Command
    {
        public HideCommand() : base("hide", permLevel: 80, aliases: "h")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var acc = player.Client.Account;

            acc.Hidden = !acc.Hidden;
            acc.FlushAsync();

            if (acc.Hidden)
            {
                player.ApplyConditionEffect(ConditionEffectIndex.Hidden);
                player.ApplyConditionEffect(ConditionEffectIndex.Invincible);
                player.Manager.Clients[player.Client].Hidden = true;
            }
            else
            {
                player.ApplyConditionEffect(ConditionEffectIndex.Hidden, 0);
                player.ApplyConditionEffect(ConditionEffectIndex.Invincible, 0);
                player.Manager.Clients[player.Client].Hidden = false;
            }

            return true;
        }
    }

    class GlowCommand : Command
    {
        public GlowCommand() : base("glow", permLevel: 70)
        {
        }

        protected override bool Process(Player player, RealmTime time, string color)
        {
            if (String.IsNullOrWhiteSpace(color))
            {
                player.SendInfo("Usage: /glow <color>");
                return true;
            }

            player.Glow = Utils.FromString(color);

            var acc = player.Client.Account;
            acc.GlowColor = player.Glow;
            acc.FlushAsync();

            return true;
        }
    }

    class LinkCommand : Command
    {
        public LinkCommand() : base("link", permLevel: 50)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player?.Owner == null)
                return false;

            var world = player.Owner;
            if (world.Id < 0 || (player.Rank < 80 && !(world is Test)))
            {
                player.SendError("Forbidden.");
                return false;
            }

            if (!player.Manager.Monitor.AddPortal(world.Id))
            {
                player.SendError("Link already exists.");
                return false;
            }

            return true;
        }
    }

    class UnLinkCommand : Command
    {
        public UnLinkCommand() : base("unlink", permLevel: 50)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player?.Owner == null)
                return false;

            var world = player.Owner;
            if (world.Id < 0 || (player.Rank < 80 && !(world is Test)))
            {
                player.SendError("Forbidden.");
                return false;
            }

            if (!player.Manager.Monitor.RemovePortal(player.Owner.Id))
                player.SendError("Link not found.");
            else
                player.SendInfo("Link removed.");

            return true;
        }
    }

    class GiftCommand : Command
    {
        public GiftCommand() : base("gift", permLevel: 100)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player == null)
                return false;

            var manager = player.Manager;

            // verify argument
            var index = args.IndexOf(' ');
            if (string.IsNullOrWhiteSpace(args) || index == -1)
            {
                player.SendInfo("Usage: /gift <player name> <item name>");
                return false;
            }

            // get command args
            var playerName = args.Substring(0, index);
            Item item;
            if ((item = GetItem(player, args.Substring(index + 1))) == null)
            {
                return false;
            }

            // get player account
            if (Database.GuestNames.Contains(playerName))
            {
                player.SendError("Cannot gift the unnamed...");
                return false;
            }

            var id = manager.Database.ResolveId(playerName);
            var acc = manager.Database.GetAccount(id);
            if (id == 0 || acc == null)
            {
                player.SendError("Account not found!");
                return false;
            }

            var itemData = ItemData.GenerateData(item);
            itemData.Soulbound = true;

            if (item.SlotType != 10 && item.SlotType != 26)
            {
                var quality = ItemData.MakeQuality(item);
                itemData.Quality = quality;
                itemData.Runes = ItemData.GetRuneSlots(quality);
            }

            // add gift
            player.Manager.Database.AddGift(acc, itemData);
            string itemName = string.IsNullOrWhiteSpace(item.DisplayName) ? item.ObjectId : item.DisplayName;

            // send out success notifications
            player.SendInfo("You gifted {0} one {1}.", acc.Name, itemName);
            var gifted = player.Manager.Clients.Keys
                .SingleOrDefault(p => p.Account.AccountId == acc.AccountId);
            gifted?.Player?.SendInfo(
                "You received a gift from {0}. Enjoy your {1}.",
                player.Name,
                itemName);
            Log.Warn($"{player.Name} gifted {playerName} a {item.ObjectId}");
            return true;
        }

        private Item GetItem(Player player, string itemName)
        {
            var gameData = player.Manager.Resources.GameData;

            ushort objType;

            // allow both DisplayId and Id for query, prioritize Id
            if (!gameData.IdToObjectType.TryGetValue(itemName, out objType))
            {
                if (!gameData.DisplayIdToObjectType.TryGetValue(itemName, out objType))
                {
                    player.SendError("Unknown item type!");
                    return null;
                }
            }

            if (!gameData.Items.ContainsKey(objType))
            {
                player.SendError("Not an item!");
                return null;
            }


            return gameData.Items[objType];
        }
    }

    /*
    class RemovePets : Command
    {
        public RemovePets() : base("removeAllPets", permLevel: 100) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            // close all worlds / disconnect all players
            foreach (var w in player.Manager.Worlds.Values)
            {
                w.Closed = true;
                foreach (var p in w.Players.Values)
                    p.Client.Disconnect();
            }

            player.Manager.Database.RemoveAllPets(player.Manager.Resources.GameData);

            Program.Stop();
            return true;
        }
    }
    */

    /*
    class RemoveServerGold : Command
    {
        public RemoveServerGold() : base("removeAllGold", permLevel: 100) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            // close all worlds / disconnect all players
            foreach (var w in player.Manager.Worlds.Values)
            {
                w.Closed = true;
                foreach (var p in w.Players.Values)
                    p.Client.Disconnect();
            }

            player.Manager.Database.RemoveAllGold();

            Program.Stop();
            return true;
        }
    }
    */

    class OverrideAccountCommand : Command
    {
        public OverrideAccountCommand() : base("override", permLevel: 100)
        {
        }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            var acc = player.Client.Account;

            if (string.IsNullOrWhiteSpace(name))
            {
                player.SendError("Usage: /override <player name>");
                return false;
            }

            var id = player.Manager.Database.ResolveId(name);
            if (id == 0)
            {
                player.SendError("Account not found!");
                return false;
            }

            acc.AccountIdOverride = id;
            acc.FlushAsync();
            player.SendInfo("Account override set.");
            return true;
        }
    }

    class LevelCommand : Command
    {
        public LevelCommand() : base("level", permLevel: 80, aliases: "lvl")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            int val = int.Parse(args);
            if (val <= 300)
            {
                player.Level = val;
                player.ExperienceGoal = Player.GetExpGoal(val);
                player.Experience = Player.GetLevelExp(val);
                player.InvokeStatChange(StatsType.Experience, player.Experience - Player.GetLevelExp(val), true);
                player.CalculateFame();
                return true;
            }

            return false;
        }
    }

    class RenameCommand : Command
    {
        public RenameCommand() : base("rename", permLevel: 100)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var index = args.IndexOf(' ');
            if (string.IsNullOrWhiteSpace(args) || index == -1)
            {
                player.SendInfo("Usage: /rename <player name> <new player name>");
                return false;
            }

            var playerName = args.Substring(0, index);
            var newPlayerName = args.Substring(index + 1);

            var id = player.Manager.Database.ResolveId(playerName);
            if (id == 0)
            {
                player.SendError("Player account not found!");
                return false;
            }

            if (newPlayerName.Length < 3 || newPlayerName.Length > 10 || !newPlayerName.All(char.IsLetter) ||
                Database.GuestNames.Contains(newPlayerName))
            {
                player.SendError("New name is invalid. Must be between 3-10 char long and contain only letters.");
                return false;
            }

            string lockToken = null;
            var key = Database.NAME_LOCK;
            var db = player.Manager.Database;

            try
            {
                while ((lockToken = db.AcquireLock(key)) == null) ;

                if (db.Conn.HashExists("names", newPlayerName.ToUpperInvariant()))
                {
                    player.SendError("Name already taken");
                    return false;
                }

                var acc = db.GetAccount(id);
                if (acc == null)
                {
                    player.SendError("Account doesn't exist.");
                    return false;
                }

                using (var l = db.Lock(acc))
                    if (db.LockOk(l))
                    {
                        while (!db.RenameIGN(acc, newPlayerName, lockToken)) ;
                        player.SendInfo("Rename successful.");
                    }
                    else
                        player.SendError("Account in use.");
            }
            finally
            {
                if (lockToken != null)
                    db.ReleaseLock(key, lockToken);
            }

            return true;
        }
    }

    class UnnameCommand : Command
    {
        public UnnameCommand() : base("unname", permLevel: 100)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (string.IsNullOrWhiteSpace(args))
            {
                player.SendInfo("Usage: /unname <player name>");
                return false;
            }

            var playerName = args;

            var id = player.Manager.Database.ResolveId(playerName);
            if (id == 0)
            {
                player.SendError("Player account not found!");
                return false;
            }

            string lockToken = null;
            var key = Database.NAME_LOCK;
            var db = player.Manager.Database;

            try
            {
                while ((lockToken = db.AcquireLock(key)) == null) ;

                var acc = db.GetAccount(id);
                if (acc == null)
                {
                    player.SendError("Account doesn't exist.");
                    return false;
                }

                using (var l = db.Lock(acc))
                    if (db.LockOk(l))
                    {
                        while (!db.UnnameIGN(acc, lockToken)) ;
                        player.SendInfo("Account succesfully unnamed.");
                    }
                    else
                        player.SendError("Account in use.");
            }
            finally
            {
                if (lockToken != null)
                    db.ReleaseLock(key, lockToken);
            }

            return true;
        }
    }

    class WargCommand : Command
    {
        public WargCommand() : base("warg", permLevel: 90)
        {
        }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                player.SendError("Usage: /warg <mob name>");
                return false;
            }

            var target = player.GetNearestEntityByName(2900, name);
            if (target == null)
            {
                player.SendError("Mob not found.");
                return false;
            }

            if (target.Controller != null)
            {
                player.SendError("Only one person can control a mob at a time.");
                return false;
            }

            if (player.SpectateTarget != null)
            {
                player.SpectateTarget.FocusLost -= player.ResetFocus;
                player.SpectateTarget.Controller = null;
            }

            player.ApplyConditionEffect(ConditionEffectIndex.Paused);
            target.FocusLost += player.ResetFocus;
            target.Controller = player;
            player.SpectateTarget = target;
            player.Sight.UpdateCount++;

            player.Owner.Timers.Add(new WorldTimer(500, (w, t) =>
            {
                player.Client.SendPacket(new SetFocus()
                {
                    ObjectId = target.Id
                });
            }));
            return true;
        }
    }

    class CompactLOHCommand : Command
    {
        public CompactLOHCommand() : base("gccollect", aliases: "compactloh", permLevel: 100, listCommand: false)
        {
        }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            Log.Info("Doing manual Garbage Collection (command)");
            GCSettings.LargeObjectHeapCompactionMode = GCLargeObjectHeapCompactionMode.CompactOnce;
            GC.Collect();
            return true;
        }
    }

    class SetUnholyEssenceCommand : Command
    {
        public SetUnholyEssenceCommand() : base("setuhess", permLevel: 90, aliases: "unholyessence")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var amount = int.Parse(args);

            if (string.IsNullOrEmpty(args))
            {
                player.SendInfo("/setuhess <amount>");
                return false;
            }

            player.UnholyEssence = player.Client.Account.UnholyEssence = amount;
            player.ForceUpdate(player.UnholyEssence);
            return true;
        }
    }

    class SetDivineEssenceCommand : Command
    {
        public SetDivineEssenceCommand() : base("setdivess", permLevel: 90, aliases: "divineessence")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var amount = int.Parse(args);

            if (string.IsNullOrEmpty(args))
            {
                player.SendInfo("/setdivess <amount>");
                return false;
            }

            player.DivineEssence = player.Client.Account.DivineEssence = amount;
            player.ForceUpdate(player.DivineEssence);
            return true;
        }
    }

    class SetGoldCommand : Command
    {
        public SetGoldCommand() : base("setgold", 90, aliases: "gold")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var amount = int.Parse(args);

            if (string.IsNullOrEmpty(args))
            {
                player.SendInfo("/setgold <amount>");
                return false;
            }

            player.Credits = player.Client.Account.Credits = amount;
            player.ForceUpdate(player.Credits);
            return true;
        }
    }

    class SetFameCommand : Command
    {
        public SetFameCommand() : base("setfame", 90, aliases: "fame")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var amount = int.Parse(args);

            if (string.IsNullOrEmpty(args))
            {
                player.SendInfo("/setfame <amount>");
                return false;
            }

            player.CurrentFame = player.Client.Account.Fame = amount;
            player.ForceUpdate(player.Credits);
            return true;
        }
    }

    class AddQuest : Command
    {
        public AddQuest() : base("gq", 100)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Quests.GiveQuest(1, player.Level, player.Level > 50 ? 5 : 3, ignoreSameSlotType: true,
                extraMins: player.Random.Next(5, 30));
            return true;
        }
    }

    class ForceDungeonInvite : Command
    {
        public ForceDungeonInvite() : base("finvite", aliases: "finv", permLevel: 100)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            HashSet<string> invited = new();
            HashSet<string> missed = new();
            HashSet<string> unable = new();

            if (args.Contains("-g"))
            {
                foreach (var i in player.Manager.Clients.Keys
                    .Where(x => x.Player != null
                                && !x.Account.IgnoreList.Contains(player.AccountId)
                                && x.Account.GuildId > 0
                                && x.Account.GuildId == player.Client.Account.GuildId)
                    .Select(x => x.Player))
                {
                    if (i.Name.EqualsIgnoreCase(player.Name)) continue;

                    // already in the dungeon
                    if (i.Owner.Id == player.Owner.Id)
                    {
                        unable.Add(i.Name);
                        continue;
                    }

                    if (player.Manager.Chat.Invite(player, i.Name, player.Owner.GetDisplayName(), player.Owner.Id))
                    {
                        player.Owner.InviteDict.Add(i.Name.ToLower(), player);
                        player.Owner.Invites.Add(i.Name.ToLower());
                        invited.Add(i.Name);
                    }
                    else
                    {
                        missed.Add(i.Name);
                    }
                }

                if (invited.Count > 0)
                {
                    player.SendInfo("Invited: " + string.Join(", ", invited));
                }

                if (unable.Count > 0)
                {
                    player.SendInfo("In world: " + string.Join(", ", unable));
                }

                if (missed.Count > 0)
                {
                    player.SendInfo("Not found: " + string.Join(", ", missed));
                }

                return true;
            }

            var players = args.Split(' ').Where(n => !n.Equals("")).ToArray();

            if (players.Length > 0)
            {
                foreach (var p in players)
                {
                    if (player.Owner.InviteDict == null)
                    {
                        player.Owner.Invites = new HashSet<string>();
                        player.Owner.InviteDict = new Dictionary<string, Player>();
                    }

                    if (player.Manager.Chat.Invite(player, p, player.Owner.GetDisplayName(), player.Owner.Id))
                    {
                        player.Owner.InviteDict.Add(p.ToLower(), player);
                        player.Owner.Invites.Add(p.ToLower());
                        invited.Add(p);
                    }
                    else
                    {
                        missed.Add(p);
                    }
                }

                if (invited.Count > 0)
                {
                    player.SendInfo("Invited: " + string.Join(", ", invited));
                }

                if (unable.Count > 0)
                {
                    player.SendInfo("In world: " + string.Join(", ", unable));
                }

                if (missed.Count > 0)
                {
                    player.SendInfo("Not found: " + string.Join(", ", missed));
                }

                return true;
            }
            else
            {
                player.SendError("Specify some players to invite!");
                return false;
            }
        }
    }

    class ModDataCommand : Command
    {
        public ModDataCommand() : base("modify", aliases: "mod", permLevel: 90)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var arr = args.Split(' ');
            var slot = int.Parse(arr[0]);
            var property = arr[1];
            var value = string.Join(" ", arr.Skip(2).Take(arr.Length).ToArray());
            if (arr.Length == 0 || string.IsNullOrWhiteSpace(property) || string.IsNullOrWhiteSpace(value))
            {
                player.SendHelp("Usage: /modify <slot> <property> <value>");
                return false;
            }

            var item = player.Inventory[slot];
            if (item == new ItemData())
            {
                player.SendError("Empty slot");
                return false;
            }

            if (property.ToLower() == "uiid")
            {
                player.SendError("Cannot mod this value");
                return false;
            }

            var result = UpdateItemData(item, property, value);
            switch (result)
            {
                case UpdateResult.Success:
                    player.Inventory[slot] = item;
                    player.ForceUpdate(slot);
                    player.Stats.ReCalculateValues();
                    player.SendInfo($"Updated item data on slot {slot} [{property} = {value}]");
                    break;
                case UpdateResult.InvalidProperty:
                    player.SendError($"Invalid property \"{property}\"");
                    break;
                case UpdateResult.InvalidValue:
                    player.SendError(
                        $"Failed to update item data. \"{value}\" is not valid for property \"{property}\"");
                    break;
            }

            return true;
        }

        private UpdateResult UpdateItemData(ItemData item, string var, string val)
        {
            var field = typeof(ItemData).GetFields().FirstOrDefault(i => i.Name.EqualsIgnoreCase(var));
            if (field == null)
                return UpdateResult.InvalidProperty;

            var type = field.FieldType;
            if (type == typeof(string))
            {
                field.SetValue(item, val);
            }
            else if (type == typeof(int))
            {
                if (Utils.FromString(val, -1) == -1)
                    return UpdateResult.InvalidValue;
                field.SetValue(item, Utils.FromString(val));
            }
            else if (type == typeof(ushort))
            {
                if (!ushort.TryParse(val, out var res))
                    return UpdateResult.InvalidValue;
                field.SetValue(item, res);
            }
            else if (type == typeof(bool))
            {
                if (!bool.TryParse(val, out var res))
                    return UpdateResult.InvalidValue;
                field.SetValue(item, res);
            }
            else if (type == typeof(float))
            {
                if (!float.TryParse(val, out var res))
                    return UpdateResult.InvalidValue;
                field.SetValue(item, res);
            }
            else if (type == typeof(double))
            {
                if (!double.TryParse(val, out var res))
                    return UpdateResult.InvalidValue;
                field.SetValue(item, res);
            }
            else if (type == typeof(int[]))
            {
                object res;
                if (val.IndexOf(',') != -1)
                    res = val.Replace("[", "").Replace("]", "").Split(',').Select(n => int.Parse(n)).ToArray();
                else
                    res = new[] { int.Parse(val) };

                field.SetValue(item, res);
            }
            else if (type == typeof(ushort[]))
            {
                object res;
                if (val.IndexOf(',') != -1)
                    res = val.Replace("[", "").Replace("]", "").Split(',').Select(n => ushort.Parse(n)).ToArray();
                else
                    res = new[] { ushort.Parse(val) };

                field.SetValue(item, res);
            }
            else if (type == typeof(KeyValuePair<byte, short>[]))
            {
                object res = null;
                if (val.IndexOf(';') != -1)
                    res = val.Replace("[", "").Replace("]", "").Split(';').Select(n =>
                        new KeyValuePair<byte, short>(byte.Parse(n.Split(',')[0]), short.Parse(n.Split(',')[1]))).ToArray();
                else if (val.IndexOf(',') != -1)
                    res = new[]
                    {
                        new KeyValuePair<byte, short>(byte.Parse(val.Split(',')[0]), short.Parse(val.Split(',')[1]))
                    };

                if (res == null)
                    return UpdateResult.InvalidValue;
                field.SetValue(item, res);
            }
            else return UpdateResult.InvalidValue;

            return UpdateResult.Success;
        }

        private enum UpdateResult
        {
            Success,
            InvalidProperty,
            InvalidValue
        }
    }

    class ConvertMap : Command
    {
        // debug command to convert json maps to wmap (from resources/worlds folder)
        public ConvertMap() : base("convertmap", 100, listCommand: false)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!player.Manager.Config.serverSettings.debugMode)
            {
                player.SendError($"This command can only be used in debug mode");
                return false;
            }

            try
            {
                Json2Wmap.Convert(player.Manager.Resources.GameData,
                    player.Manager.Config.serverSettings.resourceFolder
                    + $"/worlds/{args}.jm",
                    player.Manager.Config.serverSettings.resourceFolder
                    + $"/worlds/wmap/{args}_{DateTime.UtcNow.ToUnixTimestamp()}.wmap");
                player.SendInfo($"Map successfully converted");
                return true;
            }
            catch
            {
                player.SendError("Error: Map not found");
                return false;
            }
        }
    }

    class SwapMapEndianness : Command
    {
        // reverse map endianness
        public SwapMapEndianness() : base("swapmapendianness", 100, listCommand: false)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!player.Manager.Config.serverSettings.debugMode)
            {
                player.SendError($"This command can only be used in debug mode");
                return false;
            }

            try
            {
                var json = Utils.ReadFile(player.Manager.Config.serverSettings.resourceFolder + $"/worlds/{args}.jm");
                Utils.WriteFile(
                    player.Manager.Config.serverSettings.resourceFolder + $"/worlds/{args}_little.jm",
                    JsonMap.Save(JsonMap.Load(json)));
                player.SendInfo($"Map successfully converted");
                return true;
            }
            catch
            {
                player.SendError("Error.");
                return false;
            }
        }
    }
    
    class ToggleImmunityCommand : Command
    {
        public ToggleImmunityCommand() : base("immunity", permLevel: 90)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var target = player.IsControlling ? player.SpectateTarget : player;
            if (!Enum.TryParse(args, true, out Immunity immunity))
            {
                player.SendError("Immunity not found");
                return false;
            }

            if (target.GetImmunity(immunity) == -2)
            {
                player.SendError("Something went wrong.");
                return false;
            }

            if (target.GetImmunity(immunity) > 0 || target.GetImmunity(immunity) == -1)
            {
                //remove
                target.InvokeStatChange((StatsType)immunity, 0);
                return true;
            }

            //add
            target.InvokeStatChange((StatsType)immunity, -1);
            return true;
        }
    }
    
    class LegendaryPopupCommand : Command
    {
        public LegendaryPopupCommand() : base("popup", 90, listCommand: false)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!player.Manager.Config.serverSettings.debugMode)
            {
                player.SendError($"This command can only be used in debug mode");
                return false;
            }
            
            player.Client.SendPacket(new GlobalNotification()
            {
                Text = "legendaryLoot"
            });
            return true;
        }
    }
    
    class AddPetCommand : Command
    {
        public AddPetCommand() : base("addpet", 90, listCommand: false)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var pets = player.Client.Account.PetDatas.ToList();
            try
            {
                var petData = new PetData();
                player.Manager.Database.IncrementHashField("account." + player.AccountId, "nextPetId");
                petData.Id = player.Manager.Database.GetAccountHashField(player.Client.Account, "nextPetId");
                petData.ObjectType = player.Manager.Resources.GameData.IdToObjectType[args];
                pets.Add(petData);
            }
            catch
            {
                player.SendError("Invalid name");
                return false;
            }

            player.Client.Account.PetDatas = pets.ToArray();
            player.Client.Account.FlushAsync();
            player.SendInfo($"Successfully added pet {args} to yard");
            return true;
        }
    }
    
    class ReloadBehaviorsCommand : Command
    {
        public ReloadBehaviorsCommand() : base("reload", 100, listCommand: false)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!player.Manager.Config.serverSettings.debugMode)
            {
                player.SendError($"This command can only be used in debug mode");
                return false;
            }
            
            player.Manager.Resources.LoadRawXmlBehaviors(player.Manager.Resources.ResourcePath);
            BehaviorDb.InitDb.InitXmlBehaviors(true);
            return true;
        }
    }
    
}