﻿using Shared;

namespace GameServer.networking.packets.incoming
{
    public class UpdateAck : IncomingMessage
    {
        public override PacketId ID => PacketId.UPDATEACK;

        public override Packet CreateInstance()
        {
            return new UpdateAck();
        }

        protected override void Read(NReader rdr)
        {
        }

        protected override void Write(NWriter wtr)
        {
        }
    }
}