"""Original Wukong staff arcs, with an offline center-rotated downward variant."""
from dataclasses import replace
import math

from legacy_dragonbones import Affine
from single_bone_effects import SingleBoneEffects


def nail_samples(sampler, source, rotation_center):
    if len(rotation_center) != 2 or any(not math.isfinite(v) for v in rotation_center):
        raise ValueError("Invalid downward slash rotation center")
    effects = SingleBoneEffects(sampler, source, "nail/")
    clips = {}
    names = {"nailAttack1": ("attack1", 12), "nailAttack2": ("attack2", 15),
             "nailAttack3": ("attack3", 18), "nailAttack4": ("attack4", 20),
             "nailAir": ("jumpAttack", 10), "nailUp": ("effect1", 15)}
    for output, (name, duration) in names.items():
        overlay = effects.frames(name, "nail_fx")
        if len(overlay) != duration or sampler.animation(sampler.profile["armature"], name)["duration"] != duration:
            raise ValueError("Unexpected original nail body/overlay duration")
        clips[output] = [sampler.sample(name, tick) + overlay[tick] for tick in range(duration)]
    rotation = Affine(a=-1, d=-1, tx=2*rotation_center[0], ty=2*rotation_center[1])
    up = effects.frames("effect1", "nail_fx")
    # Keep the original upright airborne attack. Only the arc rotates, around the
    # fixed character center, never around each frame's changing opaque bounds.
    clips["nailDown"] = [sampler.sample("jumpAttack", tick*10//15) +
                         [replace(d, matrix=rotation.then_local(d.matrix), slot_path=("nail_down_fx",)) for d in up[tick]]
                         for tick in range(15)]
    return clips


def nail_arc_samples(sampler, source, rotation_center):
    """Reuse exact original overlay Draws without the character/staff layer."""
    composites = nail_samples(sampler, source, rotation_center)
    names = {"nailAttack1": "nailArc1", "nailAttack2": "nailArc2", "nailAttack3": "nailArc3",
             "nailAttack4": "nailArc4", "nailAir": "nailArcAir", "nailUp": "nailArcUp", "nailDown": "nailArcDown"}
    return {names[name]: [[draw for draw in frame if draw.slot_path in (("nail_fx",), ("nail_down_fx",))]
                          for frame in frames] for name, frames in composites.items()}
