using System;
using System.Collections.Generic;
using System.Linq;
using WukongKnight.Core;

internal static class Program
{
    private static int Main()
    {
        Action[] cases = { SinglePressDoesNotAutoChain, FourPressesFollowFourStages, BufferIsBoundedAndEarlyPressIsRejected, GraceHasAnInclusiveDeadline, CancellationInvalidatesOwnership, DualWindowsDeduplicateActualTargets, QuickSlashScalesEveryStageWindow, PhysicsClockSurvivesSlowRendering, CompletionDoesNotRetainStageFourInput, ContactCleanupWaitsForNativeEnumeration, DashHitsEachResponderOnce, DashCancellationRejectsOldCallbacks, NewDashClearsTargetsWithoutAcceptingStaleHits };
        cases = cases.Concat(new Action[] { FireDemonContactCooldownAndTargetIndependence, FireDemonContactCapAndFinisher, FireDemonLagDoesNotCatchUpDamage, FireDemonCancellationAndRecast, FireDemonFixedSpellBalance, FireDemonFinisherRevealsWithoutEndingProtection, FireDemonOldFinisherCannotRevealNewCast }).ToArray();
        cases = cases.Concat(new Action[] { EnemySensorsCannotConsumeSkillHits, BossWeaponCannotRouteDamageToParent, SkillContactsRetainNativeInteractions }).ToArray();
        cases = cases.Concat(new Action[] { FireDemonFinishesWithoutLanding, FireDemonLagDoesNotExtendEffects, FireDemonOriginalRegionsMirrorAroundSourceRoot, FireDemonSourceFinisherRetainsCastProtection }).ToArray();
        cases = cases.Concat(new Action[] { BloodEyeOnlyHealsRealDamage, BloodEyeCooldownIsGlobal, BloodEyeExpiryDoesNotHeal, BloodEyeRefreshPreservesCooldown, BloodEyeClearRejectsOldCallbacks, BloodEyeFullHealthDoesNotConsumeProc, BloodEyeRejectsInvalidTime, StormUsesSourceClock, StormContactsAreBounded, StormUsesFixedSpellDamage, StormUsesOriginalLocalMask }).ToArray();
        cases = cases.Concat(new Action[] { FireDemonSourceTravelIsBounded, FireDemonTravelDoesNotDependOnSampling, BloodEyeVisualClockFollowsLifetime }).ToArray();
        cases = cases.Concat(new Action[] { FireEyeWaitsForEndWindow, FireEyeDeadlineUsesNativeRates, FireEyeRepeatedObserversDoNotStretchSourceFrames, FireEyeVisualPauseUsesScaledTime, FireEyeCancelledAndRecastClockIsFresh }).ToArray();
        cases = cases.Concat(new Action[] { DeathSourceClockDoesNotRestartOrLoop, DeathPauseUsesScaledTime, DeathCleanupAllowsFreshRespawn }).ToArray();
        cases = cases.Concat(new Action[] { FistChargeReleaseThreshold, FistChargeReleaseIsLatched, FistContactsOwnSubskills, FistSourceMasksStayLocal, FistTravelIsBounded, FistBalanceHasBoundedCloneDamage }).ToArray();
        cases = cases.Concat(new Action[] { FistChargeForcesSourceRelease, FistChargeAutoReleaseIsLatched, FistDirectionalSoulGate, FistSoulAcquisitionCanBeRevoked, FistSoulSpendingCanRevokeControl }).ToArray();
        cases = cases.Concat(new Action[] { CopiedGodslayerGhostExpiresAtReleaseEnd, CopiedEarthbreakerGhostExpiresAtLandingEnd, IdleGhostExpiryDefersForCopy, EarthbreakerDescentIsFasterAndSamplingIndependent, FistPushUsesNativeSlamAndAwayDirection }).ToArray();
        cases = cases.Concat(new Action[] { EarthbreakerProtectionEndsWithHeroAction, FireApeKeepsOriginalDeadline, HeroRecoveryRetainsOtherActionClocks }).ToArray();
        cases = cases.Concat(new Action[] { DetachedSummonsKeepIndependentClocks, AfterimageTrailBirthsRetainPositionsAcrossSlowFrames, DetachedCancellationRejectsStaleWork, SummonsSpendSoulWithoutTakingControl, SummonPaymentCanRevokeSpawn, DetachedContactsKeepCapsWhenFacingChanges }).ToArray();
        cases = cases.Concat(new Action[] { ControlledCastRejectsInsufficientAndRevokedSoul, ControlledCastPaymentAndExceptionReleaseOwner }).ToArray();
        cases = cases.Concat(new Action[] { EnemyDamageRequiresExactIdentity, EnemyDamageRequiresActualSurvivingLoss, EnemyDamageRejectsNestedAttribution, EnemyDamageRejectsRevokedAndReusedResults, EnemyDamageAllowsRepeatedAcceptedHits }).ToArray();
        foreach (Action test in cases)
        {
            try { test(); Console.WriteLine("PASS " + test.Method.Name); }
            catch (Exception error) { Console.Error.WriteLine("FAIL " + test.Method.Name + ": " + error.Message); return 1; }
        }
        Console.WriteLine(cases.Length + " combo-core checks passed (actual linked production source).");
        return 0;
    }

    private static void EnemyDamageRequiresExactIdentity()
    {
        object source = new object(), target = new object(), other = new object();
        var attempt = new ScopedEnemyDamage<object, object>(source, target, 7, 100);
        Check(!attempt.Begin(other, target, 7, 100, 1, 1), "An unrelated spell source entered Storm attribution");
        Check(!attempt.Begin(source, other, 7, 100, 1, 2), "A sibling responder entered another target's dispatch");
        Check(!attempt.Begin(source, target, 8, 100, 1, 3), "A new cast borrowed the old attempt");
        Check(attempt.Begin(source, target, 7, 100, 1, 4), "Exact dispatched hit was not observable");
        Check(attempt.Complete(source, target, 7, 90, 4, true), "Wrong identities consumed the later exact dispatch");
        foreach (bool wrongSource in new[] { false, true })
        {
            attempt = new ScopedEnemyDamage<object, object>(source, target, 7, 100);
            attempt.Begin(source, target, 7, 100, 1, 5);
            Check(!attempt.Complete(wrongSource ? other : source, wrongSource ? target : other, 7, 90, 5, true), "Completion reused a replaced source/responder");
        }
    }

    private static void EnemyDamageRequiresActualSurvivingLoss()
    {
        object source = new object(), target = new object();
        foreach (int after in new[] { 100, 105, 0, -10 })
        {
            var attempt = new ScopedEnemyDamage<object, object>(source, target, 1, 100);
            Check(attempt.Begin(source, target, 1, 100, 1, 1), "Valid native observation rejected");
            Check(!attempt.Complete(source, target, 1, after, 1, true), "No-damage/healing/fatal hit triggered interruption");
        }
        var changed = new ScopedEnemyDamage<object, object>(source, target, 1, 100);
        Check(!changed.Begin(source, target, 1, 90, 1, 2), "Pre-dispatch TAKE DAMAGE HP loss was attributed to the later hit");
        Check(!changed.Complete(source, target, 1, 80, 2, true), "Rejected observation later accepted HP loss");
        var dead = new ScopedEnemyDamage<object, object>(source, target, 1, 0);
        Check(!dead.Begin(source, target, 1, 0, 1, 3), "Already dead responder entered observation");
    }

    private static void EnemyDamageRejectsNestedAttribution()
    {
        object source = new object(), target = new object();
        var outer = new ScopedEnemyDamage<object, object>(source, target, 1, 100);
        Check(outer.Begin(source, target, 1, 100, 1, 20), "Outer native hit did not start");
        Check(!outer.Begin(source, target, 1, 100, 2, 21), "Reentrant matching source replaced the outer observation");
        Check(!outer.Complete(source, target, 1, 80, 21, true), "Nested damage contaminated the enclosing HP delta");
        var inner = new ScopedEnemyDamage<object, object>(source, target, 1, 100);
        Check(!inner.Begin(source, target, 1, 100, 2, 22), "Storm hit inside an unrelated damage callback was attributed");
        Check(!inner.Complete(source, target, 1, 90, 22, true), "Rejected nested observation became eligible");
        var afterHook = new ScopedEnemyDamage<object, object>(source, target, 1, 100);
        afterHook.Begin(source, target, 1, 100, 1, 30);
        Check(!afterHook.Complete(source, target, 1, 90, 31, true), "Later healing hook nested hit escaped sequence guard");
    }

