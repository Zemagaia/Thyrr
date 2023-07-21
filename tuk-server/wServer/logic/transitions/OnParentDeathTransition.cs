﻿using System.Xml.Linq;
using common;
using wServer.realm;
using wServer.realm.entities;

namespace wServer.logic.transitions
{
    class OnParentDeathTransition : Transition
    {
        private bool parentDead;
        private bool init;

        public OnParentDeathTransition(XElement e)
            : base(e.ParseString("@targetState", "root"))
        {
        }
        
        public OnParentDeathTransition(string targetState)
            :base(targetState)
        {
        }

        protected override bool TickCore(Entity host, RealmTime time, ref object state)
        {
            if (!init && host is Enemy)
            {
                init = true;
                var enemyHost = host as Enemy;
                if (enemyHost.ParentEntity != null)
                {
                    (host as Enemy).ParentEntity.OnDeath +=
                        (sender, e) => parentDead = true;
                }
            }

            return parentDead;
        }
    }
}