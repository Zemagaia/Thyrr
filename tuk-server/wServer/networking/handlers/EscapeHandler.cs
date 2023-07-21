using System;
using wServer.networking.packets;
using wServer.networking.packets.incoming;
using wServer.networking.packets.outgoing;
using wServer.realm;
using wServer.realm.worlds;
using wServer.realm.worlds.logic;

namespace wServer.networking.handlers
{
    class EscapeHandler : PacketHandlerBase<Escape>
    {
        public override PacketId ID => PacketId.ESCAPE;

        protected override void HandlePacket(Client client, Escape packet)
        {
            client.Manager.Logic.AddPendingAction(t => Handle(t, client));
        }

        private void Handle(RealmTime time, Client client)
        {
            if (client.Player == null || client.Player.Owner == null)
                return;

            var realm = client.Player.Owner as Realm;
            if (realm is null)
            {
                client.Reconnect(new Reconnect()
                {
                    Host = "",
                    Port = 2050,
                    GameId = World.Realm,
                    Name = "Realm",
                });
                return;
            }

            if (!client.Player.TPCooledDown())
            {
                client.Player.SendError("Teleport in cooldown");
                return;
            }
            
            var rand = new Random();
            var sPoints = realm.GetSpawnPoints();
            var pos = sPoints[rand.Next(sPoints.Length)].Key;
            client.Player.TeleportPosition(time, pos.X + 0.5f, pos.Y + 0.5f, removeNegative: true);
            client.Player.SendInfo("Teleporting to spawn...");
        }
    }
}