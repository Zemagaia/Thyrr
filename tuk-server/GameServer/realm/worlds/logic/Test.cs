﻿using System.IO;
using Shared.resources;
using Shared.terrain;

namespace GameServer.realm.worlds.logic
{
    public class Test : World
    {
        private static ProtoWorld _testProto = new()
        {
            name = "Test World",
            sbName = "Test World",
            id = 0,
            setpiece = false,
            showDisplays = false,
            background = 0,
            blocking = 0,
            difficulty = 0,
            isLimbo = false,
            maps = Empty<string>.Array,
            persist = false,
            portals = Empty<int>.Array,
            restrictTp = false,
            wmap = Empty<byte[]>.Array,
            // to-do: add test music
            music = new[] { "Test" }
        };

        public bool JsonLoaded { get; private set; }

        public Test() : base(_testProto)
        {
        }

        protected override void Init()
        {
        }

        public void LoadJson(string json)
        {
            if (!JsonLoaded)
            {
                FromWorldMap(new MemoryStream(Json2Wmap.Convert(Manager.Resources.GameData, json)));
                JsonLoaded = true;
            }

            InitShops();
        }
    }
}