﻿using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.IO;
using System.Text;
using System.Xml.Linq;
using common.terrain;
using log4net;
using Newtonsoft.Json;

namespace common.resources
{
    public struct ProtoWorld
    {
        public string name;
        public string sbName;
        public int id;
        public int difficulty;
        public int background;
        public bool isLimbo;
        public bool restrictTp;
        public bool showDisplays;
        public bool persist;
        public int blocking;
        public bool setpiece;
        public int[] portals;
        public string[] maps;
        public string[] music;
        public byte[][] wmap;
        public bool scoutQuestActive;
        public string overseer;
    }

    public class TauntData
    {
        public readonly string Name;
        public readonly string[] EnemyCount;
        public readonly string[] Final;
        public readonly string[] Spawn;
        public readonly string[] Death;

        public TauntData(XElement e)
        {
            XElement n;
            Name = e.ParseString("@name");
            if ((n = e.Element("EnemyCount")) != null)
                EnemyCount = n.Elements("Message").Select(x => x.Value).ToArray();

            if ((n = e.Element("Final")) != null)
                Final = n.Elements("Message").Select(x => x.Value).ToArray();
            
            if ((n = e.Element("Spawn")) != null)
                Spawn = n.Elements("Message").Select(x => x.Value).ToArray();
            
            if ((n = e.Element("Death")) != null)
                Death = n.Elements("Message").Select(x => x.Value).ToArray();
        }
    }

    public class SpawnData
    {
        public readonly TileRegion Region;
        public readonly int Divider;
        public readonly List<SpawnInfo> Spawns;

        public SpawnData(XElement e)
        {
            Region = (TileRegion)Enum.Parse(typeof(TileRegion), e.ParseString("@region").Replace(' ', '_'));
            // can't divide by 0 :D
            Divider = e.ParseInt("@divider", 100);
            Spawns = new List<SpawnInfo>();
            foreach (var i in e.Elements("Spawn"))
                Spawns.Add(new SpawnInfo(i));
        }
    }

    public class SpawnInfo
    {
        public readonly string Name;
        public readonly double Chance;
        public SpawnInfo(XElement e)
        {
            Name = e.ParseString("@id");
            Chance = e.ParseFloat("@chance");
        }
    }

    public class EventData
    {
        public readonly string ObjectId;
        public readonly string Setpiece;

        public EventData(XElement e)
        {
            ObjectId = e.Value;
            Setpiece = e.ParseString("@setpiece");
        }
    }

    public class WorldData
    {
        static readonly ILog Log = LogManager.GetLogger(typeof(WorldData));

        public readonly IList<string> Setpieces;
        public IDictionary<string, ProtoWorld> Data { get; private set; }
        public IDictionary<string, SpawnData[]> SpawnData { get; private set; }
        public IDictionary<string, TauntData[]> TauntData { get; private set; }
        public IDictionary<string, EventData[]> EventData { get; private set; }

        public WorldData(string dir, XmlData gameData)
        {
            Dictionary<string, ProtoWorld> worlds;
            List<string> setpieces;
            Dictionary<string, SpawnData[]> spawns;
            Dictionary<string, TauntData[]> taunts;
            Dictionary<string, EventData[]> events;
            Data = new ReadOnlyDictionary<string, ProtoWorld>(worlds = new Dictionary<string, ProtoWorld>());
            Setpieces = new List<string>(setpieces = new List<string>());
            EventData = new ReadOnlyDictionary<string, EventData[]>(events = new Dictionary<string, EventData[]>());
            SpawnData = new ReadOnlyDictionary<string, SpawnData[]>(spawns = new Dictionary<string, SpawnData[]>());
            TauntData = new ReadOnlyDictionary<string, TauntData[]>(taunts = new Dictionary<string, TauntData[]>());

            var basePath = Path.GetFullPath(dir);
            LoadWorldsAndSetpieces(gameData, basePath, setpieces, worlds);
            // World-by-world basis spawn data & taunt data
            LoadBiomeData(basePath, spawns, taunts, events);
        }

        private void LoadBiomeData(string basePath, Dictionary<string, SpawnData[]> spawnData,
            Dictionary<string, TauntData[]> tauntData, Dictionary<string, EventData[]> events)
        {
            var xmls = Directory.EnumerateFiles(basePath, "*.xml", SearchOption.AllDirectories).ToArray();
            for (var i = 0; i < xmls.Length; i++)
            {
                // I wonder a backslash check works on all OSes, I'll put this just in case...
                var arr = xmls[i].Replace("\\", "/").Split('/');
                var fileName = arr[arr.Length - 1];
                int j;
                var folderName = new StringBuilder();
                var baseIndex = 0;
                // find base worlds folder
                for (j = 0; j < arr.Length; j++)
                    if (arr[j] == "worlds")
                    {
                        baseIndex = j + 1;
                        break;
                    }

                for (j = baseIndex; j < arr.Length - 1; j++)
                {
                    folderName.Append(arr[j]);
                    // folder separation
                    if (arr.Length - j - 1 > 1)
                        folderName.Append(".");
                }

                var node = XElement.Parse(File.ReadAllText(xmls[i]));
                if (fileName == "SpawnData.xml")
                    spawnData[folderName.ToString()] = node.Elements("Biome").Select(x => new SpawnData(x)).ToArray();
                else if (fileName == "TauntData.xml")
                    tauntData[folderName.ToString()] = node.Elements("Taunt").Select(x => new TauntData(x)).ToArray();
                else if (fileName == "EventData.xml")
                    events[folderName.ToString()] = node.Elements("Event").Select(x => new EventData(x)).ToArray();
            }
        }

        private void LoadWorldsAndSetpieces(XmlData gameData, string basePath, List<string> setpieces,
            Dictionary<string, ProtoWorld> worlds)
        {
            var jwFiles = Directory.EnumerateFiles(basePath, "*.jw", SearchOption.AllDirectories).ToArray();
            for (var i = 0; i < jwFiles.Length; i++)
            {
                Log.InfoFormat("Initializing world data: " + Path.GetFileName(jwFiles[i]) + " {0}/{1}...", i + 1,
                    jwFiles.Length);

                var jw = File.ReadAllText(jwFiles[i]);
                var world = JsonConvert.DeserializeObject<ProtoWorld>(jw);

                if (world.setpiece)
                    setpieces.Add(world.name);

                if (world.maps == null)
                {
                    var jm = File.ReadAllText(jwFiles[i].Substring(0, jwFiles[i].Length - 1) + "m");
                    world.wmap = new byte[1][];
                    world.wmap[0] = Json2Wmap.Convert(gameData, jm);
                    worlds.Add(world.name, world);
                    continue;
                }

                world.wmap = new byte[world.maps.Length][];
                var di = Directory.GetParent(jwFiles[i]);
                for (var j = 0; j < world.maps.Length; j++)
                {
                    var mapFile = Path.Combine(di.FullName, world.maps[j]);
                    if (world.maps[j].EndsWith(".wmap"))
                    {
                        world.wmap[j] = File.ReadAllBytes(mapFile);
                        continue;
                    }

                    var jm = File.ReadAllText(mapFile);
                    world.wmap[j] = Json2Wmap.Convert(gameData, jm);
                }

                worlds.Add(world.name, world);
            }
        }

        public ProtoWorld this[string name] => Data[name];
    }
}