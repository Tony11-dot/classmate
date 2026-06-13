import React from "react";
import { interpolate, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

/**
 * A soft circular "finger" / touch indicator that travels to a point and
 * presses (scale dip + expanding ripple) at `tapAt`. Positions are in px
 * relative to the parent (the phone screen).
 */
export const Finger: React.FC<{
  fromX: number;
  fromY: number;
  toX: number;
  toY: number;
  /** Frame the move starts. */
  start: number;
  /** Frame the press lands. */
  tapAt: number;
  size?: number;
}> = ({ fromX, fromY, toX, toY, start, tapAt, size = 64 }) => {
  const frame = useCurrentFrame();

  const x = interpolate(frame, [start, tapAt], [fromX, toX], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const y = interpolate(frame, [start, tapAt], [fromY, toY], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const press = interpolate(
    frame,
    [tapAt - 6, tapAt, tapAt + 8],
    [1, 0.78, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  );
  const ripple = interpolate(frame, [tapAt, tapAt + 34], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const appear = interpolate(frame, [start - 6, start + 4], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: y,
        transform: "translate(-50%, -50%)",
        zIndex: 6,
        opacity: appear,
        pointerEvents: "none",
      }}
    >
      {/* Ripple */}
      <div
        style={{
          position: "absolute",
          left: "50%",
          top: "50%",
          width: size * 1.7,
          height: size * 1.7,
          marginLeft: -(size * 1.7) / 2,
          marginTop: -(size * 1.7) / 2,
          borderRadius: "50%",
          border: `3px solid ${COLORS.indigo}`,
          transform: `scale(${0.3 + ripple * 1.2})`,
          opacity: (1 - ripple) * 0.6,
        }}
      />
      {/* Touch disc */}
      <div
        style={{
          width: size,
          height: size,
          borderRadius: "50%",
          background:
            "radial-gradient(circle at 38% 32%, rgba(255,255,255,0.95), rgba(255,255,255,0.45) 55%, rgba(255,255,255,0.12) 75%)",
          border: "2px solid rgba(255,255,255,0.85)",
          boxShadow: `0 8px 24px rgba(8,12,30,0.45), 0 0 0 ${size * 0.06}px rgba(34,48,200,0.10)`,
          transform: `scale(${press})`,
        }}
      />
    </div>
  );
};
