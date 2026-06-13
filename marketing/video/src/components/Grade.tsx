import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

/**
 * Cinematic color grade applied on top of every scene (v2 — intensified):
 *  - a warm gold→emerald wash (soft-light) for the "golden hour" feel,
 *  - a stronger vignette to focus the eye,
 *  - animated film grain for texture.
 */
export const Grade: React.FC = () => {
  const frame = useCurrentFrame();
  // Re-seed the grain each frame so it shimmers like real film grain.
  const seed = frame % 64;

  return (
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      {/* Warm wash — gold from top-left, emerald from bottom-right */}
      <AbsoluteFill
        style={{
          background: `radial-gradient(120% 90% at 10% 6%, ${COLORS.gold}3D 0%, transparent 52%),
                       radial-gradient(120% 100% at 92% 96%, ${COLORS.emerald}3A 0%, transparent 58%)`,
          mixBlendMode: "soft-light",
        }}
      />
      {/* Subtle cool counter-tone so highlights don't go muddy */}
      <AbsoluteFill
        style={{
          background: `radial-gradient(90% 70% at 50% 40%, ${COLORS.sky}1A 0%, transparent 60%)`,
          mixBlendMode: "screen",
        }}
      />
      {/* Vignette */}
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(72% 72% at 50% 46%, transparent 52%, rgba(6,9,22,0.62) 100%)",
        }}
      />
      {/* Film grain */}
      <AbsoluteFill style={{ mixBlendMode: "overlay", opacity: 0.18 }}>
        <svg width="100%" height="100%">
          <filter id="grain">
            <feTurbulence
              type="fractalNoise"
              baseFrequency="0.9"
              numOctaves={2}
              seed={seed}
              stitchTiles="stitch"
            />
            <feColorMatrix type="saturate" values="0" />
          </filter>
          <rect width="100%" height="100%" filter="url(#grain)" />
        </svg>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
