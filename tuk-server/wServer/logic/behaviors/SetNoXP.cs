using System.Xml.Linq;
using wServer.realm;

namespace wServer.logic.behaviors
{
    class SetNoXp : Behavior
    {
        //State storage: nothing
        
        public SetNoXp(XElement e)
        {
        }
        
        public SetNoXp()
        {
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            host.GivesNoXp = true;
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
        }
    }
}