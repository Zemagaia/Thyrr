using wServer.networking.packets;
using wServer.networking.packets.incoming;
using wServer.networking.packets.incoming.skillTree.abilities;
using wServer.realm;
using wServer.realm.entities;

namespace wServer.networking.handlers.skillTree.abilities
{
    class OffensiveAbilityHandler : PacketHandlerBase<OffensiveAbility>
    {
        public override PacketId ID => PacketId.OFFENSIVE_ABILITY;

        protected override void HandlePacket(Client client, OffensiveAbility packet)
        {
            client.Manager.Logic.AddPendingAction(t => Handle(client.Player, t, packet));
        }

        void Handle(Player player, RealmTime time, OffensiveAbility packet)
        {
            if (player?.Owner == null)
                return;

            player.UseOffensiveAbility(time, packet.Time, packet.UsePos, packet.Angle);
        }
    }
}