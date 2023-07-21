using common;

namespace wServer.networking.packets.incoming.pets
{
    public class PetFollow : IncomingMessage
    {
        public PetData PetData;
        
        public override Packet CreateInstance() => new PetFollow();

        public override PacketId ID => PacketId.PET_FOLLOW;

        protected override void Read(NReader rdr)
        {
            PetData = PetData.Read(rdr);
        }
    }
}