﻿using System.Xml.Linq;
using Shared;
using GameServer.realm;

namespace GameServer.logic.transitions
{
    class NoPlayerWithinTransition : Transition
    {
        //State storage: none

        private readonly double _dist;
        private readonly bool _seeInvis;
        
        public NoPlayerWithinTransition(XElement e)
            : base(e.ParseString("@targetState", "root"))
        {
            _dist = e.ParseInt("@dist");
            _seeInvis = e.ParseBool("@seeInvis");
        }

        public NoPlayerWithinTransition(double dist, string targetState, bool seeInvis = false)
            : base(targetState)
        {
            _dist = dist;
            _seeInvis = seeInvis;
        }

        protected override bool TickCore(Entity host, RealmTime time, ref object state)
        {
            return host.GetNearestEntity(_dist, null, _seeInvis) == null;
        }
    }
}