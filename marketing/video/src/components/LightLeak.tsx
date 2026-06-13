import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

/**
 * A warm anamorphic light leak that sweeps across the frame — used as a
 * transition accent at the start of a scene. Self-contained: it blooms in and
 * fades out over `life` frames.
 */
export const LightLeak: React.FC<{
  life?: number;
  hue?: string;
  from?: "left" | "right";
}> = ({ life = 40, hue = COLORS.gold, from = "left" }) => {
  const frame = useCurrentFrame();
  const t = interpolate(frame, [0, life], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const x = from === "left" ? interpolate(t, [0, 1], [-30, 120]) : interpolate(t, [0, 1], [130, -20]);
  const opacity = Math.sin(t * Math.PI) * 0.9;

  return (
    <AbsoluteFill style={{ pointerEvents: "none", mixBlendMode: "screen", opacity }}>
      <AbsoluteFill
        style={{
          background: `linear-gradient(100deg, transparent ${x - 22}%, ${hue}AA ${x}%, ${COLORS.white}88 ${x + 4}%, ${hue}55 ${x + 12}%, transparent ${x + 26}%)`,
          filter: "blur(8px)",
        }}
      />
    </AbsoluteFill>
  );
};
