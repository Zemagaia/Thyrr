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
    class StayCloseToSpawn : CycleBehavior
    {
        //State storage: target position
        //assume spawn=state entry position

        float speed;
        int range;
        
        public StayCloseToSpawn(XElement e)
        {
            speed = e.ParseFloat("@speed");
            range = e.ParseInt("@range", 5);
        }
        
        public StayCloseToSpawn(double speed, int range = 5)
        {
            this.speed = (float)speed;
            this.range = range;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            state = new Vector2(host.X, host.Y);
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            Status = CycleStatus.NotStarted;

            if (host.HasConditionEffect(ConditionEffects.Paralyzed))
                return;

            if (!(state is Vector2))
            {
                state = new Vector2(host.X, host.Y);
                Status = CycleStatus.Completed;
                return;
            }

            var vect = (Vector2) state;
            if ((vect - new Vector2(host.X, host.Y)).Length() > range)
            {
                vect -= new Vector2(host.X, host.Y);
                vect.Normalize();
                float dist = host.GetSpeed(speed) * (time.ElapsedMsDelta / 1000f);
                host.ValidateAndMove(host.X + vect.X * dist, host.Y + vect.Y * dist);

                Status = CycleStatus.InProgress;
            }
            else
                Status = CycleStatus.Completed;
        }
    }
}
