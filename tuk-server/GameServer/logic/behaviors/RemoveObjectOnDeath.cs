﻿using System;
using System.Linq;
using System.Xml.Linq;
using Shared;
using Shared.resources;
using GameServer.realm;
using GameServer.realm.entities;
using Player = GameServer.realm.entities.Player;

namespace GameServer.logic.behaviors
{
    class RemoveObjectOnDeath : Behavior
    {
        private readonly string _objName;
        private readonly int _range;

        public RemoveObjectOnDeath(XElement e)
        {
            _objName = e.ParseString("@name");
            _range = e.ParseInt("@range");
        }
        
        public RemoveObjectOnDeath(string objName, int range)
        {
            _objName = objName;
            _range = range;
        }

        protected internal override void Resolve(State parent)
        {
            parent.Death += (sender, e) =>
            {

                XmlData dat = e.Host.Manager.Resources.GameData;
                var objType = dat.IdToObjectType[_objName];

                var map = e.Host.Owner.Map;

                var w = map.Width;
                var h = map.Height;

                for (var y = 0; y < h; y++)
                    for (var x = 0; x < w; x++)
                    {
                        var tile = map[x, y];

                        if (tile.ObjType != objType)
                            continue;

                        var dx = Math.Abs(x - (int)e.Host.X);
                        var dy = Math.Abs(y - (int)e.Host.Y);

                        if (dx > _range || dy > _range)
                            continue;

                        if (tile.ObjDesc?.BlocksSight == true)
                        {
                            foreach (var plr in e.Host.Owner.Players.Values
                                .Where(p => MathsUtils.DistSqr(p.X, p.Y, x, y) < Player.RadiusSqr))
                                plr.Sight.UpdateCount++;
                        }

                        tile.ObjType = 0;
                        tile.UpdateCount++;
                        map[x, y] = tile;
                    }
            };
        }
        protected override void TickCore(Entity host, RealmTime time, ref object state)
        { }
    }
}
