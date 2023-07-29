using System;
using System.Threading;
using Shared;
using Shared.resources;
using GameServer.networking.server;
using GameServer.realm;
using GameServer.networking;
using System.Globalization;
using NLog;
using NLog.Config;
using System.IO;
using System.Threading.Tasks;

namespace GameServer
{
    static class Program
    {
        internal static ServerConfig Config;
        internal static Resources Resources;

        static readonly Logger Log = LogUtil.GetLogger("GameServer");

        private static readonly ManualResetEvent Shutdown = new(false);

        static void Main(string[] args)
        {
            AppDomain.CurrentDomain.UnhandledException += LogUnhandledException;

            Thread.CurrentThread.CurrentCulture = CultureInfo.InvariantCulture;
            Thread.CurrentThread.Name = "Entry";

            Config = args.Length > 0 ? ServerConfig.ReadFile(args[0]) : ServerConfig.ReadFile("GameServer.json");
            
            var config = "release";
#if DEBUG
            config = "debug";
#endif
            LogManager.Configuration.Variables["logDirectory"] = (args.Length != 0 ? args[0] + "/" : "") + Config.serverSettings.logFolder + "/gameserver";
            LogManager.Configuration.Variables["buildConfig"] = config;

            Config.serverInfo.maxPlayers = Config.serverSettings.maxPlayers;

            using (Resources = new Resources(Config.serverSettings.resourceFolder, true))
            using (var db = new Database(
                Config.dbInfo.host,
                Config.dbInfo.port,
                Config.dbInfo.auth,
                Config.dbInfo.index,
                Resources))
            {
                var marketSweeper = new MarketSweeper(db);
                marketSweeper.Run();

                var manager = new RealmManager(Resources, db, Config);
                manager.Run();

                var policy = new PolicyServer();
                policy.Start();

                var server = new Server(manager,
                    Config.serverInfo.port,
                    Config.serverSettings.maxConnections,
                    StringUtils.StringToByteArray(Config.serverSettings.key));
                server.Start();

                Console.CancelKeyPress += delegate { Shutdown.Set(); };

                Shutdown.WaitOne();

                Log.Info("Terminating...");
                manager.Stop();
                server.Stop();
                policy.Stop();
                Log.Info("Server terminated.");
            }
        }

        public static void Stop(Task task = null)
        {
            if (task != null)
                Log.Fatal(task.Exception);

            Shutdown.Set();
        }

        private static void LogUnhandledException(object sender, UnhandledExceptionEventArgs args)
        {
            Log.Fatal((Exception)args.ExceptionObject);
        }
    }
}