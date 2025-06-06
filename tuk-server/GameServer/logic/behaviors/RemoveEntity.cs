﻿using System.Linq;
using System.Xml.Linq;
using Shared;
using GameServer.realm;
using GameServer.realm.entities;

namespace GameServer.logic.behaviors
{
    class RemoveEntity : Behavior
    {
        private readonly float dist;
        private readonly string children;

        public RemoveEntity(XElement e)
        {
            dist = e.ParseFloat("@dist");
            children = e.ParseString("@children");
        }
        
        public RemoveEntity(double dist, string children)
        {
            this.dist = (float)dist;
            this.children = children;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            var lastKilled = -1;
            var killed = 0;
            while (killed != lastKilled)
            {
                lastKilled = killed;
                foreach (var entity in host.GetNearestEntitiesByName(dist, children).OfType<Enemy>())
                {
                    entity.Spawned = true;
                    entity.Death(time);
                    killed++;
                }
            }

        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
        }
    }
}