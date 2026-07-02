import React from "react";
import { SHOT, COLORS } from "../theme";
import { Shot } from "./Shot";

/**
 * A rim-lit hero phone standing on the Podium, with a real mirrored floor
 * reflection and a coloured screen-light cast. Screenshot aspect is 1206×2622.
 *
 * The component is centred on its own origin; the *bottom edge* of the phone is
 * where it "touches" the podium, so place it with the podium at that point.
 */
export const HeroPhone: React.FC<{
  src: string;
  screenWidth?: number;
  scroll?: number;
  zoom?: number;
  /** Rim-light hue catching the phone's left/right edges. */
  rim?: string;
  /** Show the mirrored floor reflection. */
  reflection?: boolean;
}> = ({
  src,
  screenWidth = 300,
  scroll = 0,
  zoom = 1,
  rim = COLORS.sky,
  reflection = true,
}) => {
  const bezel = Math.round(screenWidth * 0.035);
  const screenH = Math.round((screenWidth * SHOT.h) / SHOT.w);
  const outerW = screenWidth + bezel * 2;
  const outerH = screenH + bezel * 2;
  const radius = Math.round(screenWidth * 0.155);

  const Frame = (
    <div
      style={{
        width: outerW,
        height: outerH,
        borderRadius: radius,
        padding: bezel,
        background:
          "linear-gradient(150deg, #fdfdff 0%, #d7dce8 20%, #a9b2c6 48%, #eef1f8 74%, #b9c2d4 100%)",
        boxShadow: [
          "0 50px 110px rgba(0,0,0,0.6)",
          "0 10px 30px rgba(0,0,0,0.5)",
          `inset 0 1px 2px rgba(255,255,255,0.9)`,
          // rim light catching both edges
          `inset 14px 0 26px -12px ${rim}`,
          `inset -14px 0 26px -12px ${rim}`,
        ].join(", "),
        position: "relative",
      }}
    >
      <div
        style={{
          width: screenWidth,
          height: screenH,
          borderRadius: Math.round(radius * 0.82),
          overflow: "hidden",
          position: "relative",
          background: "#EAF2FF",
          boxShadow: "inset 0 0 0 1px rgba(0,0,0,0.06)",
        }}
      >
        <Shot src={src} scroll={scroll} zoom={zoom} />
        {/* Dynamic island */}
        <div
          style={{
            position: "absolute",
            top: Math.round(screenWidth * 0.03),
            left: "50%",
            transform: "translateX(-50%)",
            width: Math.round(screenWidth * 0.3),
            height: Math.round(screenWidth * 0.085),
            borderRadius: 999,
            background: "#0a0e16",
            zIndex: 5,
          }}
        />
        {/* Screen glare — a diagonal sheen sweeping the glass. */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            background:
              "linear-gradient(115deg, rgba(255,255,255,0.22) 0%, transparent 22%, transparent 78%, rgba(255,255,255,0.10) 100%)",
            mixBlendMode: "screen",
            pointerEvents: "none",
          }}
        />
      </div>
    </div>
  );

  return (
    <div style={{ position: "relative", width: outerW }}>
      {/* Coloured light the screen casts down onto the podium. */}
      <div
        style={{
          position: "absolute",
          left: "50%",
          bottom: -outerH * 0.14,
          width: outerW * 1.5,
          height: outerH * 0.5,
          transform: "translateX(-50%)",
          background: `radial-gradient(50% 50% at 50% 0%, ${rim}44 0%, transparent 70%)`,
          filter: "blur(20px)",
          mixBlendMode: "screen",
          pointerEvents: "none",
        }}
      />

      {Frame}

      {/* Mirrored floor reflection. */}
      {reflection ? (
        <div
          style={{
            position: "absolute",
            top: outerH,
            left: 0,
            width: outerW,
            height: outerH,
            transform: "scaleY(-1)",
            transformOrigin: "top",
            opacity: 0.28,
            filter: "blur(2px)",
            maskImage: "linear-gradient(to bottom, black, transparent 55%)",
            WebkitMaskImage: "linear-gradient(to bottom, black, transparent 55%)",
            pointerEvents: "none",
          }}
        >
          {Frame}
        </div>
      ) : null}
    </div>
  );
};
