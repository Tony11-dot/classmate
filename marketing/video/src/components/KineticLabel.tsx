import React from "react";
import {
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { BRAND_GRADIENT, COLORS, FONTS } from "../theme";

/**
 * Kinetic feature-name typography that punches in beside a phone.
 * `kicker` is the small mono label, `title` the big display word.
 */
export const KineticLabel: React.FC<{
  kicker: string;
  title: string;
  sub?: string;
  delay?: number;
  align?: "left" | "right";
  gradient?: boolean;
}> = ({ kicker, title, sub, delay = 0, align = "left", gradient = true }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const s = spring({
    frame: frame - delay,
    fps,
    config: { damping: 14, stiffness: 120, mass: 0.8 },
  });
  const y = interpolate(s, [0, 1], [60, 0]);
  const blur = interpolate(s, [0, 1], [12, 0]);
  const kick = interpolate(frame, [delay, delay + 14], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const subIn = interpolate(frame, [delay + 16, delay + 34], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: align === "left" ? "flex-start" : "flex-end",
        textAlign: align,
        maxWidth: 620,
      }}
    >
      <div
        style={{
          fontFamily: FONTS.mono,
          color: COLORS.gold,
          letterSpacing: "0.26em",
          fontSize: 24,
          textTransform: "uppercase",
          opacity: kick,
        }}
      >
        {kicker}
      </div>
      <div
        style={{
          fontFamily: FONTS.display,
          fontWeight: 800,
          fontSize: 96,
          lineHeight: 1.0,
          letterSpacing: "-0.045em",
          marginTop: 12,
          transform: `translateY(${y}px)`,
          opacity: s,
          filter: `blur(${blur}px)`,
          ...(gradient
            ? {
                backgroundImage: BRAND_GRADIENT,
                WebkitBackgroundClip: "text",
                backgroundClip: "text",
                color: "transparent",
              }
            : { color: COLORS.white }),
        }}
      >
        {title}
      </div>
      {sub ? (
        <div
          style={{
            fontFamily: FONTS.body,
            fontSize: 30,
            color: COLORS.skyLight,
            marginTop: 18,
            opacity: subIn,
            lineHeight: 1.3,
          }}
        >
          {sub}
        </div>
      ) : null}
    </div>
  );
};
