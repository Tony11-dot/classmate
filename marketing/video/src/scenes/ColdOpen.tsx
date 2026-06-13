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
 * sweep crosses the frame, ending on a quiet title + timestamp.
 *
 * Layout is split into three vertical bands that never overlap:
 *   board (top) · title + timestamp (middle) · desk grid (bottom, top-faded).
 */
export const ColdOpen: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames } = useVideoConfig();

  // Slow cinematic push-in.
  const scale = interpolate(frame, [0, durationInFrames], [1.05, 1.14], {
    extrapolateRight: "clamp",
  });
  const sweep = interpolate(frame, [4, 60], [-30, 130], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const desks = Array.from({ length: 18 });

  const titleIn = spring({ frame: frame - 34, fps, config: { damping: 16 } });
  const stampIn = spring({ frame: frame - 54, fps, config: { damping: 18 } });

  return (
    <AbsoluteFill style={{ background: "#05080f" }}>
      <AbsoluteFill style={{ transform: `scale(${scale})` }}>
        {/* Board glow — top band */}
        <div
          style={{
            position: "absolute",
            top: "7%",
            left: "50%",
            transform: "translateX(-50%)",
            width: "42%",
            height: "16%",
            borderRadius: 22,
            background: `linear-gradient(160deg, ${COLORS.indigoDeep}, #0a0f24)`,
            boxShadow: `0 0 120px ${COLORS.indigo}55`,
            border: "1px solid rgba(255,255,255,0.06)",
          }}
        />

        {/* Desks — bottom band, faded at the top so they recede behind the title */}
        <div
          style={{
            position: "absolute",
            bottom: "5%",
            left: "50%",
            transform: "translateX(-50%)",
            display: "grid",
            gridTemplateColumns: "repeat(6, 1fr)",
            gap: 42,
            width: "68%",
            WebkitMaskImage:
              "linear-gradient(to top, #000 70%, transparent 100%)",
            maskImage: "linear-gradient(to top, #000 70%, transparent 100%)",
          }}
        >
          {desks.map((_, i) => {
            const col = i % 6;
            const lit = interpolate(
              frame,
              [8 + col * 4, 22 + col * 4],
              [0, 1],
              { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
            );
            return (
              <div
                key={i}
                style={{
                  height: 76,
                  borderRadius: 14,
                  background: `linear-gradient(160deg, #131a2c, #0b1020)`,
                  border: "1px solid rgba(255,255,255,0.05)",
                  boxShadow: `0 0 ${28 * lit}px ${COLORS.sky}${Math.round(
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
                    width: 20,
                    height: 20,
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

      {/* Title band — sits in the clear gap between board and desks */}
      <AbsoluteFill
        style={{
          alignItems: "center",
          justifyContent: "center",
          flexDirection: "column",
          paddingBottom: "16%",
        }}
      >
        <div
          style={{
            fontFamily: FONTS.display,
            fontWeight: 800,
            fontSize: 92,
            color: COLORS.white,
            letterSpacing: "-0.04em",
            opacity: titleIn,
            transform: `translateY(${interpolate(titleIn, [0, 1], [24, 0])}px)`,
            textShadow: "0 8px 40px rgba(0,0,0,0.55)",
          }}
        >
          Every morning,
        </div>
        <div
          style={{
            fontFamily: FONTS.mono,
            fontSize: 24,
            color: COLORS.skyLight,
            letterSpacing: "0.28em",
            marginTop: 26,
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
