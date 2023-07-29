﻿using System.Threading.Tasks;
using Shared;
using GameServer.realm.worlds.logic;

namespace GameServer.realm.entities.vendors
{
    class ClosedVaultChest : SellableObject
    {
        public ClosedVaultChest(RealmManager manager, ushort objType) : base(manager, objType)
        {
            Price = 100;
            Currency = CurrencyType.Fame;
        }

        public override void Buy(Player player)
        {
            var result = ValidateCustomer(player);
            if (result != BuyResult.Ok)
            {
                SendFailed(player, result);
                return;
            }

            var db = Manager.Database;
            var acc = player.Client.Account;

            var trans = db.Conn.CreateTransaction();
            Manager.Database.CreateChest(acc, trans);
            var t1 = db.UpdateCurrency(acc, -Price, Currency, trans);
            var t2 = trans.ExecuteAsync();
            Task.WhenAll(t1, t2).ContinueWith(t =>
            {
                if (t.IsCanceled)
                {
                    SendFailed(player, BuyResult.TransactionFailed);
                    return;
                }

                acc.Reload("vaultCount");
                player.CurrentFame = acc.Fame;

                player.Client.SendPacket(new networking.packets.outgoing.BuyResult()
                {
                    Result = 0,
                    ResultString = "Vault chest purchased! Re-enter your vault to reload changes."
                });
            }).ContinueWith(e =>
                    Log.Error(e.Exception.InnerException.ToString()),
                TaskContinuationOptions.OnlyOnFaulted);
        }
    }
}