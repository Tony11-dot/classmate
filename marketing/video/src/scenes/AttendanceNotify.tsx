import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Avatar } from "../components/Avatar";
import { PhoneLight } from "../components/PhoneLight";
import { SceneBG } from "../components/SceneBG";
import { LightLeak } from "../components/LightLeak";
import { BrandMark } from "../components/BrandMark";
import { COLORS, FONTS } from "../theme";

const ROSTER: { name: string; initials: string; colors: [string, string] }[] = [
  { name: "Student 1", initials: "S1", colors: [COLORS.indigo, COLORS.sky] },
  { name: "Student 2", initials: "S2", colors: [COLORS.emerald, COLORS.gold] },
  { name: "Student 3", initials: "S3", colors: [COLORS.sky, COLORS.indigoSoft] },
  { name: "Student 4", initials: "S4", colors: [COLORS.goldDeep, COLORS.gold] },
];

/**
 * Scene — Attendance → parent notification.
 * The teacher taps the roster present (left); the alert flies to the parent's
 * phone (right), which lights up. One action, everyone informed.
 */
export const AttendanceNotify: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const present = ROSTER.reduce((n, _, i) => (frame > 36 + i * 20 ? n + 1 : n), 0);
  const allDone = 36 + ROSTER.length * 20;

  // Alert travels along the arc just after the last student is marked.
  const travel = interpolate(frame, [allDone + 6, allDone + 40], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const notif = spring({
    frame: frame - (allDone + 30),
    fps,
    config: { damping: 14, stiffness: 120 },
  });

  const screenW = 300;

  return (
    <AbsoluteFill>
      <SceneBG tint={COLORS.indigoSoft} variant="indigo" />
      <LightLeak life={46} hue={COLORS.gold} from="left" />

      {/* Header */}
      <AbsoluteFill style={{ alignItems: "center", paddingTop: 70 }}>
        <div
          style={{
            fontFamily: FONTS.mono,
            color: COLORS.gold,
            letterSpacing: "0.26em",
            fontSize: 22,
            textTransform: "uppercase",
            opacity: interpolate(frame, [0, 18], [0, 1]),
          }}
        >
          Attendance
        </div>
        <div
          style={{
            fontFamily: FONTS.display,
            fontWeight: 800,
            fontSize: 64,
            color: "#fff",
            letterSpacing: "-0.04em",
            marginTop: 10,
            opacity: interpolate(frame, [6, 26], [0, 1]),
            transform: `translateY(${interpolate(frame, [6, 26], [20, 0], { extrapolateRight: "clamp" })}px)`,
          }}
        >
          Marked once. Everyone knows.
        </div>
      </AbsoluteFill>

      <AbsoluteFill
        style={{
          flexDirection: "row",
          alignItems: "center",
          justifyContent: "center",
          gap: 200,
          paddingTop: 80,
        }}
      >
        {/* Teacher roll-call card */}
        <div
          style={{
            width: 520,
            background: COLORS.paper,
            borderRadius: 28,
            padding: 28,
            boxShadow: "0 40px 90px rgba(0,0,0,0.45)",
            transform: `translateY(${interpolate(spring({ frame, fps, config: { damping: 18 } }), [0, 1], [40, 0])}px)`,
          }}
        >
          <div style={{ fontFamily: FONTS.display, fontWeight: 700, fontSize: 30, color: COLORS.ink }}>
            Grade 10 · Roll call
          </div>
          <div style={{ fontFamily: FONTS.mono, fontSize: 19, color: COLORS.greenDeep, marginTop: 6 }}>
            Present {present}/{ROSTER.length}
          </div>
          <div style={{ marginTop: 22, display: "flex", flexDirection: "column", gap: 14 }}>
            {ROSTER.map((s, i) => {
              const delay = 36 + i * 20;
              const check = spring({ frame: frame - delay, fps, config: { damping: 12, stiffness: 160 } });
              const checked = frame > delay;
              return (
                <div
                  key={s.name}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 16,
                    padding: "10px 14px",
                    borderRadius: 16,
                    background: checked ? `${COLORS.green}1A` : "rgba(11,16,32,0.04)",
                    border: `1px solid ${checked ? COLORS.green + "55" : "rgba(11,16,32,0.06)"}`,
                  }}
                >
                  <Avatar initials={s.initials} colors={s.colors} size={46} delay={i * 4} />
                  <div style={{ flex: 1, fontFamily: FONTS.body, fontWeight: 600, fontSize: 23, color: COLORS.ink }}>
                    {s.name}
                  </div>
                  <div
                    style={{
                      width: 38,
                      height: 38,
                      borderRadius: "50%",
                      background: checked ? COLORS.green : "transparent",
                      border: `2px solid ${checked ? COLORS.green : COLORS.muted}`,
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      transform: `scale(${0.6 + check * 0.4})`,
                    }}
                  >
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                      <path
                        d="M5 12.5l4 4 10-10"
                        stroke="#fff"
                        strokeWidth={3}
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeDasharray={24}
                        strokeDashoffset={interpolate(check, [0, 1], [24, 0])}
                      />
                    </svg>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Parent phone */}
        <div style={{ filter: "drop-shadow(0 40px 90px rgba(0,0,0,0.5))" }}>
          <PhoneLight screenWidth={screenW}>
            {/* Lock screen */}
            <AbsoluteFill style={{ background: `linear-gradient(160deg, ${COLORS.indigo}, ${COLORS.sky})` }} />
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
              <div style={{ fontSize: 20, opacity: 0.85, fontFamily: FONTS.mono, letterSpacing: "0.1em" }}>
                Tuesday
              </div>
              <div style={{ fontSize: 72, letterSpacing: "-0.04em", lineHeight: 1.1 }}>08:15</div>
            </div>
            {/* Notification */}
            <div
              style={{
                position: "absolute",
                left: 16,
                right: 16,
                top: 230,
                transform: `translateY(${interpolate(notif, [0, 1], [-220, 0])}px)`,
                opacity: interpolate(notif, [0, 0.35], [0, 1]),
                background: "rgba(255,255,255,0.94)",
                borderRadius: 22,
                padding: "16px 16px",
                display: "flex",
                gap: 12,
                alignItems: "center",
                boxShadow: "0 18px 44px rgba(0,0,0,0.4)",
              }}
            >
              <BrandMark size={44} style={{ borderRadius: 11, flexShrink: 0 }} />
              <div style={{ flex: 1 }}>
                <div style={{ display: "flex", justifyContent: "space-between", fontFamily: FONTS.mono, fontSize: 13, color: COLORS.muted }}>
                  <span style={{ fontWeight: 700, color: COLORS.indigo }}>CLASSMATE</span>
                  <span>now</span>
                </div>
                <div style={{ fontFamily: FONTS.body, fontWeight: 700, fontSize: 18, color: COLORS.ink, marginTop: 3 }}>
                  Student 1 is present ✓
                </div>
                <div style={{ fontFamily: FONTS.body, fontSize: 15, color: "#3a4763", marginTop: 1 }}>
                  Room 204 · 08:15
                </div>
              </div>
            </div>
          </PhoneLight>
        </div>
      </AbsoluteFill>

      {/* Traveling alert pulse (card → phone) */}
      <AbsoluteFill style={{ pointerEvents: "none" }}>
        <div
          style={{
            position: "absolute",
            left: `${interpolate(travel, [0, 1], [44, 64])}%`,
            top: `${interpolate(travel, [0, 1], [54, 40])}%`,
            width: 22,
            height: 22,
            marginLeft: -11,
            marginTop: -11,
            borderRadius: "50%",
            background: COLORS.gold,
            boxShadow: `0 0 24px ${COLORS.gold}`,
            opacity: travel > 0 && travel < 1 ? 1 : 0,
          }}
        />
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
