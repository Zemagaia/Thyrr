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
    class Follow : CycleBehavior
    {
        //State storage: follow state
        class FollowState
        {
            public F State;
            public int RemainingTime;
        }
        enum F
        {
            DontKnowWhere,
            Acquired,
            Resting
        }
        
        public Follow(XElement e)
        {
            speed = e.ParseFloat("@speed");
            acquireRange = e.ParseFloat("@acquireRange", 10);
            range = e.ParseFloat("@range", 6);
            duration = e.ParseInt("@duration");
            coolDown = new Cooldown().Normalize(e.ParseInt("@coolDown"));
        }

        float speed;
        float acquireRange;
        float range;
        int duration;
        Cooldown coolDown;
        public Follow(double speed, double acquireRange = 10, double range = 6,
            int duration = 0, Cooldown coolDown = new Cooldown())
        {
            this.speed = (float)speed;
            this.acquireRange = (float)acquireRange;
            this.range = (float)range;
            this.duration = duration;
            this.coolDown = coolDown.Normalize(duration == 0 ? 0 : 1000);
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            FollowState s;
            if (state == null) s = new FollowState();
            else s = (FollowState)state;

            Status = CycleStatus.NotStarted;

            if (host.HasConditionEffect(ConditionEffects.Paralyzed))
                return;

            var player = host.AttackTarget ?? host.GetNearestEntity(acquireRange, null);

            Vector2 vect;
            switch (s.State)
            {
                case F.DontKnowWhere:
                    if (player != null && s.RemainingTime <= 0)
                    {
                        s.State = F.Acquired;
                        if (duration > 0)
                            s.RemainingTime = duration;
                        goto case F.Acquired;
                    }
                    else if (s.RemainingTime > 0)
                        s.RemainingTime -= time.ElapsedMsDelta;
                    break;
                case F.Acquired:
                    if (player == null)
                    {
                        s.State = F.DontKnowWhere;
                        s.RemainingTime = 0;
                        break;
                    }
                    else if (s.RemainingTime <= 0 && duration > 0)
                    {
                        s.State = F.DontKnowWhere;
                        s.RemainingTime = coolDown.Next(Random);
                        Status = CycleStatus.Completed;
                        break;
                    }
                    if (s.RemainingTime > 0)
                        s.RemainingTime -= time.ElapsedMsDelta;

                    vect = new Vector2(player.X - host.X, player.Y - host.Y);
                    if (vect.Length() > range)
                    {
                        Status = CycleStatus.InProgress;
                        vect.X -= Random.Next(-2, 2) / 2f;
                        vect.Y -= Random.Next(-2, 2) / 2f;
                        vect.Normalize();
                        float dist = host.GetSpeed(speed) * (time.ElapsedMsDelta / 1000f);
                        host.ValidateAndMove(host.X + vect.X * dist, host.Y + vect.Y * dist);
                    }
                    else
                    {
                        Status = CycleStatus.Completed;
                        s.State = F.Resting;
                        s.RemainingTime = 0;
                    }
                    break;
                case F.Resting:
                    if (player == null)
                    {
                        s.State = F.DontKnowWhere;
                        if (duration > 0)
                            s.RemainingTime = duration;
                        break;
                    }
                    Status = CycleStatus.Completed;
                    vect = new Vector2(player.X - host.X, player.Y - host.Y);
                    if (vect.Length() > range + 1)
                    {
                        s.State = F.Acquired;
                        s.RemainingTime = duration;
                        goto case F.Acquired;
                    }
                    break;

            }

            state = s;
        }
    }
}
