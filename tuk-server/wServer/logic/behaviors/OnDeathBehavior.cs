using System.Xml.Linq;
using wServer.realm;

namespace wServer.logic.behaviors
{
    public class OnDeathBehavior : Behavior
    {
        private readonly Behavior behavior;

        public OnDeathBehavior(XElement e, IStateChildren[] children)
        {
            foreach (var child in children)
            {
                if (child is Behavior bh)
                {
                    behavior = bh;
                    break;
                }
            }
        }
        
        public OnDeathBehavior(Behavior behavior)
        {
            this.behavior = behavior;
        }

        protected internal override void Resolve(State parent)
        {
            parent.Death += (s, e) =>
            {
                behavior.OnStateEntry(e.Host, e.Time);
            };
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
        }
    }
}