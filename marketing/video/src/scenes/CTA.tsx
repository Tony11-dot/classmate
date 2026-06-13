import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { BRAND_GRADIENT, COLORS, FONTS } from "../theme";
import { BrandMark } from "../components/BrandMark";

/**
 * Scene 7 — "Join ClassMate Today" call to action.
 */
export const CTA: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const logoIn = spring({ frame: frame - 6, fps, config: { damping: 12 } });
  const titleIn = spring({ frame: frame - 24, fps, config: { damping: 14 } });
  const btnIn = spring({ frame: frame - 50, fps, config: { damping: 13 } });
  const urlIn = interpolate(frame, [66, 90], [0, 1], { extrapolateRight: "clamp" });
  const shimmer = interpolate(frame % 90, [0, 90], [-120, 220]);

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(90% 80% at 50% 110%, ${COLORS.gold}33, transparent 60%),
                     radial-gradient(130% 130% at 50% 18%, ${COLORS.indigoSoft}, ${COLORS.indigoDeep} 55%, ${COLORS.ink})`,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
      }}
    >
      {/* Logo mark — CM monogram (app icon) */}
      <BrandMark
        size={150}
        style={{
          borderRadius: 38,
          transform: `scale(${interpolate(logoIn, [0, 1], [0.5, 1])})`,
          opacity: logoIn,
          boxShadow: `0 30px 80px ${COLORS.indigo}88`,
        }}
      />

      <div
        style={{
          fontFamily: FONTS.display,
          fontWeight: 800,
          fontSize: 118,
          color: "#fff",
          letterSpacing: "-0.045em",
          marginTop: 40,
          textAlign: "center",
          lineHeight: 1.02,
          transform: `translateY(${interpolate(titleIn, [0, 1], [40, 0])}px)`,
          opacity: titleIn,
        }}
      >
        Join ClassMate Today
      </div>

      <div
        style={{
          fontFamily: FONTS.body,
          fontSize: 34,
          color: COLORS.skyLight,
          marginTop: 18,
          opacity: interpolate(frame, [40, 60], [0, 1]),
        }}
      >
        Attendance, schedules and your whole school — in one app.
      </div>

      {/* Button */}
      <div
        style={{
          position: "relative",
          overflow: "hidden",
          marginTop: 56,
          padding: "26px 64px",
          borderRadius: 999,
          background: BRAND_GRADIENT,
          color: "#fff",
          fontFamily: FONTS.display,
          fontWeight: 800,
          fontSize: 40,
          transform: `scale(${interpolate(btnIn, [0, 1], [0.7, 1])})`,
          opacity: btnIn,
          boxShadow: `0 26px 70px ${COLORS.indigo}77`,
        }}
      >
        Get the app →
        <div
          style={{
            position: "absolute",
            top: 0,
            left: `${shimmer}%`,
            width: "40%",
            height: "100%",
            background:
              "linear-gradient(100deg, transparent, rgba(255,255,255,0.45), transparent)",
            transform: "skewX(-20deg)",
          }}
        />
      </div>

      <div
        style={{
          fontFamily: FONTS.mono,
          fontSize: 30,
          color: "#fff",
          letterSpacing: "0.12em",
          marginTop: 40,
          opacity: urlIn,
        }}
      >
        classmateapp.org
      </div>
    </AbsoluteFill>
  );
};
