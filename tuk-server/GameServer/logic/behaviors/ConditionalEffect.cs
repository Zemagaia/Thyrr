﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Shared;
using Shared.resources;
using GameServer.realm;

namespace GameServer.logic.behaviors
{
    class ConditionalEffect : Behavior
    {
        //State storage: none

        ConditionEffectIndex effect;
        bool perm;
        int duration;
        
        public ConditionalEffect(XElement e)
        {
            effect = e.ParseConditionEffect("@effect");
            perm = e.ParseBool("@perm");
            duration = e.ParseInt("@duration", -1);
        }
        
        public ConditionalEffect(ConditionEffectIndex effect, bool perm = false, int duration = -1)
        {
            this.effect = effect;
            this.perm = perm;
            this.duration = duration; 
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            host.ApplyConditionEffect(new ConditionEffect()
            {
                Effect = effect,
                DurationMS = duration
            });
        }

        protected override void OnStateExit(Entity host, RealmTime time, ref object state)
        {
            if (!perm)
            {
                host.ApplyConditionEffect(new ConditionEffect()
                {
                    Effect = effect,
                    DurationMS = 0
                });
            }
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        { }
    }
}
