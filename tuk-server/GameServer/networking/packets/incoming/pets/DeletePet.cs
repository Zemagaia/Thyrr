using Shared;

namespace GameServer.networking.packets.incoming.pets
{
    public class DeletePet : IncomingMessage
    {
        public PetData PetData;
        
        public override Packet CreateInstance() => new DeletePet();

        public override PacketId ID => PacketId.DELETE_PET;

        protected override void Read(NReader rdr)
        {
            PetData = PetData.Read(rdr);
        }
    }
}