using System.Timers;
using Shared;
using Timer = System.Timers.Timer;

namespace AppEngine
{
    public class LegendSweeper
    {
        private readonly Timer _tmr = new(60000);
        private readonly Database _db;

        public LegendSweeper(Database db)
        {
            _db = db;
        }

        public void Run()
        {
            _tmr.Elapsed += (sender, e) => _db.CleanLegends();
            _tmr.Start();
        }
    }
}