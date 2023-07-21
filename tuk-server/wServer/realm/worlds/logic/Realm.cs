using System;
using System.IO;
using System.Threading.Tasks;
using common.resources;
using log4net;
using wServer.networking;
using wServer.realm.entities;
using wServer.realm.setpieces;

namespace wServer.realm.worlds.logic
{
    public class Realm : World
    {
        static readonly ILog Log = LogManager.GetLogger(typeof(Realm));

        private readonly bool _oryxPresent;

        public Realm(ProtoWorld proto, Client client = null) : base(proto)
        {
            _oryxPresent = true;
        }

        private long _last = 10;

        protected override void Init()
        {
            Log.InfoFormat("Initializing Game World {0}({1}) from map...", Id, Name);

            FromWorldMap(new MemoryStream(Manager.Resources.Worlds["Realm"].wmap[0]));
            SetPieces.ApplySetPieces(this);
            
            Log.Info("Game World initalized.");
        }

        public override void Tick(RealmTime time)
        {
            var secondsElapsed = time.TotalElapsedMs / 1000;
            if (secondsElapsed % 1800 == 0 && _last < secondsElapsed)
            {
                Log.Info("Doing automatic Garbage Collection (30 minutes)");
                GC.Collect(); // collect
                _last = secondsElapsed;
            }

            base.Tick(time);
        }
    }
}