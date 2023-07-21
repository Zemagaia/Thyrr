﻿using System.Xml.Linq;
using common;
using wServer.realm;
using wServer.realm.setpieces;

namespace wServer.logic.behaviors
{
    public class ApplySetpiece : Behavior
    {
        private readonly string name;
        
        public ApplySetpiece(XElement e)
        {
            name = e.ParseString("@name");
        }

        public ApplySetpiece(string name)
        {
            this.name = name;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            try
            {
                SetPieces.RenderFromProto(host.Owner, new IntPoint((int)host.X, (int)host.Y), host.Manager.Resources.Worlds[name]);
            }
            catch { }
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state) { }
    }
}
