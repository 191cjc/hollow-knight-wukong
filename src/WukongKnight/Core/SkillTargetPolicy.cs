namespace WukongKnight.Core
{
    /// <summary>Physics queries must explicitly reproduce native attack contact filtering.</summary>
    internal static class SkillTargetPolicy
    {
        public const int AttackLayer = 17;
        public const int EnemyLayer = 11;
        private const int IgnoredLayers = (1 << 9) | (1 << 20) | (1 << 26) | (1 << 31);

        public static int QueryMask(int nativeAttackMask) => nativeAttackMask & ~IgnoredLayers;

        public static bool Allows(int colliderLayer, int queryMask, bool healthTarget)
        {
            if (colliderLayer < 0 || colliderLayer > 31 || (queryMask & (1 << colliderLayer)) == 0) return false;
            // A boss's weapon/sensor can share its HealthManager ancestor without being a hurtbox.
            return !healthTarget || colliderLayer == EnemyLayer;
        }
    }
}
