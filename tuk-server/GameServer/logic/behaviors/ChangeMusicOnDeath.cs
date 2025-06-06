﻿using System.Xml.Linq;
using Shared;
using GameServer.networking.packets.outgoing;
using GameServer.realm;

namespace GameServer.logic.behaviors
{
    class ChangeMusicOnDeath : Behavior
    {
        private readonly string _music;
        
        public ChangeMusicOnDeath(XElement e)
        {
            _music = e.ParseString("@song");
        }

        public ChangeMusicOnDeath(string file)
        {
            _music = file;
        }

        protected internal override void Resolve(State parent)
        {
            parent.Death += (sender, e) =>
            {
                if (e.Host.Owner.Music != _music)
                {
                    var owner = e.Host.Owner;

                    owner.Music = _music;

                    var i = 0;
                    foreach (var plr in owner.Players.Values)
                    {
                        owner.Timers.Add(new WorldTimer(100 * i, (w, t) =>
                        {
                            if (plr == null)
                                return;

                            plr.Client.SendPacket(new SwitchMusic()
                            {
                                Music = _music
                            });
                        }));
                        i++;
                    }
                }
            };
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
        }
    }
}