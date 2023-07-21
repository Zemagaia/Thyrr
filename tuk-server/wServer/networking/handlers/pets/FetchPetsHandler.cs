﻿using System;
using common;
using common.resources;
using Newtonsoft.Json;
using wServer.networking.packets;
using wServer.networking.packets.incoming.pets;
using wServer.networking.packets.outgoing.pets;

namespace wServer.networking.handlers.pets
{
    class FetchPetsHandler : PacketHandlerBase<FetchPets>
    {
        public override PacketId ID => PacketId.FETCH_PETS;

        protected override void HandlePacket(Client client, FetchPets packet)
        {
            client.Manager.Logic.AddPendingAction(_ => { Handle(client); });
        }

        private void Handle(Client client)
        {
            if (client.Player == null || IsTest(client))
            {
                return;
            }

            if (client.Account.PetDatas.Length == 0)
            {
                client.SendPacket(new FetchPetsResult
                {
                    PetDatas = new PetData[0],
                    Description = $"No pets found"
                });
                return;
            }

            client.SendPacket(new FetchPetsResult
            {
                PetDatas = client.Account.PetDatas,
                Description = ""
            });
        }
    }
}