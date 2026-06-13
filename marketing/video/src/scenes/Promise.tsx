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
 * Scene 2 — Kinetic-type promise.
 * Words punch in one after another, last word swapped to a gradient.
 */
const WORDS = ["Attendance,", "finally,", "effortless."];

export const Promise: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(120% 120% at 50% 0%, ${COLORS.indigoDeep}, ${COLORS.ink})`,
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 8,
        }}
      >
        {WORDS.map((word, i) => {
          const delay = 12 + i * 28;
          const s = spring({
            frame: frame - delay,
            fps,
            config: { damping: 13, stiffness: 130, mass: 0.8 },
          });
          const y = interpolate(s, [0, 1], [80, 0]);
          const blur = interpolate(s, [0, 1], [14, 0]);
          const isLast = i === WORDS.length - 1;
          return (
            <div
              key={word}
              style={{
                fontFamily: FONTS.display,
                fontWeight: 800,
                fontSize: 132,
                lineHeight: 1.02,
                letterSpacing: "-0.045em",
                transform: `translateY(${y}px)`,
                opacity: s,
                filter: `blur(${blur}px)`,
                ...(isLast
                  ? {
                      backgroundImage: BRAND_GRADIENT,
                      WebkitBackgroundClip: "text",
                      backgroundClip: "text",
                      color: "transparent",
                    }
                  : { color: COLORS.white }),
              }}
            >
              {word}
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};
