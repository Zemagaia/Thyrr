using common;
using common.resources;
using Newtonsoft.Json;
using wServer.networking.packets;
using wServer.networking.packets.incoming.quests;
using wServer.networking.packets.outgoing.quests;
using wServer.realm.worlds;

namespace wServer.networking.handlers.quests
{
    class FetchCharacterQuestsHandler : PacketHandlerBase<FetchCharacterQuests>
    {
        public override PacketId ID => PacketId.FETCH_CHARACTER_QUESTS;

        protected override void HandlePacket(Client client, FetchCharacterQuests packet)
        {
            client.Manager.Logic.AddPendingAction(t =>
            {
                var player = client.Player;
                if (player == null || IsTest(client))
                {
                    return;
                }

                var quests = player.CharacterQuests;
                // no quests or world is not quest world (useless?... but this is only for fetching, why would you need it?)
                // quest world is nexus for now.. remember to change!
                if (quests != null && quests.Length == 0 || player.Owner.Id != World.Tinker && player.Rank < 100)
                {
                    client.SendPacket(new FetchCharacterQuestsResult
                    {
                        Results = new AcceptedQuestData[0],
                        Description = $"You do not have any character quests"
                    });
                    return;
                }

                client.SendPacket(new FetchCharacterQuestsResult
                {
                    Results = quests,
                    Description = ""
                });
            });
        }
    }
}