    private static void EnemyDamageRejectsRevokedAndReusedResults()
    {
        object source = new object(), target = new object();
        foreach (bool newCast in new[] { false, true })
        {
            var attempt = new ScopedEnemyDamage<object, object>(source, target, 4, 100);
            attempt.Begin(source, target, 4, 100, 1, 1);
            Check(!attempt.Complete(source, target, newCast ? 5 : 4, 90, 1, newCast), "Recast/cancelled/detached owner accepted an old result");
            Check(!attempt.Complete(source, target, 4, 90, 1, true), "Revoked result became valid after reacquisition");
        }
        var missing = new ScopedEnemyDamage<object, object>(source, target, 4, 100);
        Check(!missing.Complete(source, target, 4, 90, 1, true), "Unobserved HP change counted as a hit");
        Check(!missing.Begin(source, target, 4, 100, 1, 2), "Completed result reopened an old dispatch");
    }

    private static void EnemyDamageAllowsRepeatedAcceptedHits()
    {
        object source = new object(), target = new object();
        var ledger = new SpellHitLedger(FlameStormRules.HitCap);
        long token = ledger.Begin();
        for (int index = 0; index < FlameStormRules.HitCap; index++)
        {
            Check(ledger.TryAirHit(token, 42, index * .11), "Existing Storm cap/contact spacing changed");
            var attempt = new ScopedEnemyDamage<object, object>(source, target, token, 100 - index * 10);
            Check(attempt.Begin(source, target, token, 100 - index * 10, 1, index + 1), "A later effective hit inherited a consumed result");
            Check(attempt.Complete(source, target, token, 90 - index * 10, index + 1, ledger.Owns(token)), "Repeated effective hit was not accepted");
            Check(!attempt.Complete(source, target, token, 90 - index * 10, index + 1, true), "One hit triggered interruption twice");
        }
        Check(!ledger.TryAirHit(token, 42, 1), "Observation allowed a sixth Storm contact");
    }

