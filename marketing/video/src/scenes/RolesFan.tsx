import React from "react";
import { AbsoluteFill, Img, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS } from "../theme";

/** "One platform, every role" — role chips fan out from the ClassMate mark. */
export const RolesFan: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames: dur } = useVideoConfig();
  const pop = spring({ frame, fps, config: { damping: 13, stiffness: 110 } });

  const roles = [
    { label: "Students", c: COLORS.sky, a: -150 },
    { label: "Teachers", c: COLORS.emerald, a: -95 },
    { label: "Parents", c: COLORS.gold, a: -40 },
    { label: "Admins", c: COLORS.indigoSoft, a: 15 },
    { label: "Secretaries", c: COLORS.goldDeep, a: 70 },
  ];
  const R = 340;

  const titleIn = spring({ frame: frame - 4, fps, config: { damping: 18, stiffness: 90 } });

  return (
    <AbsoluteFill>

      <AbsoluteFill style={{ display: "flex", alignItems: "center", justifyContent: "center" }}>
        {/* connectors */}
        <svg width="100%" height="100%" style={{ position: "absolute", inset: 0 }}>
          {roles.map((r, i) => {
            const t = spring({ frame: frame - 6 - i * 4, fps, config: { damping: 16, stiffness: 100 } });
            const rad = (r.a * Math.PI) / 180;
            const x = Math.cos(rad) * R * t;
            const y = Math.sin(rad) * R * t;
            return (
              <line key={i} x1="50%" y1="50%" x2={`calc(50% + ${x}px)`} y2={`calc(50% + ${y}px)`} stroke={r.c} strokeWidth={2} opacity={0.35 * t} />
            );
          })}
        </svg>

        {/* role chips */}
        {roles.map((r, i) => {
          const t = spring({ frame: frame - 6 - i * 4, fps, config: { damping: 14, stiffness: 110 } });
          const rad = (r.a * Math.PI) / 180;
          const x = Math.cos(rad) * R * t;
          const y = Math.sin(rad) * R * t;
          return (
            <div
              key={i}
              style={{
                position: "absolute",
                left: "50%", top: "50%",
                transform: `translate(-50%,-50%) translate(${x}px, ${y}px) scale(${t})`,
                opacity: t,
                background: "linear-gradient(135deg, rgba(255,255,255,0.14), rgba(255,255,255,0.06))",
                border: "1px solid rgba(255,255,255,0.2)",
                backdropFilter: "blur(14px)",
                WebkitBackdropFilter: "blur(14px)",
                borderRadius: 999,
                padding: "14px 26px 14px 16px",
                display: "flex", alignItems: "center", gap: 12,
                boxShadow: "0 20px 44px -14px rgba(20,30,80,0.34), inset 0 0 0 1px rgba(0,0,0,0.04)",
                fontFamily: FONTS.body, fontSize: 26, fontWeight: 700, color: "#F2F5FF",
              }}
            >
              <span style={{ width: 30, height: 30, borderRadius: 99, background: `linear-gradient(150deg, ${r.c}, ${r.c}bb)` }} />
              {r.label}
            </div>
          );
        })}

        {/* center mark */}
        <div
          style={{
            width: 180, height: 180, borderRadius: 46,
            background: `linear-gradient(150deg, ${COLORS.indigo}, ${COLORS.indigoDeep})`,
            display: "flex", alignItems: "center", justifyContent: "center",
            transform: `scale(${interpolate(pop, [0, 1], [0.6, 1])})`,
            boxShadow: `0 34px 74px -20px ${COLORS.indigo}aa`,
            zIndex: 5,
          }}
        >
          <Img src={staticFile("brand/cm-icon.png")} style={{ width: 118, height: 118, objectFit: "contain" }} />
        </div>
      </AbsoluteFill>

      <div
        style={{
          position: "absolute", top: "8.5%", left: 0, right: 0, textAlign: "center",
          opacity: titleIn, transform: `translateY(${interpolate(titleIn, [0, 1], [20, 0])}px)`,
          fontFamily: FONTS.display, fontSize: 66, fontWeight: 800, letterSpacing: -1.4,
          background: "linear-gradient(120deg, #9DBBFF, #F2F5FF)",
          WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent",
        }}
      >
        One platform. Every role.
      </div>
    </AbsoluteFill>
  );
};
