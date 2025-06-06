﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Shared;
using Shared.resources;
using GameServer.realm;
using Mono.Game;

namespace GameServer.logic.behaviors
{
    class Buzz : CycleBehavior
    {
        //State storage: direction & remain
        class BuzzStorage
        {
            public Vector2 Direction;
            public float RemainingDistance;
            public int RemainingTime;
        }


        float speed;
        float dist;
        // ?
        Cooldown coolDown;
        
        public Buzz(XElement e)
        {
            speed = e.ParseFloat("@speed");
            dist = e.ParseFloat("@dist");
            coolDown = new Cooldown().Normalize(e.ParseInt("@coolDown", 1));
        }
        
        public Buzz(double speed = 2, double dist = 0.5, Cooldown coolDown = new Cooldown())
        {
            this.speed = (float)speed;
            this.dist = (float)dist;
            this.coolDown = coolDown.Normalize(1);
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            state = new BuzzStorage();
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            BuzzStorage storage = (BuzzStorage)state;

            Status = CycleStatus.NotStarted;

            if (host.HasConditionEffect(ConditionEffects.Paralyzed))
                return;

            if (storage.RemainingTime > 0)
            {
                storage.RemainingTime -= time.ElapsedMsDelta;
                Status = CycleStatus.NotStarted;
            }
            else
            {
                Status = CycleStatus.InProgress;
                if (storage.RemainingDistance <= 0)
                {
                    do
                    {
                        storage.Direction = new Vector2(Random.Next(-1, 2), Random.Next(-1, 2));
                    } while (storage.Direction.X == 0 && storage.Direction.Y == 0);
                    storage.Direction.Normalize();
                    storage.RemainingDistance = this.dist;
                    Status = CycleStatus.Completed;
                }
                float dist = host.GetSpeed(speed) * (time.ElapsedMsDelta / 1000f);
                host.ValidateAndMove(host.X + storage.Direction.X * dist, host.Y + storage.Direction.Y * dist);

                storage.RemainingDistance -= dist;
            }

            state = storage;
        }
    }
}
