﻿using System.Xml.Linq;
using Shared;
using Shared.resources;
using GameServer.realm;
using GameServer.realm.entities;

namespace GameServer.logic.behaviors
{
    class TransferDamageOnDeath : Behavior
    {
        private readonly ushort _target;
        private readonly float _radius;

        public TransferDamageOnDeath(XElement e)
        {
            _target = GetObjType(e.ParseString("@target"));
            _radius = e.ParseFloat("@radius");
        }
        
        public TransferDamageOnDeath(string target, float radius = 50)
        {
            _target = GetObjType(target);
            _radius = radius;
        }

        protected internal override void Resolve(State parent)
        {
            parent.Death += (sender, e) =>
            {
                var enemy = e.Host as Enemy;
                
                if (enemy == null)
                    return;

                var targetObj = e.Host.GetNearestEntity(_radius, _target) as Enemy;

                if (targetObj == null)
                    return;

                enemy.DamageCounter.TransferData(targetObj.DamageCounter);
            };
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        { }
    }
}
