﻿using System.Linq;
using wServer.networking.packets;
using wServer.networking.packets.incoming;
using wServer.realm;
using wServer.realm.entities;

namespace wServer.networking.handlers
{
    class PlayerHitHandler : PacketHandlerBase<PlayerHit>
    {
        public override PacketId ID => PacketId.PLAYERHIT;

        protected override void HandlePacket(Client client, PlayerHit packet)
        {
            client.Manager.Logic.AddPendingAction(t => Handle(client.Player, t, packet.ObjectId, packet.BulletId));
        }

        private void Handle(Player player, RealmTime time, int objectId, byte bulletId)
        {
            if (player?.Owner == null)
                return;

            var prj = player.Owner.GetProjectile(objectId, bulletId);
            if (prj == null)
                return;

            if (prj.ProjDesc.Effects != null)
                foreach (var effect in prj.ProjDesc.Effects)
                {
                    player.ApplyConditionEffect(effect);
                }

            prj.ForceHit(player, time);
            player.AcLastHitTime = time.TotalElapsedMs;
            player.AcShotsHit++;
        }
    }
}