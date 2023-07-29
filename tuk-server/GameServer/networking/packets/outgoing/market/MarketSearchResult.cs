﻿using Shared;

namespace GameServer.networking.packets.outgoing.market
{
    public class MarketSearchResult : OutgoingMessage
    {
        public override Packet CreateInstance() => new MarketSearchResult();

        public override PacketId ID => PacketId.MARKET_SEARCH_RESULT;

        public MarketData[] Results;
        public string Description;

        protected override void Write(NWriter wtr)
        {
            wtr.Write((short)Results.Length);
            for (int i = 0; i < Results.Length; i++)
            {
                Results[i].Write(wtr);
            }

            wtr.WriteUTF(Description);
        }
    }
}