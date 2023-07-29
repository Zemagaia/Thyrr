using System;
using NLog;

namespace Shared
{
    public static class MathUtils
    {
        private static readonly Logger Log = LogUtil.GetLogger(typeof(MathUtils));
        public static readonly Random Random = new();

        public static double NextDouble()
        {
            return Random.NextDouble();
        }

        public static int Next(int max)
        {
            return (int)(NextDouble() * max);
        }

        public static int Next(int min, int max)
        {
            return min + (int)(NextDouble() * (max - min));
        }
    }
}