    private static void ControlledCastRejectsInsufficientAndRevokedSoul()
    {
        int soul=23, acquired=0, spent=0, recovered=0;
        bool held=false;
        Func<bool> acquire=() => { acquired++; held=true; return true; };
        Func<bool> cast=() => FistRules.TryBeginControlled(true,24,() => soul,acquire,() => held,
            n => { spent+=n; soul-=n; },() => { recovered++; held=false; });
        Check(!cast() && acquired==0 && spent==0 && recovered==0, "Insufficient Storm Soul took Dream control");
        soul=24;
        Check(!FistRules.TryBeginControlled(true,24,() => soul,
            () => { acquired++; held=true; soul=0; return true; },() => held,
            n => spent+=n,() => { recovered++; held=false; }), "Acquisition callback changed Soul without rejecting cast");
        Check(spent==0 && recovered==1 && !held, "Revoked acquisition retained control or spent Soul");
        soul=24;
        Check(cast() && spent==24 && soul==0 && held && recovered==1, "Valid reacquisition did not spend exactly once");
    }
    private static void ControlledCastPaymentAndExceptionReleaseOwner()
    {
        bool held=true;
        int spent=0, recovered=0;
        Check(!FistRules.TryBeginControlled(true,33,() => 33,() => held,() => held,
            n => { spent+=n; held=false; },() => recovered++), "Revoked held spell started Earthbreaker");
        Check(spent==33 && recovered==1, "Payment revocation duplicated Soul or missed recovery");
        held=true;
        bool threw=false;
        try
        {
            FistRules.TryBeginControlled(true,33,() => 33,() => held,() => held,
                n => { throw new InvalidOperationException("MP hook failure"); },() => { recovered++; held=false; });
        }
        catch (InvalidOperationException) { threw=true; }
        Check(threw && !held && recovered==2, "MP hook exception stranded native control");
    }
    private static void DetachedSummonsKeepIndependentClocks()
    {
        var combo=new FistSummonClock(FistAction.Afterimage,10);
        var ape=new FistSummonClock(FistAction.FireApe,11);
        var held=new GodslayerCharge(); held.Release(.2,false); held.Reset();
        for (int i=0;i<5;i++)
        {
            Check(combo.Tick(11)==30 && ape.Tick(11)==0, "Repeated observation or another skill reset a summon clock");
            Check(combo.Active(11) && ape.Active(11), "One summon hid the other");
        }
        Check(!combo.Active(10+71.0/30) && ape.Active(10+71.0/30), "Combo completion ended the moving Ape");
        Check(ape.Active(11+105.0/30-.001) && !ape.Active(11+105.0/30), "Ape lost original105-tick lifetime");
        Check(!ape.Active(double.NaN) && !combo.Active(double.PositiveInfinity), "Invalid source clock retained damage");
    }
    private static void AfterimageTrailBirthsRetainPositionsAcrossSlowFrames()
    {
        foreach (bool slow in new[] {false,true})
        {
            var clock=new FistSummonClock(FistAction.Afterimage,0);
            var positions=new List<double>(); double position=0;
            for (int tick=1;tick<=71;tick++)
            {
                if (slow && tick<71) continue;
                while (clock.NextAfterimageStep(tick/30.0,out double pixels,out int birth))
                {
                    position+=pixels;
                    if (birth!=0) { Check(birth==positions.Count+1,"Trail born out of order"); positions.Add(position); }
                }
            }
            Check(positions.SequenceEqual(new[] {60.0,165.0,270.0,360.0}), "Slow frame collapsed the four trail positions");
            Check(position==540,"Detached clone changed original total forward travel");
            Check(!clock.NextAfterimageStep(71.0/30,out _,out _),"Repeated fixed step moved the clone twice");
        }
    }
    private static void DetachedCancellationRejectsStaleWork()
    {
        var old=new FistSummonClock(FistAction.Afterimage,0);
        old.NextAfterimageStep(.5,out _,out _); old.Cancel();
        var fresh=new FistSummonClock(FistAction.Afterimage,1);
        Check(!old.Active(1) && !old.NextAfterimageStep(2,out _,out _),"Canceled actor retained callbacks/trail births");
        Check(fresh.Active(1) && fresh.Tick(1)==0,"Recast inherited previous clock");
        var ape=new FistSummonClock(FistAction.FireApe,0); fresh.Cancel();
        Check(ape.Active(2),"Replacing combo canceled an unrelated Ape");
    }
    private static void SummonsSpendSoulWithoutTakingControl()
    {
        foreach (FistAction action in new[] {FistAction.Afterimage,FistAction.FireApe})
        foreach (int cost in new[] {33,24})
        {
            int soul=cost-1, spends=0; bool eligible=true;
            Func<bool> start=() => FistRules.TryBeginSummon(action,cost,() => soul,() => eligible,n => { soul-=n; spends++; });
            Check(!start() && spends==0,"Insufficient Soul started a summon");
            soul=cost; Check(start() && soul==0 && spends==1,"Summon did not spend live native cost exactly once");
            soul=cost; eligible=false; Check(!start() && soul==cost && spends==1,"Duplicate/ineligible cast spent Soul");
        }
        Check(!FistRules.TryBeginSummon(FistAction.Godslayer,33,() => 99,() => true,_ => { throw new Exception("Unexpected payment"); }),"Owned hero skill used detached payment");
    }
    private static void SummonPaymentCanRevokeSpawn()
    {
        bool alive=true; int paid=0;
        bool accepted=FistRules.TryBeginSummon(FistAction.FireApe,33,() => 33,() => alive,n => { paid+=n; alive=false; });
        Check(!accepted && paid==33,"Native Soul callback could spawn a dead/stale actor or charged twice");
    }
    private static void DetachedContactsKeepCapsWhenFacingChanges()
    {
        var ape=new FistContacts(); var clone=new FistContacts();
        Check(ape.TryHit(0,7,5,.434,0),"Initial detached contact rejected");
        Check(!ape.TryHit(0,7,5,.434,.1),"Turning/moving could reset detached cooldown");
        Check(clone.TryHit(0,7,2,.3,.1),"Independent clone shared Ape's cooldown");
        for (int i=1;i<5;i++) Check(ape.TryHit(0,7,5,.434,i*.434),"Source punches lost a contact");
        Check(!ape.TryHit(0,7,5,.434,3),"Ape recentered and exceeded its per-target cap");
        Check(ape.TryHit(1,7,2,.4,3),"Front roar lost independent subskill budget");
    }
    private static void EarthbreakerProtectionEndsWithHeroAction()
    {
        Check(!FistRules.ActionFinished(FistAction.Earthbreaker, 0, -1, false, 0), "Earthbreaker ended at launch");
        Check(!FistRules.ActionFinished(FistAction.Earthbreaker, 4.9, -1, false, 0), "Falling protection ended before timeout");
        Check(!FistRules.ActionFinished(FistAction.Earthbreaker, 2, 14.0/30-.001, false, 0), "Landing tail lost protection early");
        Check(FistRules.ActionFinished(FistAction.Earthbreaker, 2, 14.0/30, false, 0), "Landing tail retained old protection");
        Check(FistRules.ActionFinished(FistAction.Earthbreaker, 5, -1, false, 0), "Bottomless timeout retained protection");
        Check(FistRules.ActionFinished(FistAction.None, 0, -1, false, 0), "Stopped action still owned a defensive window");
    }
    private static void FireApeKeepsOriginalDeadline()
    {
        for (int observation=0; observation<8; observation++)
            Check(!FistRules.ActionFinished(FistAction.FireApe, 2, -1, false, 0), "Paused/repeated damage observer advanced action");
        Check(!FistRules.ActionFinished(FistAction.FireApe, 105.0/30-.001, -1, false, 0), "Ape effect cut the source tail short");
        Check(FistRules.ActionFinished(FistAction.FireApe, 105.0/30, -1, false, 0), "Ape clock restarted or extended the effect");
        Check(FistRules.ActionFinished(FistAction.FireApe, 5, -1, false, 0), "Late observer retained the effect");
    }
    private static void HeroRecoveryRetainsOtherActionClocks()
    {
        Check(!FistRules.ActionFinished(FistAction.Afterimage, 71.0/30-.001, -1, false, 0), "Combo tail changed");
        Check(FistRules.ActionFinished(FistAction.Afterimage, 71.0/30, -1, false, 0), "Combo no longer ends");
        Check(!FistRules.ActionFinished(FistAction.Godslayer, 8, -1, false, 0), "Unreleased charge ended through recovery policy");
        Check(!FistRules.ActionFinished(FistAction.Godslayer, 3, -1, true, 25.0/30-.001), "Released tail ended early");
        Check(FistRules.ActionFinished(FistAction.Godslayer, 3, -1, true, 25.0/30), "Released tail never recovers");
        Check(FistRules.ActionFinished(FistAction.FireApe, double.NaN, -1, false, 0), "Invalid clock retained action");
    }
    private static void FistChargeReleaseThreshold()
    {
        var c = new GodslayerCharge();
        Check(c.Release(38.0/30-.001,false) && !c.Full, "Early release was full");
        c.Reset(); Check(c.Release(38.0/30,false) && c.Full, "Source frame39 threshold missed");
        c.Reset(); Check(c.Release(38.0/60,true) && c.Full, "Dream Wielder threshold missed");
        Check(c.ChargeTick(100,false) == 59, "Charge exceeded source automatic release frame");
        Check(c.ChargeTick(double.NaN,false) == 0, "Invalid charge time escaped");
    }
    private static void CopiedGodslayerGhostExpiresAtReleaseEnd()
    {
        Check(!FistRules.GhostFinished(FistAction.Godslayer, false, 20, -1, 20), "Charging ghost vanished before releasing");
        Check(!FistRules.GhostFinished(FistAction.Godslayer, true, 25.0/30-.001, -1, .9), "Copied release tail was cut short");
        Check(FistRules.GhostFinished(FistAction.Godslayer, true, 25.0/30, -1, 1), "Copied ghost waited for ten-second idle expiry");
        Check(FistRules.GhostFinished(FistAction.Godslayer, true, 2, -1, 2), "Slow-frame completion retained a copied ghost");
    }
    private static void CopiedEarthbreakerGhostExpiresAtLandingEnd()
    {
        Check(!FistRules.GhostFinished(FistAction.Earthbreaker, false, 1, -1, 1), "Falling ghost disappeared before landing");
        Check(!FistRules.GhostFinished(FistAction.Earthbreaker, false, 2, 14.0/30-.001, 2), "Copied landing tail was cut short");
        Check(FistRules.GhostFinished(FistAction.Earthbreaker, false, 2, 14.0/30, 2), "Copied landing ghost returned to idle");
        Check(FistRules.GhostFinished(FistAction.Earthbreaker, false, 5, -1, 5), "Bottomless copied slam never expired");
    }
    private static void IdleGhostExpiryDefersForCopy()
    {
        Check(!FistRules.GhostFinished(FistAction.None, false, 0, -1, 9.999), "Unused ghost lifetime shortened");
        Check(FistRules.GhostFinished(FistAction.None, false, 0, -1, 10), "Unused ghost did not expire at ten seconds");
        Check(!FistRules.GhostFinished(FistAction.Earthbreaker, false, 1, -1, 11), "Idle expiry destroyed an active copy");
        Check(FistRules.GhostFinished(FistAction.Earthbreaker, false, 1.5, .5, 11.5), "Finished copy survived after idle expiry");
    }
    private static void EarthbreakerDescentIsFasterAndSamplingIndependent()
    {
        Check(Math.Abs(FistRules.EarthbreakerStep(0,16,true)-16*17.8)<1e-8, "Ground launch changed while accelerating descent");
        Check(FistRules.EarthbreakerStep(0,8,false)==0, "Air antic unexpectedly moved");
        foreach (bool ground in new[] {false,true})
        {
            double antic=FistRules.EarthbreakerAnticTicks(ground);
            double fall=FistRules.EarthbreakerStep(antic,antic+10,ground);
            Check(fall==-330 && fall==-22*10*1.5, "Descent did not become1.5x faster");
            double sum=0;
            for (int t=0;t<40;t++)sum+=FistRules.EarthbreakerStep(t,t+1,ground);
            Check(Math.Abs(sum-FistRules.EarthbreakerStep(0,40,ground))<1e-7, "Slow sampling changed total swept travel");
            Check(FistRules.EarthbreakerStep(20,20,ground)==0, "Paused/repeated observation moved the body");
        }
    }
    private static void FistPushUsesNativeSlamAndAwayDirection()
    {
        Check(FistRules.KnockbackMagnitude==2, "Fist recoil no longer matches native Quake slam");
        Check(FistRules.PushDirection(10,11,false,false)==0 && FistRules.PushDirection(10,9,true,false)==180, "Body hits pushed an enemy toward the caster");
        Check(FistRules.PushDirection(10,10,true,false)==0 && FistRules.PushDirection(10,10,false,false)==180, "Centered target lost facing fallback");
        Check(FistRules.PushDirection(20,19,true,true)==0 && FistRules.PushDirection(10,11,false,true)==180, "Passing Godslayer wave pulled the target back toward the hero");
    }
    private static void FistChargeReleaseIsLatched()
    {
        var c = new GodslayerCharge(); c.Release(.1,false);
        Check(!c.Release(10,false) && !c.Full && c.ReleasedAt == .1, "Released punch changed tier later");
        c.Reset(); Check(!c.Released && !c.Full && c.Release(2,false) && c.Full, "Recast reused partial state");
        c.Reset(); Check(!c.Release(double.NaN,false) && !c.Release(-1,false) && !c.Release(double.PositiveInfinity,false), "Invalid release accepted");
        Check(c.ChargeTick(.5,false) == c.ChargeTick(.5,false), "Paused scaled time advanced charge");
    }
    private static void FistChargeForcesSourceRelease()
    {
        foreach (bool wielder in new[] { false, true })
        {
            var c = new GodslayerCharge(); double rate = wielder ? 60 : 30;
            Check(!c.Observe(38 / rate, wielder, true), "Full damage threshold fired before original maximum charge");
            Check(!c.Observe(59 / rate - .001, wielder, true) && !c.Released, "Automatic release was early");
            Check(c.Observe(59 / rate, wielder, true) && c.Released && c.Full, "Held input did not force source frame60 release");
            Check(Math.Abs(c.ReleasedAt - 59 / rate) < 1e-8, "Automatic release lost its source clock");
            c.Reset(); Check(c.Observe(.1, wielder, false) && !c.Full, "Manual partial release changed");
        }
    }
    private static void FistChargeAutoReleaseIsLatched()
    {
        var c = new GodslayerCharge();
        Check(!c.Observe(1, false, true) && !c.Observe(1, false, true), "Repeated paused scaled time fired a wave");
        Check(c.Observe(4, false, true) && c.Full && c.ReleasedAt == 4, "Slow frame lost the release tail before wave creation");
        Check(!c.Observe(4, false, true) && !c.Observe(5, false, false) && c.ReleasedAt == 4, "Held input or later key-up fired twice");
        c.Reset(); Check(!c.Observe(double.NaN, false, true) && !c.Observe(double.PositiveInfinity, false, false), "Invalid time forced a release");
        Check(c.Observe(.2, false, false) && !c.Full, "Recast retained prior full charge");
    }
    private static void FistDirectionalSoulGate()
    {
        foreach (FistAction action in new[] { FistAction.Earthbreaker, FistAction.FireApe })
        foreach (int cost in new[] { 33, 24, 17 })
        {
            int soul = cost - 1, acquired = 0, spent = 0, canceled = 0;
            Func<bool> begin = () => { acquired++; return true; };
            Action<int> take = n => { soul -= n; spent++; };
            Check(!FistRules.TryBeginDream(action, cost, () => soul, begin, () => true, take, () => canceled++), "Insufficient Soul allowed a directional cast");
            Check(acquired == 0 && spent == 0 && canceled == 0, "Rejected cast took control or Soul");
            soul = cost;
            Check(FistRules.TryBeginDream(action, cost, () => soul, begin, () => true, take, () => canceled++), "Exact live native cost was rejected");
            Check(soul == 0 && acquired == 1 && spent == 1 && canceled == 0, "Successful cast did not charge live cost exactly once");
        }
        Check(FistRules.TryBeginDream(FistAction.Godslayer, 33, () => 0, () => true, () => true,
            _ => { throw new Exception("Neutral Dream attack spent Soul"); }, () => { }), "Godslayer incorrectly required Soul");
    }
    private static void FistSoulAcquisitionCanBeRevoked()
    {
        int soul = 33, spent = 0, canceled = 0;
        Check(!FistRules.TryBeginDream(FistAction.FireApe, 33, () => soul, () => false, () => true,
            _ => spent++, () => canceled++), "Failed native acquisition began gameplay");
        Check(spent == 0 && canceled == 0, "Failed acquisition spent Soul or forced recovery");
        Check(!FistRules.TryBeginDream(FistAction.Earthbreaker, 33, () => soul, () => { soul = 0; return true; }, () => true,
            _ => spent++, () => canceled++), "Soul loss during native cancellation was ignored");
        Check(spent == 0 && canceled == 1, "Revoked acquisition spent Soul or retained control");
        soul = 33;
        Check(!FistRules.TryBeginDream(FistAction.FireApe, 33, () => soul, () => true, () => false,
            _ => spent++, () => canceled++), "Lost ownership started the action/ghosts");
        Check(spent == 0 && canceled == 2, "Lost ownership charged Soul");
    }
    private static void FistSoulSpendingCanRevokeControl()
    {
        bool owns = true; int spent = 0, canceled = 0;
        Check(!FistRules.TryBeginDream(FistAction.FireApe, 24, () => 24, () => true, () => owns,
            n => { spent += n; owns = false; }, () => canceled++), "Native TakeMP callback lost control but still began gameplay");
        Check(spent == 24 && canceled == 1, "Spending hook cancellation duplicated cost or retained ownership");
    }
    private static void FistContactsOwnSubskills()
    {
        var h = new FistContacts();
        Check(h.TryHit(0,10,2,.3,1) && !h.TryHit(0,10,2,.3,1.299), "First source interval ignored");
        Check(h.TryHit(0,10,2,.3,1.3) && !h.TryHit(0,10,2,.3,5), "First source cap ignored");
        Check(h.TryHit(1,10,1,0,1.3) && h.TryHit(1,11,1,0,1.3), "Independent target/subskill rejected");
        Check(!h.TryHit(1,10,1,0,2), "Duplicate collider duplicated source hit");
        h.Clear(); Check(h.TryHit(1,10,1,0,2), "Recast retained old hit target");
    }
    private static void FistSourceMasksStayLocal()
    {
        Check(!FistRules.Region("effect4_1",6.99,true).HasValue, "Combo hit before source frame8");
        FireDemonRegion a=FistRules.Region("effect4_1",7,true)!.Value;
        FireDemonRegion b=FistRules.Region("effect4_1",7,false)!.Value;
        Check(Math.Abs(a.X+b.X)<1e-7 && a.Width == b.Width && a.Y == b.Y && a.Width < 230, "Mask mirror or extent invalid");
        Check(!FistRules.Region("effect4_1",25,true).HasValue && FistRules.Region("effect4_2",25,true).HasValue, "Subskill boundary wrong");
        Check(!FistRules.Region("effect5_0",68,true).HasValue && FistRules.Region("effect5_1",68,true).HasValue, "Ape roar boundary wrong");
        Check(FistRules.Region("effect2_1",0,true)!.Value.Width < 252, "Wave replaced with room sensor");
    }
    private static void FistTravelIsBounded()
    {
        Check(FistRules.AfterimageTravel(0)==0 && FistRules.AfterimageTravel(3)==0, "Travel before source shoot frame");
        Check(FistRules.AfterimageTravel(51)==360 && FistRules.AfterimageTravel(63)==540 && FistRules.AfterimageTravel(100)==540, "Source speed tiers/cap wrong");
        Check(FistRules.CloneBirthTicks.SequenceEqual(new[] {11,25,39,51}) && FistRules.CloneSeconds==10, "Clone source lifecycle changed");
    }
    private static void FistBalanceHasBoundedCloneDamage()
    {
        Check(FistRules.SpellDamage(1,false)==3 && FistRules.SpellDamage(2,true)==8, "Forward tier/Shaman mapping wrong");
        foreach (int n in new[] {5,9,13,17,21})
        {
            int full=FistRules.DreamDamage(FistAction.Godslayer,n,true,false,false);
            int weak=FistRules.DreamDamage(FistAction.Godslayer,n,false,false,false);
            int clone=FistRules.DreamDamage(FistAction.Godslayer,n,true,false,true);
            Check(full>weak && clone>0 && clone<weak, "Free Dream/clone balance invalid");
        }
    }

