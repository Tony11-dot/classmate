import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { FONTS } from "../theme";

/**
 * iOS-liquid-glass tab bar whose "tabs" are the words of the scene's phrase —
 * each tab pops and lights up in sync with the VO (the user's navbar idea).
 * Replaces big captions: minimal text, maximum glass.
 */
export const GlassDock: React.FC<{
  words: string[];
  /** activation frame per word (station-local). */
  at: number[];
  accent?: string;
  y?: string;
}> = ({ words, at, accent = "#9DBBFF", y = "87%" }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const dockIn = spring({ frame: frame - (at[0] - 10), fps, config: { damping: 15, mass: 0.7, stiffness: 190 } });
  if (frame < at[0] - 14) return null;

  return (
    <div style={{ position: "absolute", left: "50%", top: y, transform: `translate(-50%,-50%) translateY(${(1 - dockIn) * 60}px) scale(${0.9 + 0.1 * dockIn})`, opacity: dockIn }}>
      <div
        style={{
          display: "flex",
          gap: 10,
          padding: 10,
          borderRadius: 999,
          background: "linear-gradient(135deg, rgba(255,255,255,0.13), rgba(255,255,255,0.05))",
          border: "1.5px solid rgba(255,255,255,0.2)",
          boxShadow: "inset 0 1.5px 0 rgba(255,255,255,0.3), 0 26px 60px -20px rgba(0,0,0,0.7)",
          backdropFilter: "blur(20px)",
          WebkitBackdropFilter: "blur(20px)",
        }}
      >
        {words.map((w, i) => {
          const s = spring({ frame: frame - at[i], fps, config: { damping: 12, mass: 0.6, stiffness: 240 } });
          const active = frame >= at[i];
          const breathe = 1 + 0.02 * Math.sin(frame / 16 + i * 2);
          return (
            <div
              key={i}
              style={{
                padding: "13px 28px",
                borderRadius: 999,
                fontFamily: FONTS.body,
                fontWeight: 800,
                fontSize: 28,
                letterSpacing: 0.5,
                color: active ? "#FFFFFF" : "rgba(255,255,255,0.35)",
                background: active ? `linear-gradient(135deg, ${accent}55, rgba(255,255,255,0.10))` : "transparent",
                boxShadow: active ? `inset 0 1px 0 rgba(255,255,255,0.35), 0 0 ${24 * Math.min(1, s)}px ${accent}66` : undefined,
                transform: `scale(${active ? (0.8 + 0.2 * s) * breathe : 1}) translateY(${active ? (1 - s) * 10 : 0}px)`,
              }}
            >
              {w}
            </div>
          );
        })}
      </div>
    </div>
  );
};

/** Animated spotlight — dims the world except a moving circular focus. */
export const Spot: React.FC<{ keys: Array<{ at: number; x: number; y: number; r?: number }>; strength?: number }> = ({ keys, strength = 0.45 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  if (frame < keys[0].at) return null;
  let x = keys[0].x, y = keys[0].y, r = keys[0].r ?? 420;
  for (let i = 1; i < keys.length; i++) {
    const s = spring({ frame: frame - keys[i].at, fps, config: { damping: 17, mass: 0.8, stiffness: 140 } });
    x += (keys[i].x - keys[i - 1].x) * s;
    y += (keys[i].y - keys[i - 1].y) * s;
    r += ((keys[i].r ?? 420) - (keys[i - 1].r ?? 420)) * s;
  }
  const fadeIn = interpolate(frame, [keys[0].at, keys[0].at + 14], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  return (
    <div
      style={{
        position: "absolute",
        inset: 0,
        pointerEvents: "none",
        background: `radial-gradient(circle ${r}px at calc(50% + ${x}px) calc(50% + ${y}px), transparent 55%, rgba(2,4,12,${strength}) 100%)`,
        opacity: fadeIn,
      }}
    />
  );
};
