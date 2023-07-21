﻿using System;
using System.Linq;
using common.resources;
using wServer.networking.packets.outgoing;
using wServer.realm.worlds;

namespace wServer.realm.entities
{
    public partial class Player
    {
        long l;

       /*  private void HandleOceanTrenchGround(RealmTime time)
        {
            try
            {
                // don't suffocate hidden players
                if (HasConditionEffect(ConditionEffects.Hidden)) return;

                if (time.TotalElapsedMs - l <= 100 || Owner?.Name != "OceanTrench") return;

                if (!(Owner?.StaticObjects.Where(i => i.Value.ObjectType == 0x098e).Count(i =>
                    (X - i.Value.X) * (X - i.Value.X) + (Y - i.Value.Y) * (Y - i.Value.Y) < 1) > 0))
                {
                    if (OxygenBar == 0)
                        HP -= 10;
                    else
                        OxygenBar -= 2;

                    if (HP <= 0)
                        Death("suffocation");
                }
                else
                {
                    if (OxygenBar < 100)
                        OxygenBar += 8;
                    if (OxygenBar > 100)
                        OxygenBar = 100;
                }

                l = time.TotalElapsedMs;
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
        } */

       public void DamagePlayerGround(Position pos, int damage)
        {
            WmapTile tile = Owner.Map[(int)pos.X, (int)pos.Y];
            TileDesc tileDesc = Manager.Resources.GameData.Tiles[tile.TileId];

            var limit = (int)Math.Min(ShieldMax + 100, ShieldMax * 1.3);
            if (Shield > 0)
                ShieldDamage += damage;
            else if (ShieldDamage + damage <= limit)
            {
                // more accurate... maybe
                ShieldDamage += damage;
                HP -= damage;
            }
            else
                HP -= damage;

            Owner.BroadcastPacketNearby(new Damage()
            {
                TargetId = Id,
                DamageAmount = (ushort)damage,
                Kill = HP <= 0,
            }, this);

            if (HP <= 0)
            {
                Death(tileDesc.ObjectId, tile: tile);
            }
        }
    }
}