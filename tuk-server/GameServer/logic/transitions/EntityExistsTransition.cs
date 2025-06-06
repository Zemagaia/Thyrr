﻿using System.Xml.Linq;
using GameServer.realm;
using Shared;

namespace GameServer.logic.transitions
{
    class EntityExistsTransition : Transition
    {
        //State storage: none

        readonly double _dist;
        readonly ushort _target;
        
        public EntityExistsTransition(XElement e)
            : base(e.ParseString("@targetState", "root"))
        {
            _dist = e.ParseFloat("@dist");
            _target = Behavior.GetObjType(e.ParseString("@target"));
        }

        public EntityExistsTransition(string target, double dist, string targetState)
            : base(targetState)
        {
            _dist = dist;
            _target = Behavior.GetObjType(target);
        }

        protected override bool TickCore(Entity host, RealmTime time, ref object state)
        {
            return host.GetNearestEntity(_dist, _target) != null;
        }
    }
}