﻿using System;
using System.Collections.Generic;
using System.Linq;
using Shared;
using Shared.resources;
using Newtonsoft.Json;
using GameServer.networking.packets.outgoing;
using GameServer.realm.worlds.logic;

namespace GameServer.realm.entities
{
    partial class Player
    {
        internal Dictionary<Player, int> potentialTrader = new();
        internal Player tradeTarget;
        internal bool[] trade;
        internal bool tradeAccepted;

        public void RequestTrade(string name)
        {
            if (Owner is Test)
                return;

            Manager.Database.ReloadAccount(_client.Account);
            var acc = _client.Account;

            if (!acc.NameChosen)
            {
                SendError("A unique name is required before trading with others!");
                return;
            }

            if (tradeTarget != null)
            {
                SendError("Already trading!");
                return;
            }

            if (Database.GuestNames.Contains(name))
            {
                SendError(name + " needs to choose a unique name first!");
                return;
            }

            var target = Owner.GetUniqueNamedPlayer(name);
            if (target == null || !target.CanBeSeenBy(this))
            {
                SendError(name + " not found!");
                return;
            }

            if (target == this)
            {
                SendError("You can't trade with yourself!");
                return;
            }

            if (target._client.Account.IgnoreList.Contains(AccountId))
                return; // account is ignored

            if (target.tradeTarget != null)
            {
                SendError(target.Name + " is already trading!");
                return;
            }

            if (potentialTrader.ContainsKey(target))
            {
                tradeTarget = target;
                trade = new bool[12];
                tradeAccepted = false;
                target.tradeTarget = this;
                target.trade = new bool[12];
                target.tradeAccepted = false;
                potentialTrader.Clear();
                target.potentialTrader.Clear();

                // shouldn't be needed since there is checks on
                // invswap, invdrop, and useitem packets for trading
                //MonitorTrade();
                //target.MonitorTrade();

                var my = new TradeItem[12];
                for (int i = 0; i < 12; i++)
                    my[i] = new TradeItem()
                    {
                        ItemData = Inventory[i],
                        SlotType = SlotTypes[i],
                        Included = false,
                        Tradeable = Inventory[i].Item != null && i >= 4 && !Inventory[i].Item.Soulbound &&
                                    !Inventory[i].Soulbound
                    };
                var your = new TradeItem[12];
                for (int i = 0; i < 12; i++)
                    your[i] = new TradeItem()
                    {
                        ItemData = target.Inventory[i],
                        SlotType = target.SlotTypes[i],
                        Included = false,
                        Tradeable = target.Inventory[i].Item != null && i >= 4 && !target.Inventory[i].Item.Soulbound &&
                                    !target.Inventory[i].Soulbound
                    };

                _client.SendPacket(new TradeStart()
                {
                    MyItems = my,
                    YourName = target.Name,
                    YourItems = your
                });
                target._client.SendPacket(new TradeStart()
                {
                    MyItems = your,
                    YourName = Name,
                    YourItems = my
                });
            }
            else
            {
                target.potentialTrader[this] = 1000 * 20;
                target._client.SendPacket(new TradeRequested()
                {
                    Name = Name
                });
                SendInfo("You have sent a trade request to " + target.Name + "!");
                return;
            }
        }

        public void CancelTrade()
        {
            _client.SendPacket(new TradeDone()
            {
                Code = 1,
                Description = "Trade canceled!"
            });

            if (tradeTarget != null && tradeTarget._client != null)
                tradeTarget._client.SendPacket(new TradeDone()
                {
                    Code = 1,
                    Description = "Trade canceled!"
                });

            ResetTrade();
        }

        public void ResetTrade()
        {
            if (tradeTarget != null)
            {
                tradeTarget.tradeTarget = null;
                tradeTarget.trade = null;
                tradeTarget.tradeAccepted = false;
            }

            tradeTarget = null;
            trade = null;
            tradeAccepted = false;
        }

        void CheckTradeTimeout(RealmTime time)
        {
            List<Tuple<Player, int>> newState = new List<Tuple<Player, int>>();
            foreach (var i in potentialTrader)
                newState.Add(new Tuple<Player, int>(i.Key, i.Value - time.ElapsedMsDelta));

            foreach (var i in newState)
            {
                if (i.Item2 < 0)
                {
                    i.Item1.SendInfo("Trade to " + Name + " has timed out!");
                    potentialTrader.Remove(i.Item1);
                }
                else potentialTrader[i.Item1] = i.Item2;
            }
        }
    }
}