﻿using Shared;

namespace GameServer.networking.packets.outgoing
{
    public class TradeStart : OutgoingMessage
    {
        public TradeItem[] MyItems { get; set; }
        public string YourName { get; set; }
        public TradeItem[] YourItems { get; set; }

        public override PacketId ID => PacketId.TRADESTART;

        public override Packet CreateInstance()
        {
            return new TradeStart();
        }

        protected override void Write(NWriter wtr)
        {
            wtr.Write((short)MyItems.Length);
            foreach (var i in MyItems)
                i.Write(wtr);

            wtr.WriteUTF(YourName);
            wtr.Write((short)YourItems.Length);
            foreach (var i in YourItems)
                i.Write(wtr);
        }
    }
}