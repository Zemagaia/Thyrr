﻿using System.Xml.Linq;
using Shared;
using GameServer.realm;

namespace GameServer.logic.behaviors
{
    class MutePlayer : Behavior
    {
        private readonly int _timeout; 

        public MutePlayer(XElement e)
        {
            _timeout = e.ParseInt("@durationMin");
        }
        
        public MutePlayer(int durationMin = 0)
        {
            _timeout = durationMin;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            if (host.AttackTarget?.Owner == null || host.AttackTarget.Muted)
                return;

            var muteCmd = host.Manager.Commands.Commands["mute"];
            muteCmd.Execute(null, time, $"{muteCmd.CommandName}", $"{host.AttackTarget.Name} {_timeout}", true);
        }
        
        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
        }
    }
}