﻿using System.Xml.Linq;
using Shared;
using GameServer.realm;

namespace GameServer.logic.transitions
{
    class EntityNotExistsTransition : Transition
    {
        //State storage: none

        private readonly double _dist;
        private readonly ushort? _target;
        private readonly bool _attackTarget;
        
        public EntityNotExistsTransition(XElement e)
            : base(e.ParseString("@targetState", "root"))
        {
            _dist = e.ParseFloat("@dist");
            _target = Behavior.GetObjType(e.ParseString("@target"));
            _attackTarget = e.ParseBool("@checkAttackTarget");
        }

        public EntityNotExistsTransition(string target, double dist, string targetState, bool checkAttackTarget = false)
            : base(targetState)
        {
            _dist = dist;

            if (target != null)
                _target = Behavior.GetObjType(target);

            _attackTarget = checkAttackTarget;
        }

        protected override bool TickCore(Entity host, RealmTime time, ref object state)
        {
            if (_attackTarget)
            {
                if (host.AttackTarget == null || !host.Owner.Players.TryGetValue(host.AttackTarget.Id, out _))
                {
                    host.AttackTarget = null;
                    return true;
                }

                return false;
            }

            return host.GetNearestEntity(_dist, _target) == null;
        }
    }
}