﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Shared;
using Shared.resources;
using GameServer.realm;
using Mono.Game;
using GameServer.realm.entities;

namespace GameServer.logic.behaviors
{
    class BringEnemy : Behavior
    {
        string name;
        double range;
        
        public BringEnemy(XElement e)
        {
            range = e.ParseFloat("@range");
            name = e.ParseString("@name");
        }
        
        public BringEnemy(string name, double range)
        {
            this.name = name;
            this.range = range;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            foreach (var entity in host.GetNearestEntitiesByName(range, name).OfType<Enemy>())
                entity.Move(host.X, host.Y);
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
        }
    }
}
