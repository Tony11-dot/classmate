import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Avatar } from "../components/Avatar";
import { COLORS, FONTS } from "../theme";

/**
 * Scene 5 — Student check-in.
 * The student taps a big check-in button; a ripple fires and it flips to a
 * confirmed state.
 */
export const Checkin: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const tap = spring({
    frame: frame - 70,
    fps,
    config: { damping: 11, stiffness: 200 },
  });
  const confirmed = frame > 70;
  const press = interpolate(
    frame,
    [60, 70, 80],
    [1, 0.92, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  );
  const ripple = interpolate(frame, [70, 110], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(120% 120% at 50% 30%, ${COLORS.skyMist}, ${COLORS.skyLight})`,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 50,
      }}
    >
      <div
        style={{
          fontFamily: FONTS.mono,
          color: COLORS.indigo,
          letterSpacing: "0.24em",
          fontSize: 24,
          textTransform: "uppercase",
          opacity: interpolate(frame, [0, 20], [0, 1]),
        }}
      >
        For students
      </div>

      <Avatar
        initials="MC"
        colors={[COLORS.indigo, COLORS.sky]}
        size={180}
        delay={6}
        ring
      />

      <div
        style={{
          fontFamily: FONTS.display,
          fontWeight: 800,
          fontSize: 64,
          color: COLORS.ink,
          letterSpacing: "-0.03em",
          opacity: interpolate(frame, [14, 34], [0, 1]),
        }}
      >
        Good morning, Maya
      </div>

      {/* Check-in button */}
      <div style={{ position: "relative", marginTop: 8 }}>
        {/* ripple */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            borderRadius: 999,
            border: `3px solid ${COLORS.green}`,
            transform: `scale(${1 + ripple * 1.4})`,
            opacity: (1 - ripple) * 0.7,
          }}
        />
        <div
          style={{
            transform: `scale(${press})`,
            padding: "30px 70px",
            borderRadius: 999,
            background: confirmed
              ? `linear-gradient(135deg, ${COLORS.green}, ${COLORS.greenDeep})`
              : `linear-gradient(135deg, ${COLORS.indigo}, ${COLORS.sky})`,
            color: "#fff",
            fontFamily: FONTS.display,
            fontWeight: 800,
            fontSize: 46,
            letterSpacing: "-0.02em",
            display: "flex",
            alignItems: "center",
            gap: 18,
            boxShadow: `0 26px 60px ${confirmed ? COLORS.green : COLORS.indigo}66`,
          }}
        >
          {confirmed ? (
            <>
              <svg width="46" height="46" viewBox="0 0 24 24" fill="none">
                <path
                  d="M5 12.5l4 4 10-10"
                  stroke="#fff"
                  strokeWidth={3}
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeDasharray={24}
                  strokeDashoffset={interpolate(tap, [0, 1], [24, 0])}
                />
              </svg>
              Checked in
            </>
          ) : (
            "Tap to check in"
          )}
        </div>
      </div>
    </AbsoluteFill>
  );
};
