using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using common;
using common.resources;
using wServer.realm;
using Mono.Game;
using wServer.realm.entities;

namespace wServer.logic.behaviors
{
    class TeleportToTarget : CycleBehavior
    {
        float range;
        
        public TeleportToTarget(XElement e)
        {
            range = e.ParseFloat("@range");
        }
        
        public TeleportToTarget(double range)
        {
            this.range = (float)range;
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            Status = CycleStatus.NotStarted;

            var player = host.AttackTarget ?? null;
            if (player == null)
            {
                state = CycleStatus.Completed;
                return;
            }

            Vector2 vect;
            vect = new Vector2{ X = player.X - host.X, Y = player.Y - host.Y};
            if (vect.Length() > range)
            {
                host.Move(player.X, player.Y);
                state = CycleStatus.InProgress;
            }
            else
                state = CycleStatus.Completed;
        }
    }
}
