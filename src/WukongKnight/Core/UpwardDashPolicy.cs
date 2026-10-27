using System;

namespace WukongKnight.Core
{
    /// <summary>One admitted upward dash per physical landing; native air allowance is separate.</summary>
    internal sealed class UpwardDashPolicy
    {
        private long sequence;
        private bool pending;
        private bool motionRevoked;
        private bool hasVelocity;
        private float lastX;
        private float lastY;
        public long Token { get; private set; }
        public bool Active { get; private set; }
        public bool UsedUntilLanding { get; private set; }

        public static bool RequestsUp(bool equipped, bool airborne, bool up, bool down, bool left, bool right)
            => equipped && airborne && up && !down && !left && !right;

        public bool Allows(bool nativeAllowed, bool requestsUp)
            => nativeAllowed && (!requestsUp || !UsedUntilLanding);

        // Prepare happens before native callbacks. Every start, including a script's
        // horizontal dash, invalidates older deferred completion/vector callbacks.
        public long Prepare(bool admittedUpwardInput)
        {
            Token = ++sequence;
            Active = false;
            pending = admittedUpwardInput && !UsedUntilLanding;
            motionRevoked = hasVelocity = false;
            return Token;
        }

        public bool Complete(long token, bool nativeStarted)
        {
            if (token != Token || !pending) return false;
            pending = false;
            if (!nativeStarted) return false;
            Active = UsedUntilLanding = true;
            return true;
        }

        public bool Owns(long token) => token != 0 && token == Token && Active;

        public void Observe(bool nativeDashing, bool ownsFlame)
        {
            // Native HeroDash can synchronously notify observers during startup,
            // before it sets dashing. Only an already-active dash may expire here.
            if (Active && (!nativeDashing || !ownsFlame)) Stop(Token);
        }

        public void RecordVelocity(long token, float x, float y)
        {
            if (!Owns(token) || motionRevoked) return;
            hasVelocity = !float.IsNaN(x) && !float.IsInfinity(x) && !float.IsNaN(y) && !float.IsInfinity(y);
            lastX = x; lastY = y;
        }

        // New native jump/bounce/recoil motion always wins, even if it happens to
        // choose the same velocity as the previous dash output.
        public void RevokeMotion()
        {
            motionRevoked = true;
            hasVelocity = false;
        }

        public bool Finish(long token, bool normalNativeFinish, float currentX, float currentY)
        {
            if (!Owns(token)) return false;
            bool clearY = normalNativeFinish && hasVelocity && !motionRevoked &&
                lastY > 0 && currentY == lastY && currentX == lastX;
            Stop(token);
            return clearY;
        }

        public void Stop(long token)
        {
            if (token != Token) return;
            Active = pending = hasVelocity = false;
        }

        public void Landed(bool nativeGrounded, bool touchingGround)
        {
            // An up dash starts in air; do not reset from stale ground state while
            // that transaction is still moving away from the floor.
            if (nativeGrounded && touchingGround && !Active) UsedUntilLanding = false;
        }

        public void ConfirmLanding(long token, bool nativeAccepted)
        {
            // This is the actual bottom-contact branch after native BackOnGround
            // or hard/dash landing. Unlike a passive ray, it proves a new landing,
            // including one that occurs before an active dash finishes.
            if (token == Token && nativeAccepted) UsedUntilLanding = false;
        }

        public void Clear()
        {
            Token = ++sequence;
            Active = pending = hasVelocity = UsedUntilLanding = false;
            motionRevoked = false;
        }
    }
}
