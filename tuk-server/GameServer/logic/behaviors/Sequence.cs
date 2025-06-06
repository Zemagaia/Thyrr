﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using GameServer.realm;

namespace GameServer.logic.behaviors
{
    //replacement for simple sequential state transition
    class Sequence : Behavior
    {
        //State storage: index

        CycleBehavior[] children;
        
        public Sequence(XElement e, IStateChildren[] children)
        {
            var behaviors = new List<CycleBehavior>();
            foreach (var child in children)
            {
                if (child is CycleBehavior cb)
                    behaviors.Add(cb);
            }

            this.children = behaviors.ToArray();
        }
        
        public Sequence(params CycleBehavior[] children)
        {
            this.children = children;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            foreach (var i in children)
                i.OnStateEntry(host, time);
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            int index;
            if (state == null) index = 0;
            else index = (int)state;

            children[index].Tick(host, time);
            if (children[index].Status == CycleStatus.Completed ||
                children[index].Status == CycleStatus.NotStarted)
            {
                index++;
                if (index == children.Length) index = 0;
            }

            state = index;
        }
    }
}
