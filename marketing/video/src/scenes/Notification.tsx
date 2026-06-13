import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Device } from "../components/Device";
import { COLORS, FONTS } from "../theme";

/**
 * Scene 4 — Parent notification.
 * A lock-screen push slides down and settles; "moments later" the parent
 * already knows their child is safe at school.
 */
export const Notification: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const drop = spring({
    frame: frame - 30,
    fps,
    config: { damping: 14, stiffness: 120, mass: 0.9 },
  });
  const y = interpolate(drop, [0, 1], [-260, 0]);

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(150deg, ${COLORS.indigoDeep}, ${COLORS.ink})`,
        alignItems: "center",
        justifyContent: "center",
        gap: 100,
      }}
    >
      <Device width={430}>
        {/* Lock screen wallpaper */}
        <AbsoluteFill
          style={{
            background: `linear-gradient(160deg, ${COLORS.indigo}, ${COLORS.sky})`,
          }}
        />
        <div
          style={{
            position: "absolute",
            top: 70,
            width: "100%",
            textAlign: "center",
            color: "#fff",
            fontFamily: FONTS.display,
            fontWeight: 700,
          }}
        >
          <div style={{ fontSize: 26, opacity: 0.85, fontFamily: FONTS.mono, letterSpacing: "0.1em" }}>
            Tuesday
          </div>
          <div style={{ fontSize: 92, letterSpacing: "-0.04em", lineHeight: 1.1 }}>
            08:15
          </div>
        </div>

        {/* Notification card */}
        <div
          style={{
            position: "absolute",
            left: 22,
            right: 22,
            top: 250,
            transform: `translateY(${y}px)`,
            opacity: interpolate(drop, [0, 0.4], [0, 1]),
            background: "rgba(255,255,255,0.92)",
            backdropFilter: "blur(8px)",
            borderRadius: 26,
            padding: "20px 22px",
            display: "flex",
            gap: 16,
            alignItems: "center",
            boxShadow: "0 24px 60px rgba(0,0,0,0.4)",
          }}
        >
          <div
            style={{
              width: 56,
              height: 56,
              borderRadius: 14,
              background: `linear-gradient(140deg, ${COLORS.indigo}, ${COLORS.sky})`,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              color: "#fff",
              fontFamily: FONTS.display,
              fontWeight: 800,
              fontSize: 30,
              flexShrink: 0,
            }}
          >
            C
          </div>
          <div style={{ flex: 1 }}>
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                fontFamily: FONTS.mono,
                fontSize: 16,
                color: COLORS.muted,
              }}
            >
              <span style={{ fontWeight: 700, color: COLORS.indigo }}>CLASSMATE</span>
              <span>now</span>
            </div>
            <div
              style={{
                fontFamily: FONTS.body,
                fontWeight: 700,
                fontSize: 23,
                color: COLORS.ink,
                marginTop: 4,
              }}
            >
              Maya is present ✓
            </div>
            <div
              style={{
                fontFamily: FONTS.body,
                fontSize: 20,
                color: "#3a4763",
                marginTop: 2,
              }}
            >
              Marked present in Room 204 at 08:15.
            </div>
          </div>
        </div>
      </Device>

      <div style={{ maxWidth: 560 }}>
        <div
          style={{
            fontFamily: FONTS.mono,
            color: COLORS.skyLight,
            letterSpacing: "0.22em",
            fontSize: 22,
            textTransform: "uppercase",
            opacity: interpolate(frame, [50, 70], [0, 1]),
          }}
        >
          For parents
        </div>
        <div
          style={{
            fontFamily: FONTS.display,
            fontWeight: 800,
            fontSize: 76,
            color: "#fff",
            letterSpacing: "-0.04em",
            lineHeight: 1.05,
            marginTop: 14,
            opacity: interpolate(frame, [56, 80], [0, 1]),
            transform: `translateX(${interpolate(frame, [56, 80], [40, 0], { extrapolateRight: "clamp" })}px)`,
          }}
        >
          They know
          <br />
          the moment it
          <br />
          happens.
        </div>
      </div>
    </AbsoluteFill>
  );
};
