import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";

/**
 * Cinematic camera move: a perspective container that slowly pushes in and
 * drifts in 3D, with an optional punchy whip-in on entry. Wrap a phone (or any
 * hero element) in this for the "action-trailer" feel.
 */
export const CameraRig: React.FC<{
  children: React.ReactNode;
  /** Scale at scene start → end (slow push-in). */
  push?: [number, number];
  /** Max yaw / pitch degrees of the idle drift. */
  tilt?: number;
  /** Whip-in direction on entry; 0 disables. */
  whip?: number;
  durationInFrames?: number;
}> = ({ children, push = [1.0, 1.08], tilt = 4, whip = 1, durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames: compDur } = useVideoConfig();
  const dur = durationInFrames ?? compDur;

  const enter = spring({ frame, fps, config: { damping: 13, mass: 0.8, stiffness: 130 } });
  const scale = interpolate(frame, [0, dur], push, { extrapolateRight: "clamp" }) *
    interpolate(enter, [0, 1], [0.9, 1]);
  const yaw = Math.sin(frame / 45) * tilt + interpolate(enter, [0, 1], [whip * 20, 0]);
  const pitch = Math.cos(frame / 60) * (tilt * 0.55);
  const blur = interpolate(enter, [0, 1], [whip * 9, 0]);

  return (
    <div style={{ perspective: 1600, transformStyle: "preserve-3d" }}>
      <div
        style={{
          transform: `scale(${scale}) rotateY(${yaw}deg) rotateX(${pitch}deg)`,
          transformStyle: "preserve-3d",
          filter: blur > 0.4 ? `blur(${blur}px)` : undefined,
          willChange: "transform",
        }}
      >
        {children}
      </div>
    </div>
  );
};