    private static void DeathSourceClockDoesNotRestartOrLoop()
    {
        var death = new SourceDeathClock(65, 30);
        Check(death.Begin(10) && death.Active && death.Tick(10) == 0, "Actual death did not start source tick0.");
        Check(!death.Begin(10.2), "Duplicate native death notification restarted the body/ghost.");
        Check(Math.Abs(death.Tick(10.3) - 9) < 1e-8, "Death did not follow original30Hz source time.");
        Check(death.Tick(13) >= 64 && death.Tick(13) < 65, "Finished death looped instead of holding prone pose.");
        Check(death.Active, "Source end incorrectly resumed gameplay before native recovery.");
    }

    private static void DeathPauseUsesScaledTime()
    {
        var death = new SourceDeathClock(65, 30); death.Begin(20);
        double tick = death.Tick(20.5);
        for (int i = 0; i < 20; i++) Check(death.Tick(20.5) == tick, "Paused game advanced death art.");
        Check(Math.Abs(death.Tick(20.6) - tick - 3) < 1e-8, "Resuming skipped source frames.");
    }

    private static void DeathCleanupAllowsFreshRespawn()
    {
        var death = new SourceDeathClock(65, 30); death.Begin(30); death.Clear();
        Check(!death.Active && death.Tick(31) == 0, "Scene/disable left death art active.");
        Check(!death.Begin(double.NaN) && !death.Begin(double.PositiveInfinity), "Invalid death time poisoned presentation.");
        Check(death.Begin(32) && death.Tick(32) == 0, "Respawn's next death reused old ticks.");
        Check(death.Tick(double.NaN) == 0, "Invalid sample escaped the safe source pose.");
    }

