﻿using GameServer.realm;
using GameServer.realm.entities;
using GameServer.networking.packets;
using GameServer.networking.packets.incoming;

namespace GameServer.networking.handlers
{
    public class PlayerMessage
    {
        public Player Player { get; private set; }
        public string Message { get; private set; }
        public long Time { get; private set; }

        public PlayerMessage(Player player, RealmTime time, string msg)
        {
            Player = player;
            Message = msg;
            Time = time.TotalElapsedMs;
        }
    }

    class PlayerTextHandler : PacketHandlerBase<PlayerText>
    {
        public override PacketId ID => PacketId.PLAYERTEXT;

        protected override void HandlePacket(Client client, PlayerText packet)
        {
            client.Manager.Logic.AddPendingAction(t => Handle(client.Player, t, packet.Text));
        }

        void Handle(Player player, RealmTime time, string text)
        {
            if (player?.Owner == null || text.Length > 128)
                return;

            var manager = player.Manager;

            // check for commands before other checks
            if (text[0] == '/')
            {
                manager.Commands.Execute(player, time, text);
                return;
            }

            if (!player.NameChosen)
            {
                player.SendError("Please choose a name before chatting.");
                return;
            }

            if (player.Muted)
            {
                player.SendError("Muted. You can not talk at this time.");
                return;
            }

            if (player.CompareAndCheckSpam(text, time.TotalElapsedMs))
            {
                return;
            }

            // save message for mob behaviors
            player.Owner.ChatReceived(player, text);

            manager.Chat.Say(player, text);
        }
    }
}