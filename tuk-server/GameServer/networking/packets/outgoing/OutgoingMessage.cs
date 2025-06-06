﻿using Shared;

namespace GameServer.networking.packets.outgoing
{
    public abstract class OutgoingMessage : Packet
    {
        public override void Crypt(Client client, byte[] dat, int offset, int len)
        {
            client.SendKey.Crypt(dat, offset, len);
        }

        protected override void Read(NReader rdr)
        {
        }
    }
}