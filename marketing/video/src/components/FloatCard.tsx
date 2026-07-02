import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { SHOT } from "../theme";
import { Shot } from "./Shot";

/**
 * A rounded, soft-shadowed card that floats in 3D space (ref1 aesthetic). It
 * "explodes" out from the cluster centre on entry, then idles with a gentle
 * parallax drift + bob. Can show a cropped app screenshot or arbitrary content.
 */
export const FloatCard: React.FC<{
  /** Target position relative to cluster centre, in px. */
  x: number;
  y: number;
  /** Depth — positive = toward camera (bigger), negative = back. */
  z?: number;
  /** Card width in px. Height derives from the screenshot crop. */
  w?: number;
  /** How tall a slice of the phone screen to show (fraction 0..1). */
  crop?: number;
  /** Scroll offset into the screenshot (px at full res-scaled). */
  scroll?: number;
  src?: string;
  children?: React.ReactNode;
  rot?: number;
  /** Stagger — frames to delay the explode entrance. */
  delay?: number;
  /** Per-card drift phase so they don't move in lockstep. */
  seed?: number;
  tint?: string;
}> = ({ x, y, z = 0, w = 220, crop = 0.42, scroll = 0, src, children, rot = 0, delay = 0, seed = 0, tint }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const enterAt = (f: number) =>
    spring({ frame: f - delay, fps, config: { damping: 12, mass: 0.7, stiffness: 190 } });
  const enter = enterAt(frame);
  const driftX = Math.sin(frame / 34 + seed) * 9;
  const driftY = Math.cos(frame / 28 + seed * 1.7) * 11;
  const driftR = Math.sin(frame / 44 + seed) * 1.6;

  // Explode from centre with real velocity blur on the way out.
  const px = interpolate(enter, [0, 1], [0, x]) + driftX;
  const py = interpolate(enter, [0, 1], [0, y]) + driftY;
  const pz = interpolate(enter, [0, 1], [-140, z]);
  const scale = interpolate(enter, [0, 1], [0.2, 1]);
  const rotZ = interpolate(enter, [0, 1], [rot * 0.3, rot]) + driftR;
  const vel = Math.abs(enterAt(frame) - enterAt(frame - 1)) * Math.hypot(x, y);
  const blur = Math.min(8, vel * 0.06);

  const h = Math.round(w * (SHOT.h / SHOT.w) * crop);
  const radius = Math.round(w * 0.11);

  return (
    <div
      style={{
        position: "absolute",
        left: "50%",
        top: "50%",
        width: w,
        height: children ? undefined : h,
        transform: `translate(-50%,-50%) translate3d(${px}px, ${py}px, ${pz}px) rotate(${rotZ}deg) scale(${scale})`,
        transformStyle: "preserve-3d",
        opacity: interpolate(enter, [0, 0.25], [0, 1], { extrapolateRight: "clamp" }),
        borderRadius: radius,
        overflow: "hidden",
        background: "#ffffff",
        boxShadow: `0 30px 60px -18px rgba(20,30,80,0.35), 0 8px 20px -10px rgba(20,30,80,0.25), inset 0 0 0 1px rgba(255,255,255,0.9)`,
        filter: blur > 0.5 ? `blur(${blur}px)` : undefined,
        willChange: "transform",
      }}
    >
      {src ? <div style={{ position: "relative", width: w, height: h }}><Shot src={src} scroll={scroll} zoom={1} /></div> : null}
      {children ? <div style={{ padding: Math.round(w * 0.08) }}>{children}</div> : null}
      {/* subtle tint glaze so cards read as glass */}
      {tint ? (
        <div style={{ position: "absolute", inset: 0, background: `linear-gradient(150deg, ${tint}14, transparent 60%)`, pointerEvents: "none" }} />
      ) : null}
    </div>
  );
};
