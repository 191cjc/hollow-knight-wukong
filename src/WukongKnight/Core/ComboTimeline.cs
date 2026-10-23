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

    internal sealed class ComboStage
    {
        public ComboStage(string clip, int ticks, int bufferOpenTick, double rangeMultiplier, HitWindow[] windows)
        {
            Clip = clip; Ticks = ticks; BufferOpenTick = bufferOpenTick;
            RangeMultiplier = rangeMultiplier; Windows = windows;
        }
        public string Clip { get; }
        public int Ticks { get; }
        public int BufferOpenTick { get; }
        public double RangeMultiplier { get; }
        public HitWindow[] Windows { get; }
    }

    internal enum ComboEventKind { StageStarted, WindowOpened, WindowClosed, StageEnded, Canceled }

    internal readonly struct ComboEvent
    {
        public ComboEvent(ComboEventKind kind, long token, int stage, int window = -1)
        { Kind = kind; Token = token; Stage = stage; Window = window; }
        public ComboEventKind Kind { get; }
        public long Token { get; }
        public int Stage { get; }
        public int Window { get; }
    }

    /// <summary>Engine-free, scaled source-tick clock. A press can queue at most one subsequent stage.</summary>
    internal sealed class ComboTimeline
    {
        private readonly ComboStage[] stages;
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

        public ComboTimeline(ComboStage[] stages, double frameRate, double grace)
        {
            if (stages.Length != 4 || frameRate <= 0 || grace < 0) throw new ArgumentException("Invalid combo clock.");
            this.stages = stages; this.frameRate = frameRate; this.grace = grace;
        }
        public bool Active { get; private set; }
        public int StageIndex { get; private set; }
        public int WindowIndex { get; private set; } = -1;
        public long Token { get; private set; }
        public bool Buffered => buffered;
        public double Duration => stages[StageIndex].Ticks * secondsPerTick;
        public double SecondsPerTick => secondsPerTick;
        public double Elapsed(double now) => Active ? Math.Max(0, now - started) : 0;

        public List<ComboEvent> Press(double now, double timeScale)
        {
            var events = new List<ComboEvent>();
            if (Active)
            {
                // Early presses are deliberately discarded, rather than surviving every stage.
                if (Elapsed(now) >= stages[StageIndex].BufferOpenTick * secondsPerTick) buffered = true;
            }
            else
            {
                if (now > graceUntil) nextStage = 0;
                Begin(now, timeScale, events);
            }
            return events;
        }

        public List<ComboEvent> Advance(double now, double nextTimeScale)
        {
            var events = new List<ComboEvent>();
            if (!Active) return events;
            double elapsed = Elapsed(now);
            HitWindow[] windows = stages[StageIndex].Windows;
            while (nextWindow < windows.Length)
            {
                HitWindow window = windows[nextWindow];
                if (elapsed < window.StartTick * secondsPerTick) break;
                if (WindowIndex < 0)
                {
                    WindowIndex = nextWindow;
                    targets.Clear();
                    events.Add(new ComboEvent(ComboEventKind.WindowOpened, Token, StageIndex, WindowIndex));
                }
                if (elapsed < window.EndTick * secondsPerTick) break;
                events.Add(new ComboEvent(ComboEventKind.WindowClosed, Token, StageIndex, WindowIndex));
                WindowIndex = -1;
                nextWindow++;
            }
            if (elapsed >= Duration)
            {
                events.Add(new ComboEvent(ComboEventKind.StageEnded, Token, StageIndex));
                bool follow = buffered && StageIndex < stages.Length - 1;
                nextStage = (StageIndex + 1) % stages.Length;
                graceUntil = started + Duration + grace;
                Active = false;
                buffered = false;
                targets.Clear();
                if (follow) Begin(now, nextTimeScale, events);
            }
            return events;
        }

        public List<ComboEvent> Cancel()
        {
            var events = new List<ComboEvent>();
            if (Active) events.Add(new ComboEvent(ComboEventKind.Canceled, Token, StageIndex, WindowIndex));
            Active = false; WindowIndex = -1; buffered = false; nextStage = 0; nextWindow = 0;
            graceUntil = double.NegativeInfinity; targets.Clear(); Token = ++serial;
            return events;
        }

        public bool TryHit(long token, int window, int responderId)
        {
            return Active && token == Token && window >= 0 && window == WindowIndex && targets.Add(responderId);
        }

        private void Begin(double now, double timeScale, List<ComboEvent> events)
        {
            if (double.IsNaN(timeScale) || double.IsInfinity(timeScale) || timeScale <= 0)
                throw new ArgumentOutOfRangeException(nameof(timeScale));
            StageIndex = nextStage; started = now; secondsPerTick = timeScale / frameRate;
            Token = ++serial; WindowIndex = -1; nextWindow = 0; buffered = false; Active = true; targets.Clear();
            events.Add(new ComboEvent(ComboEventKind.StageStarted, Token, StageIndex));
        }
    }
}
