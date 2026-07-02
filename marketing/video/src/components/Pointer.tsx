import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS } from "../theme";

export type Waypoint = { at: number; x: number; y: number };

/**
 * macOS-style cursor that springs between waypoints and click-presses at the
 * given frames (scale dip + expanding ring). Coordinates are px relative to
 * the station frame centre.
 */
export const Pointer: React.FC<{ waypoints: Waypoint[]; clicks?: number[]; scale?: number }> = ({ waypoints, clicks = [], scale = 1 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  if (frame < waypoints[0].at - 6) return null;

  let x = waypoints[0].x, y = waypoints[0].y;
  for (let i = 1; i < waypoints.length; i++) {
    const s = spring({ frame: frame - waypoints[i].at, fps, config: { damping: 16, mass: 0.7, stiffness: 160 } });
    x += (waypoints[i].x - waypoints[i - 1].x) * s;
    y += (waypoints[i].y - waypoints[i - 1].y) * s;
  }
  const appear = spring({ frame: frame - (waypoints[0].at - 6), fps, config: { damping: 14, stiffness: 200 } });
  let press = 1;
  for (const c of clicks) {
    press *= 1 - 0.18 * Math.sin(Math.PI * interpolate(frame, [c - 4, c + 8], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }));
  }

  return (
    <>
      {clicks.map((c, i) => {
        const t = interpolate(frame, [c, c + 18], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
        if (frame < c || t >= 1) return null;
        return (
          <div key={i} style={{ position: "absolute", left: `calc(50% + ${x}px)`, top: `calc(50% + ${y}px)`, width: 90 * (0.3 + t), height: 90 * (0.3 + t), transform: "translate(-50%,-50%)", borderRadius: "50%", border: `3px solid ${COLORS.sky}`, opacity: (1 - t) * 0.9 }} />
        );
      })}
      <div style={{ position: "absolute", left: `calc(50% + ${x}px)`, top: `calc(50% + ${y}px)`, transform: `translate(-4px,-2px) scale(${appear * press * scale})`, transformOrigin: "4px 2px", filter: "drop-shadow(0 6px 14px rgba(0,0,10,0.5))", zIndex: 40 }}>
        <svg width="34" height="44" viewBox="0 0 24 30">
          <path d="M4 2 L4 24 L9.5 19 L13 27.5 L16.5 26 L13 17.8 L20 17.5 Z" fill="#fff" stroke="#1a2033" strokeWidth="1.6" strokeLinejoin="round" />
        </svg>
      </div>
    </>
  );
};