    private static void FireEyeWaitsForEndWindow()
    {
        var clock = new FireEyeCastClock(); clock.Observe(true, -1, 10);
        Check(clock.Tick(10.1) < 0, "Startup showed the casting overlay before native drain started.");
        clock.Observe(true, .891, 10.25);
        Check(clock.Tick(10.4) < 0, "Casting flames started before the final0.7s window.");
        Check(Math.Abs(clock.Tick(10.441)) < 1e-8, "Source opening is not scheduled from native completion.");
        Check(Math.Abs(clock.Tick(10.541) - 3) < 1e-8, "Delayed opening changed original30Hz speed.");
        Check(Math.Abs(clock.Tick(11.141) - 21) < 1e-8, "Source end did not align with native focus.");
    }

    private static void FireEyeDeadlineUsesNativeRates()
    {
        // Native normal/Quick/Deep/combined rates and a shorter Unn charge.
        foreach (double remaining in new[] { .891, .594, 1.47, .98, .297 })
        {
            var clock = new FireEyeCastClock(); clock.Observe(true, remaining, 20);
            double begins = 20 + remaining - .7;
            double sample = Math.Max(20, begins) + .05;
            Check(Math.Abs(clock.Tick(sample + .1) - clock.Tick(sample) - 3) < 1e-8, "Charm stretched source speed.");
            Check(Math.Abs(clock.Tick(20 + remaining) - 21) < 1e-8, "Charm timing did not end-align.");
            if (remaining < .7) Check(clock.Tick(20) > 0, "Short charge did not select the source tail.");
            else Check(clock.Tick(20) < 0, "Long charge played early flames.");
        }
    }

    private static void FireEyeRepeatedObserversDoNotStretchSourceFrames()
    {
        var clock = new FireEyeCastClock(); clock.Observe(true, 1, 20);
        foreach (double time in new[] { 20.0, 20.1, 20.1, 20.3, 20.6 }) clock.Observe(true, 1, time);
        Check(Math.Abs(clock.Tick(21) - 21) < 1e-8, "Observers restarted the native deadline.");
        Check(clock.Tick(22) > 21, "Completed overlay looped while native state was exiting.");
    }

    private static void FireEyeVisualPauseUsesScaledTime()
    {
        var clock = new FireEyeCastClock(); clock.Observe(true, .7, 30);
        double pausedTick = clock.Tick(30.2);
        for (int i = 0; i < 20; i++) { clock.Observe(true, .5, 30.2); Check(clock.Tick(30.2) == pausedTick, "Pause advanced source animation."); }
        Check(Math.Abs(clock.Tick(30.3) - pausedTick - 3) < 1e-8, "Resume added paused time.");
    }

    private static void FireEyeCancelledAndRecastClockIsFresh()
    {
        var clock = new FireEyeCastClock(); clock.Observe(true, .7, 40);
        clock.Observe(false, 0, 40.1);
        Check(clock.Tick(40.2) < 0, "Cancelled cast retained its old overlay.");
        clock.Observe(true, -1, 40.3);
        Check(clock.Tick(40.4) < 0, "Rapid rehold reused the old deadline during startup.");
        clock.Observe(true, .9, 40.5);
        Check(Math.Abs(clock.Tick(41.4) - 21) < 1e-8, "Recast failed to use fresh native timing.");
        clock.Clear(); Check(clock.Tick(41) < 0, "Death/detach retained casting time.");
        clock.Observe(true, .7, double.NaN); Check(clock.Tick(42) < 0, "Invalid clock poisoned a later cast.");
        clock.Observe(true, double.NaN, 42); Check(clock.Tick(42) < 0, "Invalid native deadline scheduled art.");
        clock.Observe(true, .7, 43); Check(Math.Abs(clock.Tick(43)) < 1e-8, "New cast failed after cleanup.");
        clock.Observe(false, 0, 43.1); Check(clock.Tick(43.1) < 0, "Early native completion left a casting tail.");
    }

    private static void FireDemonSourceTravelIsBounded()
    {
        Check(new FireDemonTimeline(0).TravelPixels == 0, "Preparation moved.");
        Check(new FireDemonTimeline(5.0 / 30).TravelPixels == 0, "Travel began before original shoot frame.");
        Check(Math.Abs(new FireDemonTimeline(20.0 / 30).TravelPixels - 75) < 1e-8, "Original speed50 and physics step0.1 were lost.");
        Check(Math.Abs(new FireDemonTimeline(36.0 / 30).TravelPixels - 155) < 1e-8, "Finisher returned to cast start instead of moved root.");
        Check(new FireDemonTimeline(55.0 / 30).TravelPixels == 155, "Finisher kept moving after original stop.");
    }

    private static void FireDemonTravelDoesNotDependOnSampling()
    {
        var travel = new FireDemonTravel(); double total = 0;
        foreach (double time in new[] { 0, .1, .2, .2, .7, 1.2, 1.2, 1.5 })
            total += travel.Advance(new FireDemonTimeline(time));
        Check(Math.Abs(total - 155) < 1e-8, "Repeated observers or a lag step changed displacement.");
        var sparse = new FireDemonTravel();
        Check(sparse.Advance(new FireDemonTimeline(1.5)) == total, "Sparse and dense sampling differ.");
        Check(travel.Advance(new FireDemonTimeline(.7)) == 0, "Repeated older time restored consumed distance.");
        travel.Reset();
        Check(Math.Abs(travel.Advance(new FireDemonTimeline(1.2)) - 155) < 1e-8, "A new cast did not reset travel.");
        var blocked = new FireDemonTravel();
        blocked.Advance(new FireDemonTimeline(.7)); // Terrain rejects the whole requested distance.
        Check(blocked.Advance(new FireDemonTimeline(.7)) == 0, "Blocked distance was banked for an immediate teleport.");
        Check(Math.Abs(blocked.Advance(new FireDemonTimeline(1.2)) - 75) < 1e-8, "Blocked displacement leaked into a later move.");
    }

    private static void BloodEyeVisualClockFollowsLifetime()
    {
        var buff = new BloodthirstyBuff();
        Check(buff.VisualTick(10) == 0, "Inactive aura clock was running.");
        buff.Activate(10);
        Check(buff.VisualTick(10) == 0 && buff.VisualTick(11) == 30, "Aura is not on scaled source clock.");
        Check(buff.Active(14.99) && buff.VisualTick(14.99) > 149, "Aura ended before the buff.");
        Check(!buff.Active(15) && buff.VisualTick(15) == 0, "Expired aura retained playback.");
        buff.Activate(15);
        Check(buff.VisualTick(15) == 0, "Refreshed aura did not restart.");
        buff.Clear();
        Check(!buff.Active(15.1) && buff.VisualTick(15.1) == 0, "Detached/dead hero retained aura.");
    }

    private static ComboTimeline NewCombo() => new ComboTimeline(new[] {
        new ComboStage("attack1", 12, 2, 1, new[] { new HitWindow(4, 7) }),
        new ComboStage("attack2", 15, 2, 1, new[] { new HitWindow(5, 8) }),
        new ComboStage("attack3", 18, 3, 1, new[] { new HitWindow(3, 5), new HitWindow(11, 14) }),
        new ComboStage("attack4", 20, 5, 1, new[] { new HitWindow(5, 8) }) }, 30, .35);

    private static void BloodEyeOnlyHealsRealDamage()
    {
        var buff = new BloodthirstyBuff();
        Check(!buff.TryHeal(buff.Token, 10, 20, 10, 3, 5), "Uncharged eye healed.");
        buff.Activate(10); long token = buff.Token;
        Check(!buff.TryHeal(token, 10, 20, 20, 3, 5), "Blocked/evaded attack healed.");
        Check(!buff.TryHeal(token, 10, 0, -1, 3, 5), "Already-dead enemy healed.");
        Check(!buff.TryHeal(token, 10, 20, 19, 0, 5), "Dead hero healed.");
        Check(buff.TryHeal(token, 10, 20, 0, 3, 5), "Real killing blow failed to heal one HP.");
        Check(!buff.TryHeal(token, 10, 20, 0, 3, 5), "Reentrant/duplicate callback healed twice.");
    }

    private static void BloodEyeCooldownIsGlobal()
    {
        var buff = new BloodthirstyBuff(); buff.Activate(4); long token = buff.Token;
        Check(buff.TryHeal(token, 4, 100, 90, 1, 9), "First attack failed.");
        Check(!buff.TryHeal(token, 4.9999, 200, 150, 2, 9), "A different target/attack bypassed the one-second cooldown.");
        Check(buff.TryHeal(token, 5, 200, 150, 2, 9), "Exact one-second boundary rejected.");
        Check(!buff.TryHeal(token, 5, 300, 200, 3, 9), "Simultaneous multi-target hit healed twice.");
    }

