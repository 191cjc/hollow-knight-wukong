using System;
namespace WukongKnight.Core
{
    internal static partial class FistRules
    {
        public static FireDemonRegion? Region(string name, double tick, bool right)
        {
            if (tick < 0 || double.IsNaN(tick) || double.IsInfinity(tick)) return null;
            double[]? box = null;
            switch (name)
            {
                case "effect1_1":
                    if (tick >= 0 && tick < 100000) box = new double[] { -41.000432095, -119.984867360, 42.999245149, 1.015808140 };
                    break;
                case "effect1_2":
                    if (tick >= 0 && tick < 100000) box = new double[] { -74.050000000, -339.550000000, 211.800000000, 36.150000000 };
                    break;
                case "effect2_1":
                    if (tick >= 0 && tick < 100000) box = new double[] { -108.511937550, -48.078021252, 142.438839210, 43.922348785 };
                    break;
                case "effect2_2":
                    if (tick >= 0 && tick < 100000) box = new double[] { -107.993509438, -44.011716240, 76.004991513, 43.988769510 };
                    break;
                case "effect4_1":
                    if (tick >= 7 && tick < 16) box = new double[] { -57.998923800, -145.400454680, 166.801893960, 39.199729945 };
                    if (tick >= 16 && tick < 25) box = new double[] { -74.423255950, -132.012368120, 159.327528490, 33.237281005 };
                    break;
                case "effect4_2":
                    if (tick >= 25 && tick < 32) box = new double[] { -74.423255950, -215.362822800, 159.327528490, 33.237010950 };
                    break;
                case "effect4_3":
                    if (tick >= 32 && tick < 40) box = new double[] { -160.671863550, -151.510437600, 169.727308410, 25.939704900 };
                    break;
                case "effect4_4":
                    if (tick >= 40 && tick < 53) box = new double[] { -98.070062800, -151.510437600, 218.728347760, 25.939704900 };
                    break;
                case "effect4_5":
                    if (tick >= 53 && tick < 100000) box = new double[] { -57.900405525, -151.510437600, 168.250531455, 25.939704900 };
                    break;
                case "effect5_0":
                    if (tick >= 10 && tick < 23) box = new double[] { -188.289484650, -348.576219600, 191.560100030, 17.523429150 };
                    if (tick >= 23 && tick < 31) box = new double[] { -188.287345900, -348.576219600, 281.612579780, 17.523429150 };
                    if (tick >= 31 && tick < 35) box = new double[] { -188.289484650, -348.576219600, 191.560100030, 17.523429150 };
                    if (tick >= 35 && tick < 43) box = new double[] { -188.287345900, -348.576219600, 281.612579780, 17.523429150 };
                    if (tick >= 43 && tick < 47) box = new double[] { -188.289484650, -348.576219600, 191.560100030, 17.523429150 };
                    if (tick >= 47 && tick < 55) box = new double[] { -188.287345900, -348.576219600, 281.612579780, 17.523429150 };
                    if (tick >= 55 && tick < 59) box = new double[] { -188.289484650, -348.576219600, 191.560100030, 17.523429150 };
                    if (tick >= 59 && tick < 68) box = new double[] { -188.287345900, -348.576219600, 281.612579780, 17.523429150 };
                    break;
                case "effect5_1":
                    if (tick >= 68 && tick < 79) box = new double[] { -188.289484650, -348.576219600, 191.560100030, 17.523429150 };
                    if (tick >= 79 && tick < 100000) box = new double[] { -188.300018900, -348.576219600, 437.650496380, 17.523429150 };
                    break;
                default: throw new ArgumentOutOfRangeException(nameof(name));
            }
            if (box == null) return null;
            return new FireDemonRegion((box[0] + box[2]) / 2 * (right ? 1 : -1), -(box[1] + box[3]) / 2, box[2] - box[0], box[3] - box[1]);
        }
    }
}
