using System;
using System.Xml.Linq;
using wServer.realm;
using wServer.realm.entities;

namespace wServer.logic.behaviors
{
    class Suicide : Behavior
    {
        //State storage: timer

        public Suicide()
        {
        }
        
        public Suicide(XElement e)
        {
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            if (!(host is Enemy))
                throw new NotSupportedException("Use Decay instead");
            (host as Enemy).Death(time);
        }
    }
}