    private static void BloodEyeExpiryDoesNotHeal()
    {
        var buff = new BloodthirstyBuff(); buff.Activate(20); long token = buff.Token;
        Check(buff.Active(20) && buff.Active(24.9999) && !buff.Active(25), "Five-second half-open duration changed.");
        Check(buff.TryHeal(token, 24.9999, 100, 90, 1, 9), "Hit just before expiry failed.");
        Check(!buff.TryHeal(token, 25, 100, 90, 2, 9) && !buff.TryHeal(token, 26, 100, 90, 2, 9), "Expiry retained healing.");
    }

    private static void BloodEyeRefreshPreservesCooldown()
    {
        var buff = new BloodthirstyBuff(); buff.Activate(0); long old = buff.Token;
        Check(buff.TryHeal(old, .2, 50, 40, 1, 9), "Initial hit failed.");
        buff.Activate(.5); long fresh = buff.Token;
        Check(!buff.TryHeal(old, 1.2, 50, 40, 2, 9), "Old cast callback survived refresh.");
        Check(!buff.TryHeal(fresh, .5, 50, 40, 2, 9), "Refresh bypassed cooldown.");
        Check(buff.TryHeal(fresh, 1.2, 50, 40, 2, 9), "Refresh lost the original cooldown deadline.");
        Check(buff.Active(5.4999) && !buff.Active(5.5), "Refresh stacked duration instead of replacing expiry.");
    }

    private static void BloodEyeClearRejectsOldCallbacks()
    {
        var buff = new BloodthirstyBuff(); buff.Activate(0); long old = buff.Token; buff.Clear();
        Check(!buff.Active(0) && !buff.TryHeal(old, 0, 100, 90, 1, 5), "Death/scene/detach left the buff active.");
        buff.Activate(1);
        Check(!buff.TryHeal(old, 1, 100, 90, 1, 5) && buff.TryHeal(buff.Token, 1, 100, 90, 1, 5), "Old callbacks damaged a new lifetime.");
    }

    private static void BloodEyeFullHealthDoesNotConsumeProc()
    {
        var buff = new BloodthirstyBuff(); buff.Activate(0); long token = buff.Token;
        Check(!buff.TryHeal(token, 0, 50, 40, 5, 5), "Full HP attack consumed healing.");
        Check(buff.TryHeal(token, .01, 50, 40, 4, 5), "Full HP wasted the next valid proc.");
    }

    private static void BloodEyeRejectsInvalidTime()
    {
        var buff = new BloodthirstyBuff(); buff.Activate(double.NaN); buff.Activate(double.PositiveInfinity);
        Check(!buff.Active(0), "Invalid activation created a buff."); buff.Activate(2);
        foreach (double now in new[] { 1.9, double.NaN, double.PositiveInfinity, double.NegativeInfinity })
            Check(!buff.TryHeal(buff.Token, now, 50, 40, 1, 5), "Invalid/before-activation hit healed.");
        Check(buff.TryHeal(buff.Token, 2, 50, 40, 1, 5), "Invalid hits consumed the real proc.");
    }

    private static void StormUsesSourceClock()
    {
        Check(!new FlameStormClock(15.999 / 30).Complete && new FlameStormClock(16.0 / 30).Complete, "Storm did not end after the original 16 ticks.");
        Check(new FlameStormClock(3).Complete, "Lag replayed the storm.");
        Check(new FlameStormClock(-1).Tick == 0 && new FlameStormClock(double.NaN).Complete && new FlameStormClock(double.PositiveInfinity).Complete, "Invalid clock held movement indefinitely.");
    }

    private static void StormContactsAreBounded()
    {
        var hits = new SpellHitLedger(FlameStormRules.HitCap); long token = hits.Begin();
        for (int i = 0; i < 5; i++)
        {
            Check(hits.TryAirHit(token, 1, i * .1), "Storm lost a valid contact.");
            Check(!hits.TryAirHit(token, 1, i * .1 + .05), "Storm ignored the source 100ms cooldown.");
        }
        Check(!hits.TryAirHit(token, 1, .5), "Storm exceeded five contacts.");
        Check(hits.TryAirHit(token, 2, .5) && !hits.TryAirHit(token, 2, .5), "Targets shared caps or a lag frame generated catch-up hits.");
        hits.Stop(token); long fresh = hits.Begin(); hits.Stop(token);
        Check(!hits.TryAirHit(token, 2, .6) && hits.TryAirHit(fresh, 1, .6), "Stale storm callback changed a new cast.");
    }

    private static void StormUsesFixedSpellDamage()
    {
        Check(FlameStormRules.Damage(1, false) * 5 == 35 && FlameStormRules.Damage(2, false) * 5 == 55, "Storm tier balance changed.");
        Check(FlameStormRules.Damage(1, true) * 5 == 55 && FlameStormRules.Damage(2, true) * 5 == 85, "Storm Shaman rounding changed.");
    }

    private static void StormUsesOriginalLocalMask()
    {
        FireDemonRegion right = FlameStormRules.Region(true), left = FlameStormRules.Region(false);
        Check(Math.Abs(right.X - -6.4639412) < .00001 && Math.Abs(right.Y - 35.0111057) < .00001, "Source root/Flash Y-down conversion changed.");
        Check(Math.Abs(right.Width - 402.9517788) < .00001 && Math.Abs(right.Height - 170.0001534) < .00001, "Original source mask dimensions changed.");
        Check(left.X == -right.X && left.Y == right.Y && left.Width == right.Width && left.Height == right.Height, "Storm facing changed vertical position or reach.");
    }

    private static void Check(bool condition, string message)
    { if (!condition) throw new InvalidOperationException(message); }

    // Attack-layer collision matrix read from the actual 1.5.78.11833 player assets.
    private static int NativeSkillMask => SkillTargetPolicy.QueryMask(unchecked((int)2184845768u));

    private static FireDemonTimeline AtTick(double tick) => new FireDemonTimeline(tick / 30);

    private static void FireDemonFinishesWithoutLanding()
    {
        Check(!AtTick(4.999).Air && !AtTick(4.999).Finisher, "Effect spawned before source frame 5.");
        Check(AtTick(5).Air && AtTick(5).AirTick == 0, "Air did not start at source frame 5.");
        Check(AtTick(35.999).Air && !AtTick(35.999).Finisher, "Air ended early.");
        Check(!AtTick(36).Air && AtTick(36).Finisher && AtTick(36).FinisherTick == 0, "Finisher waited for landing instead of air expiry.");
        Check(AtTick(55.999).Finisher && !AtTick(55.999).Complete, "Finisher ended early.");
        Check(AtTick(56).Complete && !AtTick(56).Finisher, "Source cast did not end after 20 finisher ticks.");
    }

    private static void FireDemonLagDoesNotExtendEffects()
    {
        Check(AtTick(44).Finisher && Math.Abs(AtTick(44).FinisherTick - 8) < .000001, "Delayed observation restarted the finisher clock.");
        Check(AtTick(90).Complete && !AtTick(90).Air && !AtTick(90).Finisher, "Expired effects replayed after lag.");
        Check(new FireDemonTimeline(double.NaN).Complete && new FireDemonTimeline(double.PositiveInfinity).Complete, "Invalid clock retained cast protection.");
    }

    private static void FireDemonOriginalRegionsMirrorAroundSourceRoot()
    {
        FireDemonRegion right = FireDemonGeometry.Air(true), left = FireDemonGeometry.Air(false);
        double rightMin = FireDemonGeometry.AirSpawnX + right.X - right.Width / 2;
        double rightMax = FireDemonGeometry.AirSpawnX + right.X + right.Width / 2;
        Check(Math.Abs(rightMin - -41.94691) < .00001 && Math.Abs(rightMax - 401.00243) < .00001, "Air region was recentered/enlarged instead of using source spawn and mask.");
        Check(Math.Abs(FireDemonGeometry.AirSpawnY + right.Y - right.Height / 2 - 48.020165) < .00001, "Source Y-down conversion or vertical registration changed.");
        Check(left.X == -right.X && left.Y == right.Y && left.Width == right.Width && left.Height == right.Height, "Facing changed reach or vertical placement.");
        Check(Math.Abs(-FireDemonGeometry.AirSpawnX + left.X + left.Width / 2 + rightMin) < .00001, "Left-facing source spawn failed to mirror.");
        FireDemonRegion finisher = FireDemonGeometry.Finisher(true);
        Check(Math.Abs(finisher.X - finisher.Width / 2 - -131.950705) < .00001 && Math.Abs(finisher.Y + finisher.Height / 2 - 194.9888) < .00001, "Finisher lost original mask placement.");
        Check(FireDemonGeometry.Finisher(false).X == -finisher.X, "Finisher did not mirror its local source offset.");
    }

