import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Avatar } from "../components/Avatar";
import { Device } from "../components/Device";
import { COLORS, FONTS } from "../theme";

const ROSTER: { name: string; initials: string; colors: [string, string] }[] = [
  { name: "Maya Cohen", initials: "MC", colors: [COLORS.indigo, COLORS.sky] },
  { name: "Liam Okafor", initials: "LO", colors: [COLORS.green, COLORS.gold] },
  { name: "Sara Haddad", initials: "SH", colors: [COLORS.sky, COLORS.indigoSoft] },
  { name: "Noa Levi", initials: "NL", colors: [COLORS.goldDeep, COLORS.gold] },
  { name: "Omar Idris", initials: "OI", colors: [COLORS.indigoSoft, COLORS.green] },
];

export const Attendance: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const present = ROSTER.reduce(
    (n, _, i) => (frame > 40 + i * 22 ? n + 1 : n),
    0,
  );

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(135deg, ${COLORS.skyMist}, ${COLORS.skyLight})`,
        alignItems: "center",
        justifyContent: "center",
        gap: 90,
        flexDirection: "row",
      }}
    >
      <div style={{ maxWidth: 560 }}>
        <div
          style={{
            fontFamily: FONTS.mono,
            color: COLORS.indigo,
            letterSpacing: "0.22em",
            fontSize: 22,
            textTransform: "uppercase",
            opacity: interpolate(frame, [0, 20], [0, 1]),
          }}
        >
          For teachers
        </div>
        <div
          style={{
            fontFamily: FONTS.display,
            fontWeight: 800,
            fontSize: 78,
            color: COLORS.ink,
            letterSpacing: "-0.04em",
            lineHeight: 1.05,
            marginTop: 14,
            opacity: interpolate(frame, [6, 30], [0, 1]),
            transform: `translateY(${interpolate(frame, [6, 30], [20, 0], { extrapolateRight: "clamp" })}px)`,
          }}
        >
          One tap per
          <br />
          student.
        </div>
        <div
          style={{
            fontFamily: FONTS.body,
            fontSize: 30,
            color: "#3a4763",
            marginTop: 22,
            opacity: interpolate(frame, [20, 44], [0, 1]),
          }}
        >
          The whole class, taken before the bell stops ringing.
        </div>
      </div>

      <Device width={430}>
        <div style={{ padding: 28, height: "100%" }}>
          {/* Header */}
          <div
            style={{
              fontFamily: FONTS.display,
              fontWeight: 700,
              fontSize: 30,
              color: COLORS.ink,
            }}
          >
            Grade 10 · Roll call
          </div>
          <div
            style={{
              fontFamily: FONTS.mono,
              fontSize: 18,
              color: COLORS.green,
              marginTop: 6,
            }}
          >
            Present {present}/{ROSTER.length}
          </div>

          {/* Rows */}
          <div style={{ marginTop: 26, display: "flex", flexDirection: "column", gap: 16 }}>
            {ROSTER.map((s, i) => {
              const delay = 40 + i * 22;
              const check = spring({
                frame: frame - delay,
                fps,
                config: { damping: 12, stiffness: 160 },
              });
              const checked = frame > delay;
              return (
                <div
                  key={s.name}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 16,
                    padding: "12px 14px",
                    borderRadius: 18,
                    background: checked
                      ? `${COLORS.green}1A`
                      : "rgba(11,16,32,0.04)",
                    border: `1px solid ${checked ? COLORS.green + "55" : "rgba(11,16,32,0.06)"}`,
                    transition: "none",
                  }}
                >
                  <Avatar initials={s.initials} colors={s.colors} size={48} delay={i * 4} />
                  <div
                    style={{
                      flex: 1,
                      fontFamily: FONTS.body,
                      fontWeight: 600,
                      fontSize: 24,
                      color: COLORS.ink,
                    }}
                  >
                    {s.name}
                  </div>
                  <div
                    style={{
                      width: 40,
                      height: 40,
                      borderRadius: "50%",
                      background: checked ? COLORS.green : "transparent",
                      border: `2px solid ${checked ? COLORS.green : COLORS.muted}`,
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      transform: `scale(${0.6 + check * 0.4})`,
                    }}
                  >
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
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
      </Device>
    </AbsoluteFill>
  );
};
