﻿using System;
using System.Xml.Linq;
using Shared;
using GameServer.realm;

namespace GameServer.logic.transitions
{
    class TimedTransition : Transition
    {
        //State storage: cooldown timer

        int time;
        bool randomized;
        
        public TimedTransition(XElement e)
            : base(e.ParseString("@targetState", "root"))
        {
            time = e.ParseInt("@time");
            randomized = e.ParseBool("@randomizedTime");
        }

        public TimedTransition(int time, string targetState, bool randomized = false)
            : base(targetState)
        {
            this.time = time;
            this.randomized = randomized;
        }

        protected override bool TickCore(Entity host, RealmTime time, ref object state)
        {
            int cool;
            if (state == null) cool = randomized ? Random.Next(this.time) : this.time;
            else cool = (int)state;

            bool ret = false;
            if (cool <= 0)
            {
                ret = true;
                cool = this.time;
            }
            else
                cool -= time.ElapsedMsDelta;

            state = cool;
            return ret;
        }
    }
}