    private static void FireDemonSourceFinisherRetainsCastProtection()
    {
        var hits = new SpellHitLedger(); long token = hits.Begin();
        Check(hits.Active && !hits.FinisherStarted, "Preparation was unprotected.");
        Check(AtTick(36).Finisher && hits.BeginFinisher(token), "Source expiry did not enter finisher.");
        Check(hits.Active && hits.TryFinisher(token, 1), "Airborne finisher ended the protected cast.");
        Check(!hits.TryAirHit(token, 1, 1.3), "Old air callbacks damaged during the finisher.");
        if (AtTick(56).Complete) hits.Stop(token);
        Check(!hits.Active && !hits.TryFinisher(token, 2), "Completed source cast retained damage/protection.");
    }

    private static void EnemySensorsCannotConsumeSkillHits()
    {
        var dash = new DashHitLedger(); long dashToken = dash.Begin();
        var spell = new SpellHitLedger(); long spellToken = spell.Begin();
        // Hornet Refight/A Sphere Range; Angry Buzzer Alert Range; terrain and attack children.
        foreach (int layer in new[] { 13, 14, 15, 22 })
        {
            bool accepted = SkillTargetPolicy.Allows(layer, NativeSkillMask, true);
            Check(!accepted, "A detector/weapon resolved to its enemy ancestor.");
            if (accepted) { dash.TryHit(dashToken, 1); spell.TryAirHit(spellToken, 1, 0); }
        }
        Check(SkillTargetPolicy.Allows(11, NativeSkillMask, true), "Real Hornet/Buzzer body was rejected.");
        Check(dash.TryHit(dashToken, 1) && spell.TryAirHit(spellToken, 1, 0), "Rejected sensors consumed real body contact.");
    }

    private static void BossWeaponCannotRouteDamageToParent()
    {
        // Hornet's Needle Tink uses Attack (17), which the native matrix permits.
        Check(SkillTargetPolicy.Allows(17, NativeSkillMask, false), "Native non-health Attack interaction was lost.");
        Check(!SkillTargetPolicy.Allows(17, NativeSkillMask, true), "Needle Tink could damage its parent Hornet.");
        Check(!SkillTargetPolicy.Allows(12, NativeSkillMask, true), "A projectile could damage its enemy ancestor.");
    }

    private static void SkillContactsRetainNativeInteractions()
    {
        Check(SkillTargetPolicy.Allows(19, NativeSkillMask, false), "Interactive Object responder was lost.");
        Check(SkillTargetPolicy.Allows(11, NativeSkillMask, true), "An enemy hurtbox was lost.");
        foreach (int layer in new[] { 9, 20, 26, 31 })
            Check(!SkillTargetPolicy.Allows(layer, SkillTargetPolicy.QueryMask(-1), false), "Native ignored layer accepted.");
        Check(!SkillTargetPolicy.Allows(11, SkillTargetPolicy.QueryMask(0), true), "Native collision-matrix disable ignored.");
        Check(!SkillTargetPolicy.Allows(-1, NativeSkillMask, false) && !SkillTargetPolicy.Allows(32, NativeSkillMask, false), "Invalid layer wrapped around.");
    }

    private static void FireDemonContactCooldownAndTargetIndependence()
    {
        var hits = new SpellHitLedger(); long token = hits.Begin();
        Check(hits.TryAirHit(token, 1, 1), "Initial contact was lost.");
        Check(!hits.TryAirHit(token, 1, 1) && !hits.TryAirHit(token, 1, 1.099), "Duplicate collider or early contact caused damage.");
        Check(hits.TryAirHit(token, 2, 1.099), "One target consumed another target's cooldown.");
        Check(hits.TryAirHit(token, 1, 1.1), "Exact 100ms contact deadline was rejected.");
        Check(!hits.TryAirHit(token, 1, double.NaN) && !hits.TryAirHit(token, 3, double.PositiveInfinity), "Invalid clock accepted.");
    }

    private static void FireDemonContactCapAndFinisher()
    {
        var hits = new SpellHitLedger(); long token = hits.Begin();
        for (int i = 0; i < 11; i++) Check(hits.TryAirHit(token, 1, i * .1), "Valid source-style contact was rejected.");
        Check(!hits.TryAirHit(token, 1, 1.1), "Air damage exceeded the per-target cap of 11.");
        hits.BeginFinisher(token);
        Check(hits.TryFinisher(token, 1) && !hits.TryFinisher(token, 1), "Finisher did not hit exactly once independently of air contacts.");
        Check(hits.TryFinisher(token, 2), "Finisher was capped globally instead of per target.");
    }

    private static void FireDemonLagDoesNotCatchUpDamage()
    {
        var hits = new SpellHitLedger(); long token = hits.Begin();
        Check(hits.TryAirHit(token, 1, 0) && hits.TryAirHit(token, 1, .8), "Current contact after lag was lost.");
        for (int i = 0; i < 20; i++) Check(!hits.TryAirHit(token, 1, .8), "Lag generated a catch-up damage burst.");
        Check(hits.TryAirHit(token, 1, .9), "Contact cooldown failed after lag.");
    }

    private static void FireDemonCancellationAndRecast()
    {
        var hits = new SpellHitLedger(); long old = hits.Begin();
        hits.TryAirHit(old, 1, 0); hits.BeginFinisher(old); hits.TryFinisher(old, 1); hits.Stop(old);
        Check(!hits.TryAirHit(old, 2, 1) && !hits.TryFinisher(old, 2), "Canceled spell retained damage.");
        long current = hits.Begin(); hits.Stop(old);
        Check(hits.Owns(current) && !hits.TryAirHit(old, 3, 1) && !hits.TryFinisher(old, 3), "Old callbacks affected a newer cast.");
        Check(hits.TryAirHit(current, 1, 1), "Previous air target records survived a recast.");
        hits.BeginFinisher(current);
        Check(hits.TryFinisher(current, 1), "Previous finisher target records survived a recast.");
    }

    private static void FireDemonFinisherRevealsWithoutEndingProtection()
    {
        var hits = new SpellHitLedger(); long token = hits.Begin();
        Check(hits.Active && hits.HidesBody, "Cast did not start hidden/protected.");
        Check(!hits.TryFinisher(token, 7), "Finisher damaged before its phase.");
        Check(hits.TryAirHit(token, 7, 0), "Hidden air phase lost damage.");
        Check(hits.BeginFinisher(token), "Finisher transition failed.");
        Check(hits.Active && !hits.HidesBody, "Reappearing ended cast protection or kept the body hidden.");
        Check(!hits.TryAirHit(token, 8, 1), "Old air callbacks leaked into the revealed finisher.");
        Check(hits.TryFinisher(token, 7), "Air target could not take the finisher.");
        hits.Stop(token);
        Check(!hits.Active && !hits.HidesBody, "Completed cast retained protection/hidden body.");
    }

    private static void FireDemonOldFinisherCannotRevealNewCast()
    {
        var hits = new SpellHitLedger(); long old = hits.Begin(); hits.Stop(old);
        Check(!hits.Active && !hits.HidesBody, "Interrupted cast retained hidden/protected state.");
        long current = hits.Begin();
        Check(!hits.BeginFinisher(old), "Stale callback entered the new finisher.");
        hits.Stop(old);
        Check(hits.Active && hits.HidesBody && hits.Owns(current), "Old callbacks revealed or unprotected a new cast.");
    }

    private static void FireDemonFixedSpellBalance()
    {
        int[,] expected = { { 1, 0, 2, 14, 36 }, { 2, 0, 3, 22, 55 }, { 1, 1, 3, 21, 54 }, { 2, 1, 5, 33, 88 } };
        for (int i = 0; i < expected.GetLength(0); i++)
        {
            var damage = new FireDemonDamage(expected[i, 0], expected[i, 1] == 1);
            Check(damage.Air == expected[i, 2] && damage.Finisher == expected[i, 3] && damage.FullContactTotal == expected[i, 4], "Spell upgrade/Shaman damage or rounding changed.");
        }
    }

