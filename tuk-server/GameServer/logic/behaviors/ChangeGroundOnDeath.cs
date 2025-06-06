﻿using System.Xml.Linq;
using Shared;
using GameServer.realm;
using GameServer.realm.worlds;

namespace GameServer.logic.behaviors
{
    public class ChangeGroundOnDeath : Behavior
    {
        private readonly int dist;
        private readonly string[] groundToChange;
        private readonly string[] targetType;

        public ChangeGroundOnDeath(XElement e)
        {
            groundToChange = e.ParseStringArray("@groundTypes", ',');
            targetType = e.ParseStringArray("@targetTypes", ',');
            dist = e.ParseInt("@dist");
        }
        
        /// <summary>
        ///     Changes the ground if the monster dies
        /// </summary>
        /// <param name="groundTypes">The tiles you want to change (null for every tile)</param>
        /// <param name="targetTypes">The tiles who will replace the old once</param>
        /// <param name="dist">The distance around the monster</param>
        public ChangeGroundOnDeath(string[] groundTypes, string[] targetTypes, int dist)
        {
            groundToChange = groundTypes;
            targetType = targetTypes;
            this.dist = dist;
        }

        protected internal override void Resolve(State parent)
        {
            parent.Death += (sender, e) =>
            {
                var dat = e.Host.Manager.Resources.GameData;
                var w = e.Host.Owner;
                var pos = new IntPoint((int)e.Host.X - (dist / 2), (int)e.Host.Y - (dist / 2));
                if (w == null)
                    return;
                for (int x = 0; x < dist; x++)
                {
                    for (int y = 0; y < dist; y++)
                    {
                        WmapTile tile = w.Map[x + pos.X, y + pos.Y].Clone();
                        if (groundToChange != null)
                        {
                            foreach (string type in groundToChange)
                            {
                                int r = Random.Next(targetType.Length);
                                if (tile.TileId == dat.IdToTileType[type])
                                {
                                    tile.TileId = dat.IdToTileType[targetType[r]];
                                    w.Map[x + pos.X, y + pos.Y] = tile;
                                }
                            }
                        }
                        else
                        {
                            int r = Random.Next(targetType.Length);
                            tile.TileId = dat.IdToTileType[targetType[r]];
                            w.Map[x + pos.X, y + pos.Y] = tile;
                        }
                    }
                }
            };
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
        }
    }
}