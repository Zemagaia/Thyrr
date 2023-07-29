﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Shared;
using GameServer.realm;
using GameServer.realm.entities;

namespace GameServer.logic.behaviors
{
    class WhileEntityNotWithin : Behavior
    {

        Behavior child;
        string entityName;
        double range;
        
        public WhileEntityNotWithin(XElement e, IStateChildren[] behaviors)
        {
            foreach (var behavior in behaviors)
            {
                if (behavior is Behavior bh)
                {
                    child = bh;
                    break;
                }
            }
            
            entityName = e.ParseString("@entityName");
            range = e.ParseFloat("@range");
        }
        
        public WhileEntityNotWithin(Behavior child, string entityName, double range)
        {
            this.child = child;
            this.entityName = entityName;
            this.range = range;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
             child.OnStateEntry(host, time);
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            if(host.GetNearestEntityByName(range, entityName) == null)
               child.Tick(host, time);
        }
    }
}
