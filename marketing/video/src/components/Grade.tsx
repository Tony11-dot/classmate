import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

/**
 * Cinematic color grade applied on top of every scene:
 *  - a warm gold→green wash (soft-light) for the "golden hour" feel,
 *  - a vignette to focus the eye,
 *  - animated film grain for texture.
 */
export const Grade: React.FC = () => {
  const frame = useCurrentFrame();
  // Re-seed the grain each frame so it shimmers like real film grain.
  const seed = frame % 64;

  return (
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      {/* Warm wash */}
      <AbsoluteFill
        style={{
          background: `radial-gradient(120% 90% at 12% 8%, ${COLORS.gold}33 0%, transparent 55%),
                       radial-gradient(120% 100% at 90% 95%, ${COLORS.green}2E 0%, transparent 60%)`,
          mixBlendMode: "soft-light",
        }}
      />
      {/* Vignette */}
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(75% 75% at 50% 48%, transparent 55%, rgba(6,9,22,0.55) 100%)",
        }}
      />
      {/* Film grain */}
      <AbsoluteFill style={{ mixBlendMode: "overlay", opacity: 0.16 }}>
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
