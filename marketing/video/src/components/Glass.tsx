import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

/**
 * Liquid-glass world v2 — ALWAYS moving:
 * · two gradient-mesh layers drifting at different speeds (+ camera parallax)
 * · hue breathing between accent pairs
 * · grid that pans continuously
 * · glass shards floating with momentum, parallaxed against camera travel
 * · perpetual diagonal light sweep
 */
export const GlassBG: React.FC<{ accent?: string; accent2?: string; shards?: boolean; camX?: number; camY?: number }> = ({
  accent = COLORS.sky,
  accent2 = "#8B5CF6",
  shards = true,
  camX = 0,
  camY = 0,
}) => {
  const frame = useCurrentFrame();
  const d = (n: number) => Math.sin(frame / (30 + n * 6) + n * 1.7) * 8;
  const sweep = ((frame * 0.8) % 170) - 35;
  const hueMix = 0.5 + 0.5 * Math.sin(frame / 210);
  // parallax offsets (bg slower than camera)
  const p1x = -camX * 0.06 + Math.sin(frame / 90) * 14;
  const p2x = -camX * 0.14 - Math.sin(frame / 70) * 10;
  const psx = -camX * 0.3;
  const psy = -camY * 0.3;

  return (
    <AbsoluteFill style={{ background: "linear-gradient(160deg,#0B0F1E 0%,#090C16 55%,#0C1226 100%)" }}>
      {/* mesh layer A (far) */}
      <AbsoluteFill
        style={{
          transform: `translateX(${p1x}px)`,
          background: `radial-gradient(36% 42% at ${22 + d(0)}% ${30 + d(1)}%, ${accent}52 0%, transparent 64%),
                       radial-gradient(46% 52% at ${68 + d(1)}% ${84 - d(3)}%, ${COLORS.indigo}58 0%, transparent 62%)`,
          filter: "blur(12px)",
          opacity: 0.65 + 0.35 * hueMix,
        }}
      />
      {/* mesh layer B (nearer, counter-drift) */}
      <AbsoluteFill
        style={{
          transform: `translateX(${p2x}px)`,
          background: `radial-gradient(40% 46% at ${78 - d(2)}% ${24 + d(0)}%, ${accent2}4d 0%, transparent 66%),
                       radial-gradient(34% 40% at ${30 + d(3)}% ${74 + d(2)}%, ${accent}38 0%, transparent 60%)`,
          filter: "blur(14px)",
          opacity: 0.65 + 0.35 * (1 - hueMix),
        }}
      />
      {/* panning grid */}
      <AbsoluteFill
        style={{
          backgroundImage:
            "linear-gradient(rgba(255,255,255,0.034) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.034) 1px, transparent 1px)",
          backgroundSize: "88px 88px",
          backgroundPosition: `${-camX * 0.18 - frame * 0.25}px ${-camY * 0.18 - frame * 0.1}px`,
          maskImage: "radial-gradient(78% 78% at 50% 45%, black, transparent 92%)",
          WebkitMaskImage: "radial-gradient(78% 78% at 50% 45%, black, transparent 92%)",
        }}
      />
      {/* glass shards (near layer — strongest parallax + momentum bob) */}
      {shards
        ? [0, 1, 2, 3].map((i) => (
            <div
              key={i}
              style={{
                position: "absolute",
                left: `calc(${6 + i * 27}% + ${psx * (0.7 + i * 0.15)}px)`,
                top: `calc(${12 + (i % 2) * 58}% + ${psy}px)`,
                width: 210 + i * 55,
                height: 130 + i * 28,
                borderRadius: 30,
                transform: `rotate(${-12 + i * 8 + Math.sin(frame / 34 + i) * 3}deg) translateY(${Math.sin(frame / 26 + i * 2.1) * 16}px)`,
                background: "linear-gradient(135deg, rgba(255,255,255,0.10), rgba(255,255,255,0.02))",
                border: "1px solid rgba(255,255,255,0.15)",
                boxShadow: "inset 0 1px 0 rgba(255,255,255,0.28), 0 34px 70px -34px rgba(0,0,0,0.65)",
                backdropFilter: "blur(7px)",
                WebkitBackdropFilter: "blur(7px)",
                opacity: 0.75,
              }}
            />
          ))
        : null}
      {/* light sweep */}
      <AbsoluteFill
        style={{
          background: `linear-gradient(115deg, transparent ${sweep}%, rgba(255,255,255,0.06) ${sweep + 8}%, transparent ${sweep + 16}%)`,
          mixBlendMode: "screen",
        }}
      />
      <AbsoluteFill style={{ background: "radial-gradient(80% 80% at 50% 45%, transparent 55%, rgba(0,0,0,0.5) 100%)" }} />
    </AbsoluteFill>
  );
};

/** Frosted liquid-glass panel/pill with specular top edge. */
export const LiquidPanel: React.FC<{
  children: React.ReactNode;
  radius?: number;
  pad?: string;
  style?: React.CSSProperties;
}> = ({ children, radius = 999, pad = "12px 26px", style }) => (
  <div
    style={{
      display: "inline-flex",
      alignItems: "center",
      gap: 12,
      padding: pad,
      borderRadius: radius,
      background: "linear-gradient(135deg, rgba(255,255,255,0.13), rgba(255,255,255,0.05))",
      border: "1px solid rgba(255,255,255,0.18)",
      boxShadow: "inset 0 1px 0 rgba(255,255,255,0.32), 0 18px 44px -18px rgba(0,0,0,0.6)",
      backdropFilter: "blur(16px)",
      WebkitBackdropFilter: "blur(16px)",
      ...style,
    }}
  >
    {children}
  </div>
);
