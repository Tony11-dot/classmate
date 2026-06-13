import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { BRAND_GRADIENT, COLORS, FONTS } from "../theme";

/**
 * Full-frame trailer title card — a hard-hitting line that punches in, holds,
 * and pushes out. Used between beats for the "movie trailer" rhythm.
 */
export const TitleCard: React.FC<{
  line: string;
  gradient?: boolean;
  durationInFrames?: number;
}> = ({ line, gradient = false, durationInFrames }) => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames: compDur } = useVideoConfig();
  const dur = durationInFrames ?? compDur;

  const punch = spring({ frame, fps, config: { damping: 12, stiffness: 200, mass: 0.7 } });
  const out = interpolate(frame, [dur - 12, dur], [1, 0], { extrapolateLeft: "clamp" });
  const scale = interpolate(punch, [0, 1], [1.25, 1]) * interpolate(frame, [0, dur], [1, 1.06]);
  const blur = interpolate(punch, [0, 1], [16, 0]);

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(120% 120% at 50% 50%, ${COLORS.indigoDeep}, ${COLORS.ink} 70%)`,
        alignItems: "center",
        justifyContent: "center",
        opacity: out,
      }}
    >
      <div
        style={{
          fontFamily: FONTS.display,
          fontWeight: 800,
          fontSize: 120,
          letterSpacing: "-0.05em",
          textAlign: "center",
          lineHeight: 0.98,
          transform: `scale(${scale})`,
          opacity: punch,
          filter: `blur(${blur}px)`,
          ...(gradient
            ? { backgroundImage: BRAND_GRADIENT, WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent" }
            : { color: COLORS.white }),
          textShadow: gradient ? undefined : "0 10px 60px rgba(0,0,0,0.6)",
        }}
      >
        {line}
      </div>
    </AbsoluteFill>
  );
};
