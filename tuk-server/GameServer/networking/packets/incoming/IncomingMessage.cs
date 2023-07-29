using Shared;

namespace GameServer.networking.packets.incoming
{
    public abstract class IncomingMessage : Packet
    {
        public override void Crypt(Client client, byte[] dat, int offset, int len)
        {
            client.ReceiveKey.Crypt(dat, offset, len);
        }

        protected override void Write(NWriter wtr)
        {
        }
    }
}