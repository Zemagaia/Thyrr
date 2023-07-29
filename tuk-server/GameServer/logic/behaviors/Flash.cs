﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Shared;
using GameServer.networking.packets.outgoing;
using GameServer.realm;
using GameServer.realm.entities;

namespace GameServer.logic.behaviors
{
    class Flash : Behavior
    {
        //State storage: none

        uint color;
        float flashPeriod;
        int flashRepeats;
        
        public Flash(XElement e)
        {
            color = e.ParseUInt("@color");
            flashPeriod = e.ParseFloat("@flashPeriod");
            flashRepeats = e.ParseInt("@flashRepeats");
        }
        
        public Flash(uint color, double flashPeriod, int flashRepeats)
        {
            this.color = color;
            this.flashPeriod = (float)flashPeriod;
            this.flashRepeats = flashRepeats;
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state) { }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            host.Owner.BroadcastPacketNearby(new ShowEffect()
            {
                EffectType = EffectType.Flashing,
                Pos1 = new Position() { X = flashPeriod, Y = flashRepeats },
                TargetObjectId = host.Id,
                Color = new ARGB(color)
            }, host, null);
        }
    }
}
