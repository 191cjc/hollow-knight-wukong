using System;
using System.Collections.Generic;

namespace WukongKnight.Core
{
    internal sealed class HitWindow
    {
        public HitWindow(int startTick, int endTick) { StartTick = startTick; EndTick = endTick; }
        public int StartTick { get; }
        public int EndTick { get; }
    }

    internal class AttackDefinition
    {
        public AttackDefinition(string clip, int ticks, double rangeMultiplier, HitWindow[] windows)
        { Clip = clip; Ticks = ticks; RangeMultiplier = rangeMultiplier; Windows = windows; }
        public string Clip { get; }
        public int Ticks { get; }
        public double RangeMultiplier { get; }
        public HitWindow[] Windows { get; }
    }

    internal sealed class ComboStage : AttackDefinition
    {
        public ComboStage(string clip, int ticks, int bufferOpenTick, double rangeMultiplier, HitWindow[] windows)
            : base(clip, ticks, rangeMultiplier, windows) { BufferOpenTick = bufferOpenTick; }
        public int BufferOpenTick { get; }
    }

    internal enum AttackMode { GroundCombo, AirHorizontal }
    internal enum ComboEventKind { StageStarted, WindowOpened, WindowClosed, StageEnded, Canceled }

    internal readonly struct ComboEvent
    {
        public ComboEvent(ComboEventKind kind, long token, AttackMode mode, int stage, AttackDefinition definition, int window = -1)
        { Kind = kind; Token = token; Mode = mode; Stage = stage; Definition = definition; Window = window; }
        public ComboEventKind Kind { get; }
        public long Token { get; }
        public AttackMode Mode { get; }
        public int Stage { get; }
        // An Advance can end one action and begin the next before its events are consumed.
        public AttackDefinition Definition { get; }
        public int Window { get; }
    }

    /// <summary>One scaled source-tick clock and token sequence for ground combos and single air attacks.</summary>
    internal sealed class ComboTimeline
    {
        private readonly ComboStage[] stages;
        private readonly AttackDefinition airAttack;
        private readonly double frameRate;
        private readonly double grace;
        private readonly HashSet<int> targets = new HashSet<int>();
        private long serial;
        private int nextStage;
        private int nextWindow;
        private double graceUntil = double.NegativeInfinity;
        private double started;
        private double secondsPerTick;
        private bool buffered;

        public ComboTimeline(ComboStage[] stages, AttackDefinition airAttack, double frameRate, double grace)
        {
            if (stages.Length != 4 || frameRate <= 0 || grace < 0) throw new ArgumentException("Invalid combo clock.");
            this.stages = stages; this.airAttack = airAttack; this.frameRate = frameRate; this.grace = grace;
        }
        public bool Active { get; private set; }
        public AttackMode Mode { get; private set; }
        public int StageIndex { get; private set; }
        public AttackDefinition CurrentAttack => Mode == AttackMode.AirHorizontal ? airAttack : stages[StageIndex];
        public int WindowIndex { get; private set; } = -1;
        public long Token { get; private set; }
        public bool Buffered => buffered;
        public double Duration => CurrentAttack.Ticks * secondsPerTick;
        public double SecondsPerTick => secondsPerTick;
        public double Elapsed(double now) => Active ? Math.Max(0, now - started) : 0;

        public List<ComboEvent> Press(double now, double timeScale)
        {
            var events = new List<ComboEvent>();
            if (Active)
            {
                // Air is standalone: even a ground-entry caller cannot leave it a follow-up.
                if (Mode == AttackMode.GroundCombo && Elapsed(now) >= stages[StageIndex].BufferOpenTick * secondsPerTick)
                    buffered = true;
            }
            else
            {
                if (now > graceUntil) nextStage = 0;
                Begin(AttackMode.GroundCombo, nextStage, now, timeScale, events);
            }
            return events;
        }

        public List<ComboEvent> PressAir(double now, double timeScale)
        {
            var events = new List<ComboEvent>();
            if (Active) return events;
            ResetContinuation();
            Begin(AttackMode.AirHorizontal, -1, now, timeScale, events);
            return events;
        }

        public List<ComboEvent> ObserveContact(bool onGround, bool jumping, bool wallSliding)
        {
            // This also runs while inactive: walking off a ledge invalidates ground grace.
            if (!onGround || jumping || wallSliding) ResetContinuation();
            bool invalid = wallSliding || (Mode == AttackMode.GroundCombo ? !onGround || jumping : onGround);
            return Active && invalid ? Cancel() : new List<ComboEvent>();
        }

        public List<ComboEvent> Advance(double now, double nextTimeScale)
        {
            var events = new List<ComboEvent>();
            if (!Active) return events;
            double elapsed = Elapsed(now);
            HitWindow[] windows = CurrentAttack.Windows;
            while (nextWindow < windows.Length)
            {
                HitWindow window = windows[nextWindow];
                if (elapsed < window.StartTick * secondsPerTick) break;
                if (WindowIndex < 0)
                {
                    WindowIndex = nextWindow;
                    targets.Clear();
                    events.Add(Event(ComboEventKind.WindowOpened, WindowIndex));
                }
                if (elapsed < window.EndTick * secondsPerTick) break;
                events.Add(Event(ComboEventKind.WindowClosed, WindowIndex));
                WindowIndex = -1;
                nextWindow++;
            }
            if (elapsed >= Duration)
            {
                events.Add(Event(ComboEventKind.StageEnded));
                bool follow = Mode == AttackMode.GroundCombo && buffered && StageIndex < stages.Length - 1;
                if (Mode == AttackMode.GroundCombo)
                {
                    nextStage = (StageIndex + 1) % stages.Length;
                    graceUntil = started + Duration + grace;
                }
                else ResetContinuation();
                Active = false; WindowIndex = -1;
                buffered = false;
                targets.Clear();
                if (follow) Begin(AttackMode.GroundCombo, nextStage, now, nextTimeScale, events);
            }
            return events;
        }

        public List<ComboEvent> Cancel()
        {
            var events = new List<ComboEvent>();
            if (Active) events.Add(Event(ComboEventKind.Canceled, WindowIndex));
            Active = false; WindowIndex = -1; nextWindow = 0;
            ResetContinuation(); targets.Clear(); Token = ++serial;
            return events;
        }

        public bool TryHit(long token, int window, int responderId)
        {
            return Active && token == Token && window >= 0 && window == WindowIndex && targets.Add(responderId);
        }

        private void ResetContinuation()
        { nextStage = 0; graceUntil = double.NegativeInfinity; buffered = false; }

        private ComboEvent Event(ComboEventKind kind, int window = -1) => new ComboEvent(kind, Token, Mode, StageIndex, CurrentAttack, window);

        private void Begin(AttackMode mode, int stage, double now, double timeScale, List<ComboEvent> events)
        {
            if (double.IsNaN(timeScale) || double.IsInfinity(timeScale) || timeScale <= 0)
                throw new ArgumentOutOfRangeException(nameof(timeScale));
            Mode = mode; StageIndex = stage; started = now; secondsPerTick = timeScale / frameRate;
            Token = ++serial; WindowIndex = -1; nextWindow = 0; buffered = false; Active = true; targets.Clear();
            events.Add(Event(ComboEventKind.StageStarted));
        }
    }
}
