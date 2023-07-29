﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Shared;
using Shared.resources;
using GameServer.realm;
using GameServer.realm.entities;

namespace GameServer.logic.behaviors
{
    class Transform : Behavior
    {
        //State storage: none

        ushort target;
        
        public Transform(XElement e)
        {
            target = GetObjType(e.ParseString("@target"));
        }
        
        public Transform(string target)
        {
            this.target = GetObjType(target);
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            Entity entity = Entity.Resolve(host.Manager, target);
            if (entity is Portal
              && host.Owner.Name.Contains("Arena"))
            {
                return;
            }
            entity.Move(host.X, host.Y);

            if (host is Enemy && entity is Enemy && (host as Enemy).Spawned)
            {
                (entity as Enemy).Spawned = true;
                (entity as Enemy).ApplyConditionEffect(new ConditionEffect()
                {
                    Effect = ConditionEffectIndex.Invisible,
                    DurationMS = -1
                });
            }

            host.Owner.EnterWorld(entity);
            host.Owner.LeaveWorld(host);
        }
    }
}
