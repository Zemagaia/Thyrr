﻿using System.Linq;
using System.Xml.Linq;
using Shared;
using Shared.resources;
using Mono.Game;
using GameServer.realm;
using GameServer.realm.entities;

namespace GameServer.logic.behaviors
{
    class ReturnToSpawn : CycleBehavior
    {
        private readonly float _speed;
        private readonly float _returnWithinRadius;

        public ReturnToSpawn(XElement e)
        {
            _speed = e.ParseFloat("@speed");
            _returnWithinRadius = e.ParseFloat("@returnWithinRadius", 1);
        }
        
        public ReturnToSpawn(double speed, double returnWithinRadius = 1)
        {
            _speed = (float) speed;
            _returnWithinRadius = (float) returnWithinRadius;
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            if (!(host is Enemy)) return;

            if (host.HasConditionEffect(ConditionEffects.Paralyzed))
                return;

            var spawn = (host as Enemy).SpawnPoint;
            var vect = new Vector2(spawn.X, spawn.Y) - new Vector2(host.X, host.Y);
            if (vect.Length() > _returnWithinRadius)
            {
                Status = CycleStatus.InProgress;
                vect.Normalize();
                vect *= host.GetSpeed(_speed) * (time.ElapsedMsDelta / 1000f);
                host.ValidateAndMove(host.X + vect.X, host.Y + vect.Y);
            }
            else
            {
                Status = CycleStatus.Completed;
            }
        }
    }
}
