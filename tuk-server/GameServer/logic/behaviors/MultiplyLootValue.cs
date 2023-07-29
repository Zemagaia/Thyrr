using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Shared;
using GameServer.realm;
using GameServer.realm.entities;

namespace GameServer.logic.behaviors
{
    class MultiplyLootValue : Behavior
    {
        //State storage: cooldown timer

        int multiplier;
        
        public MultiplyLootValue(XElement e)
        {
            multiplier = e.ParseInt("@multiplier");
        }

        public MultiplyLootValue(int multiplier)
        {
            this.multiplier = multiplier;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            state = false;
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            bool multiplied = (bool)state;
            if (!multiplied)
            {
                var newLootValue = host.LootValue * multiplier;
                host.LootValue = newLootValue;
                multiplied = true;
            }
            state = multiplied;
        }
    }
}
