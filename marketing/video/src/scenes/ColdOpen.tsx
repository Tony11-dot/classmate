import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { COLORS, FONTS } from "../theme";

/**
 * Scene 1 — Classroom cold open.
 * A dark room slowly pushes in; desks light up one by one as a soft light
 * sweep crosses the frame, ending on a quiet timestamp.
 */
export const ColdOpen: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames } = useVideoConfig();

  // Slow cinematic push-in.
  const scale = interpolate(frame, [0, durationInFrames], [1.06, 1.16], {
    extrapolateRight: "clamp",
  });
  const sweep = interpolate(frame, [10, 120], [-30, 130], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const desks = Array.from({ length: 18 });

  const titleIn = spring({ frame: frame - 70, fps, config: { damping: 16 } });
  const stampIn = spring({ frame: frame - 95, fps, config: { damping: 18 } });

  return (
    <AbsoluteFill style={{ background: "#05080f" }}>
      <AbsoluteFill style={{ transform: `scale(${scale})` }}>
        {/* Board glow */}
        <div
          style={{
            position: "absolute",
            top: "12%",
            left: "50%",
            transform: "translateX(-50%)",
            width: "44%",
            height: "26%",
            borderRadius: 24,
            background: `linear-gradient(160deg, ${COLORS.indigoDeep}, #0a0f24)`,
            boxShadow: `0 0 120px ${COLORS.indigo}55`,
            border: "1px solid rgba(255,255,255,0.06)",
          }}
        />
        {/* Desks */}
        <div
          style={{
            position: "absolute",
            bottom: "9%",
            left: "50%",
            transform: "translateX(-50%)",
            display: "grid",
            gridTemplateColumns: "repeat(6, 1fr)",
            gap: 46,
            width: "70%",
          }}
        >
          {desks.map((_, i) => {
            const col = i % 6;
            const lit = interpolate(
              frame,
              [25 + col * 8, 45 + col * 8],
              [0, 1],
              { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
            );
            return (
              <div
                key={i}
                style={{
                  height: 86,
                  borderRadius: 14,
                  background: `linear-gradient(160deg, #131a2c, #0b1020)`,
                  border: "1px solid rgba(255,255,255,0.05)",
                  boxShadow: `0 0 ${30 * lit}px ${COLORS.sky}${Math.round(
                    lit * 120,
                  )
                    .toString(16)
                    .padStart(2, "0")}`,
                  position: "relative",
                }}
              >
                <div
                  style={{
                    position: "absolute",
                    top: 12,
                    left: "50%",
                    transform: "translateX(-50%)",
                    width: 22,
                    height: 22,
                    borderRadius: "50%",
                    background: COLORS.sky,
                    opacity: lit * 0.9,
                    filter: "blur(0.3px)",
                  }}
                />
              </div>
            );
          })}
        </div>

        {/* Light sweep */}
        <AbsoluteFill
          style={{
            background: `linear-gradient(105deg, transparent ${sweep - 18}%, ${COLORS.sky}22 ${sweep}%, transparent ${sweep + 18}%)`,
          }}
        />
      </AbsoluteFill>

      {/* Title */}
      <AbsoluteFill
        style={{
          alignItems: "center",
          justifyContent: "center",
          flexDirection: "column",
        }}
      >
        <div
          style={{
            fontFamily: FONTS.display,
            fontWeight: 800,
            fontSize: 96,
            color: COLORS.white,
            letterSpacing: "-0.04em",
            opacity: titleIn,
            transform: `translateY(${interpolate(titleIn, [0, 1], [24, 0])}px)`,
            textShadow: "0 8px 40px rgba(0,0,0,0.5)",
          }}
        >
          Every morning,
        </div>
        <div
          style={{
            fontFamily: FONTS.mono,
            fontSize: 26,
            color: COLORS.skyLight,
            letterSpacing: "0.28em",
            marginTop: 28,
            opacity: stampIn,
            textTransform: "uppercase",
          }}
        >
          08:14 · Room 204
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
