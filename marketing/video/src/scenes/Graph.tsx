import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { COLORS, FONTS } from "../theme";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri"];
// Attendance rate per day (0..1) — a confident upward trend.
const VALUES = [0.78, 0.84, 0.88, 0.93, 0.96];

const W = 1100;
const H = 520;
const PAD = 70;

function pointFor(i: number, v: number) {
  const x = PAD + (i / (VALUES.length - 1)) * (W - PAD * 2);
  const y = H - PAD - v * (H - PAD * 2);
  return [x, y] as const;
}

const LINE = VALUES.map((v, i) => {
  const [x, y] = pointFor(i, v);
  return `${i === 0 ? "M" : "L"}${x.toFixed(1)},${y.toFixed(1)}`;
}).join(" ");

const AREA = `${LINE} L${(W - PAD).toFixed(1)},${(H - PAD).toFixed(1)} L${PAD.toFixed(
  1,
)},${(H - PAD).toFixed(1)} Z`;

/**
 * Scene 6 — Attendance graph.
 * A line draws itself left→right with a gold→green gradient while a counter
 * climbs to the final attendance rate. The end point pulses.
 */
export const Graph: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const draw = interpolate(frame, [20, 110], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const areaIn = interpolate(frame, [80, 130], [0, 0.18], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const counter = Math.round(interpolate(draw, [0, 1], [0, 96]));
  const [endX, endY] = pointFor(VALUES.length - 1, VALUES[VALUES.length - 1]);
  const dotIn = spring({ frame: frame - 108, fps, config: { damping: 10 } });
  const pulse = 1 + Math.sin(frame / 6) * 0.08 * (frame > 108 ? 1 : 0);

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(160deg, ${COLORS.ink}, ${COLORS.indigoDeep})`,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
      }}
    >
      <div
        style={{
          fontFamily: FONTS.display,
          fontWeight: 800,
          fontSize: 60,
          color: "#fff",
          letterSpacing: "-0.03em",
          opacity: interpolate(frame, [0, 20], [0, 1]),
          marginBottom: 6,
        }}
      >
        Attendance this week
      </div>
      <div
        style={{
          fontFamily: FONTS.mono,
          fontSize: 130,
          fontWeight: 700,
          letterSpacing: "-0.02em",
          backgroundImage: `linear-gradient(90deg, ${COLORS.gold}, ${COLORS.green})`,
          WebkitBackgroundClip: "text",
          backgroundClip: "text",
          color: "transparent",
        }}
      >
        {counter}
        <span style={{ fontSize: 70 }}>%</span>
      </div>

      <svg width={W} height={H} style={{ overflow: "visible" }}>
        <defs>
          <linearGradient id="stroke" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stopColor={COLORS.gold} />
            <stop offset="100%" stopColor={COLORS.green} />
          </linearGradient>
          <linearGradient id="area" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={COLORS.green} />
            <stop offset="100%" stopColor={COLORS.green} stopOpacity={0} />
          </linearGradient>
        </defs>

        {/* Grid lines */}
        {[0, 0.25, 0.5, 0.75, 1].map((g) => {
          const y = H - PAD - g * (H - PAD * 2);
          return (
            <line
              key={g}
              x1={PAD}
              y1={y}
              x2={W - PAD}
              y2={y}
              stroke="rgba(255,255,255,0.08)"
              strokeWidth={1}
            />
          );
        })}

        {/* Filled area */}
        <path d={AREA} fill="url(#area)" opacity={areaIn} />

        {/* The line, drawn via normalized pathLength */}
        <path
          d={LINE}
          fill="none"
          stroke="url(#stroke)"
          strokeWidth={8}
          strokeLinecap="round"
          strokeLinejoin="round"
          pathLength={1}
          strokeDasharray={1}
          strokeDashoffset={1 - draw}
          style={{ filter: `drop-shadow(0 6px 18px ${COLORS.green}55)` }}
        />

        {/* Day labels */}
        {DAYS.map((d, i) => {
          const [x] = pointFor(i, 0);
          return (
            <text
              key={d}
              x={x}
              y={H - PAD + 38}
              fill={COLORS.skyLight}
              fontFamily="monospace"
              fontSize={24}
              textAnchor="middle"
            >
              {d}
            </text>
          );
        })}

        {/* End dot */}
        <circle
          cx={endX}
          cy={endY}
          r={14 * pulse}
          fill={COLORS.green}
          opacity={dotIn}
          style={{ filter: `drop-shadow(0 0 16px ${COLORS.green})` }}
        />
      </svg>
    </AbsoluteFill>
  );
};
