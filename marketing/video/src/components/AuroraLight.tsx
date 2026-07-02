import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

/**
 * Bright, airy motion-graphics backdrop (ref1 / ClickUp aesthetic) — a near-white
 * stage with big soft-focus brand-colour blooms drifting behind the content, a
 * faint dot-grid for depth, and a soft top vignette. Light, premium, energetic.
 */
export const AuroraLight: React.FC<{
  hues?: string[];
  /** 0 = still, 1 = full drift. */
  life?: number;
}> = ({ hues = [COLORS.indigoSoft, COLORS.sky, COLORS.gold, COLORS.emerald], life = 1 }) => {
  const frame = useCurrentFrame();
  const d = (n: number) => Math.sin(frame / (52 + n * 9) + n) * 5 * life;

  return (
    <AbsoluteFill style={{ background: "linear-gradient(180deg, #ffffff 0%, #eef3fc 55%, #e6eefb 100%)" }}>
      {/* Soft drifting colour blooms. */}
      <AbsoluteFill
        style={{
          background: `
            radial-gradient(38% 42% at ${18 + d(0)}% ${26 + d(1)}%, ${hues[0]}3a 0%, transparent 62%),
            radial-gradient(40% 44% at ${82 + d(2)}% ${20 + d(3)}%, ${hues[1]}33 0%, transparent 64%),
            radial-gradient(44% 46% at ${76 + d(4)}% ${82 + d(1)}%, ${hues[2]}26 0%, transparent 66%),
            radial-gradient(40% 42% at ${20 + d(3)}% ${84 + d(2)}%, ${hues[3]}22 0%, transparent 64%)`,
          filter: "blur(8px)",
        }}
      />
      {/* Faint dot grid for depth. */}
      <AbsoluteFill
        style={{
          backgroundImage: "radial-gradient(rgba(34,48,200,0.06) 1.4px, transparent 1.4px)",
          backgroundSize: "34px 34px",
          maskImage: "radial-gradient(80% 80% at 50% 45%, black, transparent 85%)",
          WebkitMaskImage: "radial-gradient(80% 80% at 50% 45%, black, transparent 85%)",
          opacity: 0.7,
        }}
      />
      {/* Gentle top light + bottom lift. */}
      <AbsoluteFill
        style={{
          background:
            "linear-gradient(180deg, rgba(255,255,255,0.65) 0%, transparent 22%, transparent 80%, rgba(230,238,251,0.7) 100%)",
          opacity: interpolate(frame, [0, 16], [0.6, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),
        }}
      />
    </AbsoluteFill>
  );
};
