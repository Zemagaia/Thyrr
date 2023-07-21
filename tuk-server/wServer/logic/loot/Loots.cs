using common.resources;
using System;
using System.Collections.Generic;
using System.Linq;
using common;
using log4net;
using wServer.networking.packets.outgoing;
using wServer.realm;
using wServer.realm.entities;
using wServer.realm.worlds.logic;

namespace wServer.logic.loot
{
    public struct LootDef
    {
        public LootDef(ItemData item, double probability)
        {
            Probability = probability;
            Item = item;
        }

        public readonly ItemData Item;
        public readonly double Probability;
    }

    public class Loot : List<ILootDef>
    {
        private static readonly ILog Log = LogManager.GetLogger(typeof(Loot));

        public Loot(params ILootDef[] lootDefs)
        {
            //For independent loots(e.g. chests)
            AddRange(lootDefs);
        }

        private static readonly Random Rand = new();

        public IEnumerable<ItemData> GetLoots(RealmManager manager, int min, int max)
        {
            //For independent loots(e.g. chests)
            var consideration = new List<LootDef>();
            foreach (var i in this)
                i.Populate(manager, null, null, Rand, consideration);

            var retCount = Rand.Next(min, max);
            foreach (var i in consideration)
            {
                if (Rand.NextDouble() < i.Probability)
                {
                    yield return i.Item;
                    retCount--;
                }

                if (retCount == 0)
                    yield break;
            }
        }

        public static readonly ushort BrownBag = 0x0407;
        public static readonly ushort BlackBag = 0x0408;
        private static readonly ushort EggBasket = 0x0409;
        private static readonly ushort BlueBag = 0x040A;
        private static readonly ushort GreyBag = 0x040B;
        private static readonly ushort GoldenBag = 0x040C;
        private static readonly ushort RedBag = 0x040D;
        private static readonly ushort PinkBag = 0x040E;
        private static readonly ushort CyanBag = 0x040F;

        public void Handle(Enemy enemy)
        {
            if (enemy.Spawned)
            {
                return;
            }

            var consideration = new List<LootDef>();

            var shared = new List<ItemData>();
            foreach (var i in this)
                i.Populate(enemy.Manager, enemy, null, Rand, consideration);

            var dats = enemy.DamageCounter.GetPlayerData();
            var loots = enemy.DamageCounter.GetPlayerData().ToDictionary(
                d => d.Item1, _ => (IList<ItemData>)new List<ItemData>());

            foreach (var i in consideration)
                if (Rand.NextDouble() < i.Probability)
                    shared.Add(GetItemData(i, null));

            foreach (var loot in shared.Where(item => item.Item.Soulbound))
                loots[dats[Rand.Next(dats.Length)].Item1].Add(loot);

            foreach (var dat in dats)
            {
                consideration.Clear();
                foreach (var i in this)
                {
                    i.Populate(enemy.Manager, enemy, dat, Rand, consideration);
                }

                var lootDropBoost = dat.Item1.LDBoostTime > 0 ? 1.5 : 1;
                var luckStatBoost = 1 + dat.Item1.Stats[10] / 100.0;

                var globalLBoost = DateTime.UtcNow.ToUnixTimestamp() < Constants.EventEnds.ToUnixTimestamp()
                    ? Constants.GlobalLootBoost ?? 1
                    : 1;

                var playerLoot = loots[dat.Item1];
                foreach (var i in consideration)
                    if (Rand.NextDouble() < i.Probability * lootDropBoost * luckStatBoost * globalLBoost)
                        playerLoot.Add(GetItemData(i, dat));
            }

            AddBagsToWorld(enemy, shared, loots);
        }

        private ItemData GetItemData(LootDef i, Tuple<Player, int> dat)
        {
            // public loot
            i.Item.ObjectType = i.Item.ObjectType;
            i.Item.UIID = ItemData.MakeUIID(i.Item.ObjectType);
            // private loot since owner is not null
            /*if (dat is not null && dat.Item1 is not null)
            {
            }*/

            if (i.Item.Item.SlotType != 10 && i.Item.Item.SlotType != 26)
            {
                var quality = ItemData.MakeQuality(i.Item.Item);
                i.Item.Quality = quality;
                i.Item.Runes = ItemData.GetRuneSlots(quality);
            }

            return i.Item;
        }

        private static void AddBagsToWorld(Enemy enemy, IList<ItemData> shared, IDictionary<Player, IList<ItemData>> loots)
        {
            var pub = new List<Player>(); //only people not getting soulbound
            foreach (var i in loots)
            {
                if (i.Value.Count > 0)
                {
                    ShowBags(enemy, i.Value, i.Key);
                    continue;
                }

                pub.Add(i.Key);
            }

            if (pub.Count > 0 && shared.Count > 0)
                ShowBags(enemy, shared, pub.ToArray());
        }

        private static void ShowBags(Enemy enemy, IEnumerable<ItemData> loots, params Player[] owners)
        {
            var ownerIds = owners.Select(x => x.AccountId).ToArray();
            var bagType = 0;
            var items = new ItemData[8];
            var idx = 0;
            var highest = 0;

            foreach (var i in loots)
            {
                if (i.Item.BagType > bagType)
                {
                    bagType = i.Item.BagType;
                }

                if (i.Item.BagType > highest)
                {
                    highest = i.Item.BagType;
                }

                items[idx] = i;
                idx++;
                if (idx == 8)
                {
                    ShowBag(enemy, ownerIds, bagType, items);

                    bagType = 0;
                    items = new ItemData[8];
                    idx = 0;
                }
            }

            var player = owners[0];
            switch (highest)
            {
                case 5:
                    player.Client.SendPacket(new GlobalNotification()
                    {
                        Text = "legendaryLoot"
                    });
                    break;
                case 6:
                    player.Client.SendPacket(new GlobalNotification()
                    {
                        Text = "mythicLoot"
                    });
                    break;
                case 7:
                    player.Client.SendPacket(new GlobalNotification()
                    {
                        Text = "unholyLoot"
                    });
                    break;
                case 8:
                    player.Client.SendPacket(new GlobalNotification()
                    {
                        Text = "divineLoot"
                    });
                    break;
            }

            if (idx > 0)
                ShowBag(enemy, ownerIds, bagType, items);
        }

        private static void ShowBag(Enemy enemy, int[] owners, int bagType, ItemData[] items)
        {
            var bag = BrownBag;
            switch (bagType)
            {
                case 0:
                    bag = BrownBag;
                    break;
                case 1:
                    bag = BlackBag;
                    break;
                case 2:
                    bag = EggBasket;
                    break;
                case 3:
                    bag = BlueBag;
                    break;
                case 4:
                    bag = GreyBag;
                    break;
                case 5:
                    bag = GoldenBag;
                    break;
                case 6:
                    bag = RedBag;
                    break;
                case 7:
                    bag = PinkBag;
                    break;
                case 8:
                    bag = CyanBag;
                    break;
            }

            var container = new Container(enemy.Manager, bag, 1000 * 60, true);
            for (var j = 0; j < 8; j++)
            {
                container.Inventory[j] = items[j] ?? new ItemData();
            }

            container.BagOwners = bagType >= 1 ? owners : new int[0];
            container.Move(
                enemy.X + (float)((Rand.NextDouble() * 2 - 1) * 0.5),
                enemy.Y + (float)((Rand.NextDouble() * 2 - 1) * 0.5));
            container.SetDefaultSize(bagType > 3 ? 110 : 80);
            enemy.Owner.EnterWorld(container);
            container.AlwaysTick = true;
        }
    }
}