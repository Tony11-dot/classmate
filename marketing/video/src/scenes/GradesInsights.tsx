import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { PhoneLight } from "../components/PhoneLight";
import { Shot } from "../components/Shot";
import { KineticLabel } from "../components/KineticLabel";
import { SceneBG } from "../components/SceneBG";
import { LightLeak } from "../components/LightLeak";
import { COLORS, FONTS, SCREENS, SHOT } from "../theme";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri"];
const VALUES = [0.79, 0.85, 0.88, 0.93, 0.96];
const GW = 1080;
const GH = 460;
const PAD = 64;
const pt = (i: number, v: number) =>
  [
    PAD + (i / (VALUES.length - 1)) * (GW - PAD * 2),
    GH - PAD - v * (GH - PAD * 2),
  ] as const;
const LINE = VALUES.map((v, i) => {
  const [x, y] = pt(i, v);
  return `${i === 0 ? "M" : "L"}${x.toFixed(1)},${y.toFixed(1)}`;
}).join(" ");

/**
 * Scene — Grades → Insights.
 * The grades dashboard glides in, then hands off to an analytics graph that
 * draws itself and trends up.
 */
export const GradesInsights: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Phase A: grades phone.
  const enter = spring({ frame, fps, config: { damping: 18, mass: 1 } });
  const aOut = interpolate(frame, [170, 200], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const screenW = 360;
  const screenH = (screenW * SHOT.h) / SHOT.w;
  const float = Math.sin(frame / 40) * 7;

  // Phase B: analytics.
  const bIn = interpolate(frame, [185, 215], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const draw = interpolate(frame, [210, 320], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const counter = Math.round(interpolate(draw, [0, 1], [82, 96]));
  const [endX, endY] = pt(VALUES.length - 1, VALUES[VALUES.length - 1]);

  return (
    <AbsoluteFill>
      <SceneBG tint={COLORS.emerald} variant="warm" />
      <LightLeak life={44} hue={COLORS.emerald} from="right" />

      {/* Phase A — grades phone */}
      <AbsoluteFill
        style={{
          flexDirection: "row",
          alignItems: "center",
          justifyContent: "center",
          gap: 110,
          padding: "0 120px",
          opacity: aOut,
        }}
      >
        <div
          style={{
            transform: `translateX(${interpolate(enter, [0, 1], [-110, 0])}px) translateY(${float}px) rotate(${interpolate(enter, [0, 1], [-5, 2])}deg)`,
            filter: "drop-shadow(0 40px 90px rgba(0,0,0,0.5))",
          }}
        >
          <PhoneLight screenWidth={screenW}>
            <Shot src={SCREENS.grades} scroll={interpolate(frame, [30, 180], [0, -screenH * 0.08], { extrapolateRight: "clamp" })} zoom={1.08} />
          </PhoneLight>
        </div>
        <KineticLabel
          kicker="Grades & Insights"
          title="See progress, clearly"
          sub="Clean grade dashboards for students and parents — and the trend over time."
          delay={16}
          align="right"
        />
      </AbsoluteFill>

      {/* Phase B — analytics graph */}
      <AbsoluteFill
        style={{
          alignItems: "center",
          justifyContent: "center",
          flexDirection: "column",
          opacity: bIn,
        }}
      >
        <div
          style={{
            fontFamily: FONTS.mono,
            color: COLORS.gold,
            letterSpacing: "0.26em",
            fontSize: 22,
            textTransform: "uppercase",
          }}
        >
          Insights
        </div>
        <div
          style={{
            fontFamily: FONTS.display,
            fontWeight: 800,
            fontSize: 54,
            color: "#fff",
            letterSpacing: "-0.03em",
            marginTop: 8,
          }}
        >
          Trending up, all term
        </div>
        <div
          style={{
            fontFamily: FONTS.mono,
            fontSize: 110,
            fontWeight: 700,
            letterSpacing: "-0.02em",
            backgroundImage: `linear-gradient(90deg, ${COLORS.gold}, ${COLORS.emerald})`,
            WebkitBackgroundClip: "text",
            backgroundClip: "text",
            color: "transparent",
            lineHeight: 1.1,
          }}
        >
          {counter}
          <span style={{ fontSize: 60 }}>%</span>
        </div>

        <svg width={GW} height={GH} style={{ overflow: "visible" }}>
          <defs>
            <linearGradient id="gi-stroke" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stopColor={COLORS.gold} />
              <stop offset="100%" stopColor={COLORS.emerald} />
            </linearGradient>
          </defs>
          {[0, 0.25, 0.5, 0.75, 1].map((g) => {
            const y = GH - PAD - g * (GH - PAD * 2);
            return <line key={g} x1={PAD} y1={y} x2={GW - PAD} y2={y} stroke="rgba(255,255,255,0.08)" strokeWidth={1} />;
          })}
          <path
            d={LINE}
            fill="none"
            stroke="url(#gi-stroke)"
            strokeWidth={8}
            strokeLinecap="round"
            strokeLinejoin="round"
            pathLength={1}
            strokeDasharray={1}
            strokeDashoffset={1 - draw}
            style={{ filter: `drop-shadow(0 6px 18px ${COLORS.emerald}55)` }}
          />
          {DAYS.map((d, i) => {
            const [x] = pt(i, 0);
            return (
              <text key={d} x={x} y={GH - PAD + 36} fill={COLORS.skyLight} fontFamily="monospace" fontSize={22} textAnchor="middle">
                {d}
              </text>
            );
          })}
          <circle cx={endX} cy={endY} r={13} fill={COLORS.emerald} opacity={draw > 0.9 ? 1 : 0} style={{ filter: `drop-shadow(0 0 16px ${COLORS.emerald})` }} />
        </svg>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
