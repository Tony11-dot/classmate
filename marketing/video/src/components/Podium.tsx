import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS } from "../theme";

/**
 * The glowing pedestal the hero phone stands on — the signature ref2 element.
 * A dark reflective disc seen in perspective, with a bright glowing core ring
 * that blooms upward and lights the phone's base. Render this *between* the
 * phone's reflection and the phone itself, centred under the device.
 *
 * `width` is the visual diameter of the disc in px. The glow scales with it.
 */
export const Podium: React.FC<{
  width?: number;
  hue?: string;
  /** Vertical offset of the disc centre from this element's origin. */
  y?: number;
}> = ({ width = 620, hue = COLORS.sky, y = 0 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const rise = spring({ frame, fps, config: { damping: 18, mass: 1.1, stiffness: 90 } });
  const breathe = 0.86 + 0.14 * (0.5 + 0.5 * Math.sin(frame / 40));
  const h = width * 0.32; // perspective-squashed ellipse height

  return (
    <div
      style={{
        position: "absolute",
        left: "50%",
        top: "50%",
        transform: `translate(-50%, ${y}px)`,
        width,
        height: h,
        pointerEvents: "none",
      }}
    >
      {/* Upward bloom — light rising off the ring into the phone base. */}
      <div
        style={{
          position: "absolute",
          left: "50%",
          bottom: h * 0.4,
          width: width * 0.7,
          height: width * 0.9,
          transform: "translateX(-50%)",
          background: `radial-gradient(50% 50% at 50% 100%, ${hue}${Math.round(
            0x55 * rise,
          ).toString(16).padStart(2, "0")} 0%, transparent 70%)`,
          filter: "blur(24px)",
          mixBlendMode: "screen",
          opacity: breathe,
        }}
      />

      {/* The dark disc body. */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          borderRadius: "50%",
          background:
            "radial-gradient(60% 100% at 50% 40%, #12182b 0%, #090d18 55%, #05070e 100%)",
          boxShadow: "0 40px 80px rgba(0,0,0,0.7), inset 0 -6px 20px rgba(0,0,0,0.6)",
          border: "1px solid rgba(255,255,255,0.05)",
        }}
      />

      {/* Bright glowing core ring. */}
      <div
        style={{
          position: "absolute",
          left: "50%",
          top: "50%",
          width: width * 0.66,
          height: h * 0.62,
          transform: "translate(-50%,-50%)",
          borderRadius: "50%",
          background: `radial-gradient(50% 50% at 50% 50%, ${COLORS.white} 0%, ${hue} 34%, ${hue}00 72%)`,
          filter: "blur(6px)",
          opacity: interpolate(rise, [0, 1], [0, 0.95]) * breathe,
          mixBlendMode: "screen",
        }}
      />
      {/* Hot inner core. */}
      <div
        style={{
          position: "absolute",
          left: "50%",
          top: "50%",
          width: width * 0.28,
          height: h * 0.3,
          transform: "translate(-50%,-50%)",
          borderRadius: "50%",
          background: `radial-gradient(50% 50% at 50% 50%, ${COLORS.white} 0%, ${hue}cc 45%, transparent 80%)`,
          filter: "blur(3px)",
          opacity: rise,
          mixBlendMode: "screen",
        }}
      />
    </div>
  );
};