    private static void DashHitsEachResponderOnce()
    {
        var dash = new DashHitLedger(); long token = dash.Begin();
        Check(dash.TryHit(token, 7), "First dash hit was lost.");
        Check(!dash.TryHit(token, 7), "Multiple colliders/physics samples produced duplicate dash damage.");
        Check(dash.TryHit(token, 8), "Hitting one enemy blocked another enemy along the dash.");
    }

    private static void DashCancellationRejectsOldCallbacks()
    {
        var dash = new DashHitLedger(); long token = dash.Begin(); dash.Stop(token);
        Check(!dash.Active && !dash.TryHit(token, 7), "Canceled dash retained damage.");
    }

    private static void NewDashClearsTargetsWithoutAcceptingStaleHits()
    {
        var dash = new DashHitLedger(); long old = dash.Begin(); dash.TryHit(old, 7);
        long current = dash.Begin(); dash.Stop(old);
        Check(dash.Active && !dash.TryHit(old, 8), "Old callback damaged or stopped the new dash.");
        Check(dash.TryHit(current, 7), "A new dash cannot hit a previously hit enemy.");
    }
    private static bool Has(IEnumerable<ComboEvent> events, ComboEventKind kind, int stage = -1) => events.Any(e => e.Kind == kind && (stage < 0 || e.Stage == stage));

    private static void SinglePressDoesNotAutoChain()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1);
        var events = combo.Advance(.4, 1);
        Check(!combo.Active && Has(events, ComboEventKind.StageEnded) && !Has(events, ComboEventKind.StageStarted), "One press started extra attacks.");
    }
    private static void FourPressesFollowFourStages()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1);
        double now = 0;
        for (int stage = 0; stage < 4; stage++)
        {
            Check(combo.StageIndex == stage, "Wrong stage sequence.");
            double end = now + combo.Duration;
            if (stage < 3) combo.Press(now + .2, 1);
            var changes = combo.Advance(end + .000001, 1);
            if (stage < 3) Check(Has(changes, ComboEventKind.StageStarted, stage + 1), "Buffered stage was not emitted.");
            now = end + .000001;
        }
        Check(!combo.Active, "Fourth stage did not finish.");
    }
    private static void BufferIsBoundedAndEarlyPressIsRejected()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); combo.Press(.001, 1);
        Check(!combo.Buffered, "Premature input survived the buffer opening.");
        for (int i = 0; i < 20; i++) combo.Press(.15, 1);
        Check(combo.Buffered, "Valid input missing.");
        combo.Advance(.4, 1);
        Check(combo.StageIndex == 1 && !combo.Buffered, "More than one pending input carried into stage two.");
        combo.Advance(.91, 1); Check(!combo.Active, "Spammed stage-one inputs leaked into stage three.");
    }
    private static void GraceHasAnInclusiveDeadline()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); combo.Advance(.4, 1); combo.Press(.75, 1);
        Check(combo.StageIndex == 1, "Exact grace deadline reset chain.");
        combo = NewCombo(); combo.Press(0, 1); combo.Advance(.4, 1); combo.Press(.750001, 1);
        Check(combo.StageIndex == 0, "Expired chain survived.");
    }
    private static void CancellationInvalidatesOwnership()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); long token = combo.Token;
        combo.Advance(.14, 1); Check(combo.TryHit(token, 0, 7), "Expected first hit.");
        combo.Press(.2, 1); combo.Cancel();
        Check(!combo.Active && !combo.Buffered && !combo.TryHit(token, 0, 8), "Cancel left damage/buffer active.");
        combo.Press(.21, 1); combo.Advance(.35, 1);
        Check(combo.StageIndex == 0 && combo.Token != token && !combo.TryHit(token, 0, 9), "Stale callback can hit a new stage.");
        Check(combo.TryHit(combo.Token, 0, 7), "Old dedupe memory survived cancellation.");
    }
    private static void DualWindowsDeduplicateActualTargets()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1); combo.Press(.2, 1); combo.Advance(.4, 1);
        combo.Press(.6, 1); combo.Advance(.9, 1); long token = combo.Token;
        combo.Advance(1.001, 1);
        Check(combo.StageIndex == 2 && combo.WindowIndex == 0, "Third stage first window missing.");
        Check(combo.TryHit(token, 0, 71) && !combo.TryHit(token, 0, 71) && combo.TryHit(token, 0, 72), "Repeated collider hit or multi-target rejection.");
        combo.Advance(1.1, 1); Check(!combo.TryHit(token, 0, 73), "Closed window damaged a target.");
        combo.Advance(1.28, 1);
        Check(combo.WindowIndex == 1 && combo.TryHit(token, 1, 71) && !combo.TryHit(token, 1, 71), "Second window did not independently rearm the target.");
        Check(!combo.TryHit(token, 0, 74), "Old window callback leaked into second pulse.");
    }
    private static void QuickSlashScalesEveryStageWindow()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, .6);
        Check(Math.Abs(combo.Duration - .24) < 1e-9, "Stage duration ignored clock scale.");
        combo.Advance(.079, .6); Check(combo.WindowIndex == -1, "Window opened early.");
        combo.Advance(.081, .6); Check(combo.WindowIndex == 0, "Scaled hit window missing.");
        combo.Advance(.14, .6); Check(combo.WindowIndex == -1, "Scaled close window missing.");
        combo.Press(.15, .6); combo.Advance(.24, .6);
        Check(combo.StageIndex == 1 && Math.Abs(combo.Duration - .3) < 1e-9, "Next stage lost Quick Slash clock.");
    }
    private static void PhysicsClockSurvivesSlowRendering()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, .6);
        int physicsHits = 0;
        // Render at 10 FPS, but advance gameplay once per 20ms physics step as the runtime does.
        for (int step = 1; step <= 12; step++)
        {
            combo.Advance(step * .02, .6);
            if (combo.TryHit(combo.Token, combo.WindowIndex, 5)) physicsHits++;
        }
        Check(physicsHits == 1, "Short active window disappeared or repeated under slow rendering.");
    }
    private static void CompletionDoesNotRetainStageFourInput()
    {
        ComboTimeline combo = NewCombo(); combo.Press(0, 1);
        double now = 0;
        for (int i = 0; i < 4; i++) { combo.Press(now + .2, 1); now += combo.Duration + .000001; combo.Advance(now, 1); }
        Check(!combo.Active && !combo.Buffered, "Fourth-stage input began another chain automatically.");
        combo.Press(now + .01, 1); Check(combo.StageIndex == 0, "Next explicit press did not reset to attack one.");
    }

    private static void ContactCleanupWaitsForNativeEnumeration()
    {
        var cleanup = new DeferredContactCleanup<object>();
        object source = new object(), other = new object();
        var contacts = new List<int> { 1, 2, 3 };
        var damaged = new List<int>();
        cleanup.Enter(source);
        try
        {
            for (int i = contacts.Count - 1; i >= 0; i--)
            {
                if (cleanup.IsPending(source)) continue;
                damaged.Add(contacts[i]);
                Check(!cleanup.Request(source), "Active contact enumeration was cleared inside Hit.");
                Check(cleanup.Request(other) && !cleanup.IsPending(other), "Cleanup leaked into another source.");
            }
        }
        finally { if (cleanup.Exit(source)) contacts.Clear(); }
        Check(damaged.SequenceEqual(new[] { 3 }) && contacts.Count == 0, "Canceled contacts leaked damage or survived final cleanup.");
        Check(!cleanup.HasActiveIterations && !cleanup.IsPending(source), "Cleanup guard survived the old transaction.");
        // The same native source may immediately begin an original airborne attack.
        cleanup.Enter(source);
        Check(!cleanup.IsPending(source), "New native attack inherited cancellation suppression.");
        cleanup.Enter(source); cleanup.Request(source);
        Check(!cleanup.Exit(source) && cleanup.IsPending(source), "Nested callbacks flushed an active outer iterator.");
        Check(cleanup.Exit(source) && !cleanup.HasActiveIterations, "Outermost callback did not release pending contacts.");
    }
}
