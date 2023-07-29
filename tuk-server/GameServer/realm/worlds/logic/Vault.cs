﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Shared;
using Shared.resources;
using Shared.terrain;
using GameServer.networking;
using GameServer.networking.packets.outgoing;
using GameServer.realm.entities;
using GameServer.realm.entities.vendors;

namespace GameServer.realm.worlds.logic
{
    public class Vault : World
    {
        public int AccountId { get; private set; }

        private readonly Client _client;

        private LinkedList<Container> vaults;

        public Vault(ProtoWorld proto, Client client = null) : base(proto)
        {
            if (client != null)
            {
                _client = client;
                AccountId = _client.Account.AccountId;
                ExtraXML = ExtraXML.Concat(new[]
                {
                    @"	<Objects>
		                    <Object type=""0x0403"" id=""Vault Chest"">
			                    <Class>Container</Class>
			                    <Container/>
			                    <CanPutNormalObjects/>
			                    <CanPutSoulboundObjects/>
			                    <ShowName/>
			                    <Texture><File>utility</File><Index>0x06</Index></Texture>
			                    <SlotTypes>0, 0, 0, 0, 0, 0, 0, 0</SlotTypes>
		                    </Object>
	                    </Objects>"
                }).ToArray();
                vaults = new LinkedList<Container>();
            }
        }

        public override bool AllowedAccess(Client client)
        {
            return base.AllowedAccess(client) && AccountId == client.Account.AccountId;
        }

        protected override void Init()
        {
            if (IsLimbo)
                return;

            FromWorldMap(new MemoryStream(Manager.Resources.Worlds[Name].wmap[0]));
            InitVault();
            InitShops();
        }

        void InitVault()
        {
            var vaultChestPosition = new List<IntPoint>();
            var giftChestPosition = new List<IntPoint>();
            var spawn = new IntPoint(0, 0);

            var w = Map.Width;
            var h = Map.Height;

            for (var y = 0; y < h; y++)
            for (var x = 0; x < w; x++)
            {
                var tile = Map[x, y];
                switch (tile.Region)
                {
                    case TileRegion.Spawn:
                        spawn = new IntPoint(x, y);
                        break;
                    case TileRegion.Vault:
                        vaultChestPosition.Add(new IntPoint(x, y));
                        break;
                    case TileRegion.Gifting_Chest:
                        giftChestPosition.Add(new IntPoint(x, y));
                        break;
                }
            }

            vaultChestPosition.Sort((x, y) => Comparer<int>.Default.Compare(
                (x.X - spawn.X) * (x.X - spawn.X) + (x.Y - spawn.Y) * (x.Y - spawn.Y),
                (y.X - spawn.X) * (y.X - spawn.X) + (y.Y - spawn.Y) * (y.Y - spawn.Y)));

            giftChestPosition.Sort((x, y) => Comparer<int>.Default.Compare(
                (x.X - spawn.X) * (x.X - spawn.X) + (x.Y - spawn.Y) * (x.Y - spawn.Y),
                (y.X - spawn.X) * (y.X - spawn.X) + (y.Y - spawn.Y) * (y.Y - spawn.Y)));

            Container con;
            for (var i = 0; i < _client.Account.VaultCount && vaultChestPosition.Count > 0; i++)
            {
                var vaultChest = new DbVaultSingle(_client.Account, i);
                con = new Container(_client.Manager, 0x0403, null, false, vaultChest);
                con.BagOwners = new int[] { _client.Account.AccountId };
                con.Inventory.SetItems(vaultChest.Items);
                con.Inventory.InventoryChanged += (sender, e) => SaveChest(((Inventory)sender).Parent);
                con.Move(vaultChestPosition[0].X + 0.5f, vaultChestPosition[0].Y + 0.5f);
                EnterWorld(con);
                vaultChestPosition.RemoveAt(0);
                vaults.AddFirst(con);
            }

            foreach (var i in vaultChestPosition)
            {
                var x = new ClosedVaultChest(_client.Manager, 0x0404);
                x.Move(i.X + 0.5f, i.Y + 0.5f);
                EnterWorld(x);
            }

            foreach (var i in _client.Account.ActiveGiftChests)
            {
                var giftChest = new DbGiftSingle(_client.Account, i);
                con = new GiftChest(_client.Manager, 0x0405, null, false, giftChest);
                (con as GiftChest).AssignedGiftId = i;
                con.BagOwners = new [] { _client.Account.AccountId };
                con.Inventory.SetItems(giftChest.Items);
                con.Inventory.InventoryChanged += (sender, e) => SaveChest(((Inventory)sender).Parent);
                con.Move(giftChestPosition[0].X + 0.5f, giftChestPosition[0].Y + 0.5f);
                EnterWorld(con);
                giftChestPosition.RemoveAt(0);
            }

            foreach (var i in giftChestPosition)
            {
                var x = new StaticObject(_client.Manager, 0x0406, null, true, false, false);
                x.Move(i.X + 0.5f, i.Y + 0.5f);
                EnterWorld(x);
            }

            // lol
            // devon roach
            if (_client.Account.Name.Equals("Devon"))
            {
                var e = new Enemy(Manager, 0x12C);
                e.Move(38, 68);
                EnterWorld(e);
            }
        }

        public override void Tick(RealmTime time)
        {
            if (vaults != null && vaults.Count > 0)
            {
                foreach (var vault in vaults)
                {
                    if (vault?.Inventory == null) continue;
                    var items = vault.Inventory.Count(i => i.ObjectType != ushort.MaxValue) + "/8";
                    if (!items.Equals(vault.Name))
                        vault.Name = items;
                }
            }

            base.Tick(time);
        }

        private void SaveChest(IContainer chest)
        {
            var dbLink = chest?.DbLink;
            if (dbLink == null)
                return;

            dbLink.Items = chest.Inventory.GetItems();
            dbLink.FlushAsync();
        }

        public override void LeaveWorld(Entity entity)
        {
            base.LeaveWorld(entity);

            if (entity.ObjectType != 0x0405)
                return;

            if (entity is GiftChest gift)
            {
                var active = _client.Account.ActiveGiftChests;
                active.Remove(gift.AssignedGiftId);
                _client.Account.ActiveGiftChests = active;
            }
            
            var x = new StaticObject(_client.Manager, 0x0406, null, true, false, false);
            x.Move(entity.X, entity.Y);
            EnterWorld(x);

            if (_client.Account.ActiveGiftChests.Count <= 0)
                _client.SendPacket(new GlobalNotification
                {
                    Text = "giftChestEmpty"
                });
        }
    }
}