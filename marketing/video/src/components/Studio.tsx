import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

/**
 * Cinematic dark-studio backdrop — the ref2 "product on a stage in a dark
 * room" look. A near-black environment with a soft horizon, two slow-drifting
 * brand light pools, volumetric top light, and a heavy vignette. Meant to sit
 * *behind* the Podium + HeroPhone.
 */
export const Studio: React.FC<{
  /** Accent hue for the environment light pools + horizon. */
  hue?: string;
  /** Secondary rim hue on the opposite side. */
  hue2?: string;
  /** 0 = dead still, 1 = full idle drift. */
  life?: number;
}> = ({ hue = COLORS.indigoSoft, hue2 = COLORS.sky, life = 1 }) => {
  const frame = useCurrentFrame();
  const drift = Math.sin(frame / 70) * 3 * life;
  const pulse = 0.5 + 0.5 * Math.sin(frame / 55);

  return (
    <AbsoluteFill style={{ background: "#03050b" }}>
      {/* Environment base — a subtle vertical fall-off, darkest at the floor. */}
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(120% 90% at 50% 8%, #0b1226 0%, #060a16 45%, #03050b 100%)",
        }}
      />

      {/* Horizon glow — a wide, low band of light where the back wall meets floor. */}
      <AbsoluteFill
        style={{
          background: `radial-gradient(80% 42% at 50% 62%, ${hue}2e 0%, transparent 60%)`,
          mixBlendMode: "screen",
        }}
      />

      {/* Two drifting light pools for depth. */}
      <AbsoluteFill
        style={{
          background: `radial-gradient(42% 46% at ${18 + drift}% 30%, ${hue}40 0%, transparent 62%),
                       radial-gradient(46% 50% at ${84 - drift}% 22%, ${hue2}33 0%, transparent 64%)`,
          mixBlendMode: "screen",
        }}
      />

      {/* Volumetric top light — a soft cone raking down from above the stage. */}
      <div
        style={{
          position: "absolute",
          top: "-18%",
          left: "50%",
          width: "70%",
          height: "95%",
          transform: "translateX(-50%)",
          background: `conic-gradient(from 180deg at 50% 0%, transparent 42%, ${hue2}22 50%, transparent 58%)`,
          filter: "blur(40px)",
          opacity: 0.5 + 0.2 * pulse,
          mixBlendMode: "screen",
          pointerEvents: "none",
        }}
      />

      {/* Fine floor grain / reflection streaks for a polished-stage feel. */}
      <AbsoluteFill
        style={{
          top: "60%",
          background:
            "repeating-linear-gradient(90deg, rgba(255,255,255,0.015) 0px, rgba(255,255,255,0) 3px, rgba(255,255,255,0) 40px)",
          maskImage: "linear-gradient(to bottom, transparent, black 30%, transparent)",
          opacity: 0.4,
        }}
      />

      {/* Heavy cinematic vignette. */}
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(75% 75% at 50% 46%, transparent 55%, rgba(0,0,0,0.55) 100%)",
          opacity: interpolate(frame, [0, 20], [0.7, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      />
    </AbsoluteFill>
  );
};
