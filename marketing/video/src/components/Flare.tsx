import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

/**
 * Anamorphic lens flare "hit" — a horizontal streak + bloom that blooms at
 * `at` and decays. Use on impact moments (a tap landing, a reveal).
 */
export const Flare: React.FC<{
  at: number;
  x?: number; // 0..100 vw
  y?: number; // 0..100 vh
  hue?: string;
  life?: number;
}> = ({ at, x = 50, y = 50, hue = COLORS.gold, life = 26 }) => {
  const frame = useCurrentFrame();
  const t = interpolate(frame, [at, at + life], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  if (frame < at - 1 || t >= 1) return null;
  const intensity = Math.sin(t * Math.PI);
  const width = interpolate(t, [0, 1], [30, 120]);

  return (
    <AbsoluteFill style={{ pointerEvents: "none", mixBlendMode: "screen", opacity: intensity }}>
      {/* horizontal streak */}
      <div
        style={{
          position: "absolute",
          top: `${y}%`,
          left: `${x}%`,
          width: `${width}%`,
          height: 4,
          transform: "translate(-50%, -50%)",
          background: `linear-gradient(90deg, transparent, ${hue}, ${COLORS.white}, ${hue}, transparent)`,
          filter: "blur(2px)",
          boxShadow: `0 0 24px ${hue}`,
        }}
      />
      {/* core bloom */}
      <div
        style={{
          position: "absolute",
          top: `${y}%`,
          left: `${x}%`,
          width: 120,
          height: 120,
          transform: "translate(-50%, -50%)",
          borderRadius: "50%",
          background: `radial-gradient(circle, ${COLORS.white} 0%, ${hue}AA 30%, transparent 70%)`,
          filter: "blur(4px)",
        }}
      />
    </AbsoluteFill>
  );
};
