﻿using common;

namespace wServer.networking.packets.outgoing.market
{
    public class MarketMyOffersResult : OutgoingMessage
    {
        public override Packet CreateInstance() => new MarketMyOffersResult();

        public override PacketId ID => PacketId.MARKET_MY_OFFERS_RESULT;

        public MarketData[] Results;

        protected override void Write(NWriter wtr)
        {
            wtr.Write((short)Results.Length);
            for (int i = 0; i < Results.Length; i++)
            {
                Results[i].Write(wtr);
            }
        }
    }
}