using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using common.resources;
using common.terrain;
using log4net;
using wServer.realm.worlds;

namespace wServer.realm.setpieces
{
    class SetPieces
    {
        static ILog log = LogManager.GetLogger(typeof(SetPieces));

        struct Rect
        {
            public int x;
            public int y;
            public int w;
            public int h;

            public static bool Intersects(Rect r1, Rect r2)
            {
                return !(r2.x > r1.x + r1.w ||
                         r2.x + r2.w < r1.x ||
                         r2.y > r1.y + r1.h ||
                         r2.y + r2.h < r1.y);
            }
        }

        static Tuple<ISetPiece, int, int, TileRegion[]> SetPiece(ISetPiece piece, int min, int max,
            params TileRegion[] regions)
        {
            return Tuple.Create(piece, min, max, regions);
        }

        private static readonly List<Tuple<ISetPiece, int, int, TileRegion[]>> setPieces =
            new()
            {
                //SetPiece(new Building(), 80, 100, TileRegion.Biome_Valley),
            };

        public static int[,] rotateCW(int[,] mat)
        {
            var M = mat.GetLength(0);
            var N = mat.GetLength(1);
            var ret = new int[N, M];
            for (var r = 0; r < M; r++)
            {
                for (var c = 0; c < N; c++)
                {
                    ret[c, M - 1 - r] = mat[r, c];
                }
            }

            return ret;
        }

        public static int[,] reflectVert(int[,] mat)
        {
            var M = mat.GetLength(0);
            var N = mat.GetLength(1);
            var ret = new int[M, N];
            for (var x = 0; x < M; x++)
            for (var y = 0; y < N; y++)
                ret[x, N - y - 1] = mat[x, y];
            return ret;
        }

        public static int[,] reflectHori(int[,] mat)
        {
            var M = mat.GetLength(0);
            var N = mat.GetLength(1);
            var ret = new int[M, N];
            for (var x = 0; x < M; x++)
            for (var y = 0; y < N; y++)
                ret[M - x - 1, y] = mat[x, y];
            return ret;
        }

        private static int DistSqr(IntPoint a, IntPoint b)
        {
            return (a.X - b.X) * (a.X - b.X) + (a.Y - b.Y) * (a.Y - b.Y);
        }

        public static void ApplySetPieces(World world)
        {
            log.InfoFormat("Applying set pieces to world {0}({1}).", world.Id, world.Name);

            var map = world.Map;
            int w = map.Width, h = map.Height;

            var rand = new Random();
            var rects = new HashSet<Rect>();
            foreach (var dat in setPieces)
            {
                var size = dat.Item1.Size;
                var count = rand.Next(dat.Item2, dat.Item3);
                for (var i = 0; i < count; i++)
                {
                    var pt = new IntPoint();
                    Rect rect;

                    var max = 50;
                    do
                    {
                        pt.X = rand.Next(0, w);
                        pt.Y = rand.Next(0, h);
                        rect = new Rect() { x = pt.X, y = pt.Y, w = size, h = size };
                        max--;
                    } while ((Array.IndexOf(dat.Item4, map[pt.X, pt.Y].Region) == -1 ||
                              rects.Any(_ => Rect.Intersects(rect, _))) &&
                             max > 0);

                    if (max <= 0) continue;
                    dat.Item1.RenderSetPiece(world, pt);
                    rects.Add(rect);
                }
            }

            log.Info("Set pieces applied.");
        }

        public static void RenderFromProto(World world, IntPoint pos, ProtoWorld proto)
        {
            var manager = world.Manager;

            // get map stream
            var map = 0;
            if (proto.maps != null && proto.maps.Length > 1)
            {
                var rnd = new Random();
                map = rnd.Next(0, proto.maps.Length);
            }

            var ms = new MemoryStream(proto.wmap[map]);

            var sp = new Wmap(manager.Resources.GameData);
            sp.Load(ms, 0);
            sp.ProjectOntoWorld(world, pos);
        }

        public static Wmap GetWmap(RealmManager manager, ProtoWorld proto)
        {
            // get map stream
            var map = 0;
            if (proto.maps != null && proto.maps.Length > 1)
            {
                var rnd = new Random();
                map = rnd.Next(0, proto.maps.Length);
            }

            var ms = new MemoryStream(proto.wmap[map]);

            var wmap = new Wmap(manager.Resources.GameData);
            wmap.Load(ms, 0);
            return wmap;
        }
    }
}