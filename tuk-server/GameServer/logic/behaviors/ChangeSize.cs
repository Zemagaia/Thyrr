﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Shared;
using GameServer.realm;

namespace GameServer.logic.behaviors
{
    class ChangeSize : Behavior
    {
        //State storage: cooldown timer

        int rate;
        int target;
        
        public ChangeSize(XElement e)
        {
            rate = e.ParseInt("@rate");
            target = e.ParseInt("@target");
        }

        public ChangeSize(int rate, int target)
        {
            this.rate = rate;
            this.target = target;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            state = 0;
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            int cool = (int)state;

            if (cool <= 0)
            {
                var size = host.Size;
                if (size != target)
                {
                    size += rate;
                    if ((rate > 0 && size > target) ||
                        (rate < 0 && size < target))
                        size = target;

                    host.Size = size;
                }
                cool = 150;
            }
            else
                cool -= time.ElapsedMsDelta;

            state = cool;
        }
    }
}
