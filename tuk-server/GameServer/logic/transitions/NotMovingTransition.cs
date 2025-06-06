﻿using System.Xml.Linq;
using Shared;
using Mono.Game;
using GameServer.realm;

namespace GameServer.logic.transitions
{
    class NotMovingTransition : Transition
    {
        //State storage: NotMovingState

        class NotMovingState
        {
            public Vector2 Position;
            public int Delay;
        }

        private readonly int _delay;
        
        public NotMovingTransition(XElement e)
            : base(e.ParseString("@targetState", "root"))
        {
            _delay = e.ParseInt("@delay", 250);
        }

        public NotMovingTransition(string targetState, int delay = 250)
            : base(targetState)
        {
            _delay = delay;
        }

        protected override bool TickCore(Entity host, RealmTime time, ref object state)
        {
            if (state == null)
            {
                state = new NotMovingState()
                {
                    Position = new Vector2(host.X, host.Y),
                    Delay = _delay
                };
                return false;
            }

            var s = (NotMovingState)state;
            if (s.Delay <= 0)
            {
                var hostPos = new Vector2(host.X, host.Y);
                if (hostPos == s.Position)
                {
                    state = null;
                    return true;
                }

                s.Position = hostPos;
                s.Delay = _delay;
                return false;
            }

            s.Delay -= time.ElapsedMsDelta;
            return false;
        }
    }
}