﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using Shared;
using Shared.terrain;
using GameServer.realm.entities;
using NLog;
using Org.BouncyCastle.Security;
using GameServer.realm.worlds;
using GameServer.realm.worlds.logic;

namespace GameServer.realm
{
    public class PortalMonitor
    {
        static readonly Logger Log = LogUtil.GetLogger(typeof(PortalMonitor));

        private readonly Dictionary<int, Portal> _portals;
        private readonly World _world;
        private readonly RealmManager _manager;
        private readonly Random _rand;
        private readonly Regex _playerCountRgx;
        private readonly object _worldLock;

        public PortalMonitor(RealmManager manager, World world)
        {
            Log.Info("Initalizing Portal Monitor...");

            _manager = manager;
            _world = world;
            _portals = new Dictionary<int, Portal>();

            _rand = new Random();
            _playerCountRgx = new Regex(@" \((\d+)\)$");
            _worldLock = new object();
        }

        Position GetRandPosition()
        {
            var x = 0;
            var y = 0;
            var realmPortalRegions = _world.Map.Regions.Where(t => t.Value == TileRegion.Realm_Portals).ToArray();
            if (realmPortalRegions.Length > _portals.Count)
            {
                KeyValuePair<IntPoint, TileRegion> sRegion;
                do
                {
                    sRegion = realmPortalRegions.ElementAt(_rand.Next(0, realmPortalRegions.Length));
                } while (_portals.Values.Any(p => p.X == sRegion.Key.X + 0.5f && p.Y == sRegion.Key.Y + 0.5f));

                x = sRegion.Key.X;
                y = sRegion.Key.Y;
            }

            return new Position() { X = x, Y = y };
        }

        private static string[] _realmNames =
        {
            "Lich", "Goblin", "Ghost",
            "Giant", "Gorgon", "Blob",
            "Leviathan", "Unicorn", "Minotaur",
            "Cube", "Pirate", "Spider",
            "Snake", "Deathmage", "Gargoyle",
            "Scorpion", "Djinn", "Phoenix",
            "Satyr", "Drake", "Orc",
            "Flayer", "Cyclops", "Sprite",
            "Chimera", "Kraken", "Hydra",
            "Slime", "Ogre", "Hobbit",
            "Titan", "Medusa", "Golem",
            "Demon", "Skeleton", "Mummy",
            "Imp", "Bat", "Wyrm",
            "Spectre", "Reaper", "Beholder",
            "Dragon", "Harpy"
        };

        public bool AddPortal(int worldId, Portal portal = null, Position? position = null, bool announce = true)
        {
            if (_world == null)
                return false;

            lock (_worldLock)
            {
                if (_portals.ContainsKey(worldId))
                    return false;

                var world = _manager.Worlds[worldId];

                var pos = GetRandPosition();
                if (position != null)
                    pos = (Position)position;

                if (portal == null)
                {
                    world.SBName = _realmNames[MathUtils.Next(_realmNames.Length)];
                    portal = new Portal(_manager, 0x0101, null)
                    {
                        WorldInstance = world,
                        Name = world.GetDisplayName() + " (0)"
                    };
                    portal.SetDefaultSize(80);
                }

                portal.Move(pos.X + 0.5f, pos.Y + 0.5f);
                _world.EnterWorld(portal);
                _portals.Add(worldId, portal);
                Log.Info("Portal {0}({1}) added.", world.Id, world.GetDisplayName());
                if (announce)
                    foreach (var w in _manager.Worlds.Values)
                    foreach (var p in w.Players.Values)
                        p.SendInfo(string.Format("A portal to {0} has opened up{1}.",
                            (w == world) ? "this land" : world.GetDisplayName(),
                            (w is Realm) ? "" : " in Realm"));
                return true;
            }
        }

        public bool RemovePortal(int worldId)
        {
            if (_world == null)
                return false;

            lock (_worldLock)
            {
                if (!_portals.ContainsKey(worldId))
                    return false;

                var portal = _portals[worldId];
                _world.LeaveWorld(portal);
                _portals.Remove(worldId);
                Log.Info("Portal {0}({1}) removed.",
                    portal.WorldInstance.Id,
                    portal.WorldInstance.Name);
                return true;
            }
        }

        public bool RemovePortal(Portal portal)
        {
            if (_world == null)
                return false;

            lock (_worldLock)
            {
                if (!_portals.ContainsValue(portal))
                    return false;

                var worldId = _portals.FirstOrDefault(p => p.Value == portal).Key;
                _world.LeaveWorld(portal);
                _portals.Remove(worldId);
                Log.Info("Portal {0}({1}) removed.",
                    worldId, portal.WorldInstance.Name);
                return true;
            }
        }

        public bool RemovePortal(World world)
        {
            if (_world == null)
                return false;

            lock (_worldLock)
            {
                var portal = _portals.FirstOrDefault(p => p.Value.WorldInstance == world);
                if (portal.Value == null)
                    return false;

                _world.LeaveWorld(portal.Value);
                _portals.Remove(portal.Key);
                Log.Info("Portal {0}({1}) removed.",
                    portal.Key, portal.Value.WorldInstance.Name);
                return true;
            }
        }

        public void ClosePortal(int worldId)
        {
            if (_world == null)
                return;

            lock (_worldLock)
            {
                if (!_portals.ContainsKey(worldId))
                    return;

                var portal = _portals[worldId];
                if (portal.Usable)
                    portal.Usable = false;
            }
        }

        public void OpenPortal(int worldId)
        {
            if (_world == null)
                return;

            lock (_worldLock)
            {
                if (!_portals.ContainsKey(worldId))
                    return;

                var portal = _portals[worldId];
                if (!portal.Usable)
                    _portals[worldId].Usable = true;
            }
        }

        public bool PortalIsOpen(int worldId)
        {
            if (_world == null)
                return false;

            lock (_worldLock)
            {
                if (!_portals.ContainsKey(worldId))
                    return false;

                return _portals[worldId].Usable && !_portals[worldId].Locked;
            }
        }

        public void RenamePortal(int worldId, string name)
        {
            if (_world == null)
                return;

            lock (_worldLock)
            {
                if (_portals.ContainsKey(worldId) && !_portals[worldId].Name.Equals(name))
                    _portals[worldId].Name = name;
            }
        }

        public void UpdateWorldInstance(int worldId, World world)
        {
            if (_world == null)
                return;

            lock (_worldLock)
            {
                if (!_portals.ContainsKey(worldId))
                    return;

                _portals[worldId].WorldInstance = world;
            }
        }

        public void Tick(RealmTime t)
        {
            if (_world == null)
                return;

            lock (_worldLock)
            {
                foreach (var p in _portals.Values)
                {
                    if (p.WorldInstance == null || p.WorldInstance.Deleted)
                        continue;

                    var count = p.WorldInstance.Players.Count;
                    var updatedCount = _playerCountRgx.Replace(p.Name, $" ({count})");
                    if (p.Name.Equals(updatedCount))
                        continue;

                    p.Name = updatedCount;
                }
            }
        }
    }
}