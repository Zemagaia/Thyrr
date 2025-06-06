﻿using GameServer.realm.entities;
using GameServer.networking.packets;
using GameServer.networking.packets.incoming;
using GameServer.networking.packets.outgoing;
using GameServer.realm;
using GameServer.realm.worlds.logic;

namespace GameServer.networking.handlers
{
    class LoadHandler : PacketHandlerBase<Load>
    {
        public override PacketId ID => PacketId.LOAD;

        protected override void HandlePacket(Client client, Load packet)
        {
            //client.Manager.Logic.AddPendingAction(t => Handle(client, packet));
            Handle(client, packet);
        }

        private void Handle(Client client, Load packet)
        {
            if (client.State != ProtocolState.Handshaked)
                return;

            client.Character = client.Manager.Database
                .LoadCharacter(client.Account, packet.CharId);
            if (client.Character != null)
            {
                if (client.Character.Dead)
                {
                    client.SendFailure("Character is dead",
                        Failure.MessageWithDisconnect);
                }
                else
                {
                    var target = client.Manager.Worlds[client.TargetWorld];

                    client.Player = target is Test ? new Player(client, false) : new Player(client);

                    client.SendPacket(new CreateSuccess()
                    {
                        CharId = client.Character.CharId,
                        ObjectId = target.EnterWorld(client.Player)
                    });

                    client.State = ProtocolState.Ready;
                    client.Manager.ConMan.ClientConnected(client);
                }
            }
            else
            {
                client.SendFailure("Failed to load character",
                    Failure.MessageWithDisconnect);
            }
        }
    }
}