import React from "react";
import { SHOT } from "../theme";

/**
 * A light / silver iPhone frame that holds an app screen.
 * `screenWidth` is the visible screen width in px; the body is sized around it
 * to the real screenshot aspect ratio (1206×2622).
 */
export const PhoneLight: React.FC<{
  children: React.ReactNode;
  screenWidth?: number;
  style?: React.CSSProperties;
  glow?: boolean;
}> = ({ children, screenWidth = 360, style, glow = true }) => {
  const bezel = Math.round(screenWidth * 0.035);
  const screenH = Math.round((screenWidth * SHOT.h) / SHOT.w);
  const outerW = screenWidth + bezel * 2;
  const outerH = screenH + bezel * 2;
  const radius = Math.round(screenWidth * 0.155);

  return (
    <div
      style={{
        width: outerW,
        height: outerH,
        borderRadius: radius,
        padding: bezel,
        // Brushed-silver light frame.
        background:
          "linear-gradient(150deg, #fdfdff 0%, #d7dce8 22%, #aeb6c8 50%, #e8ecf5 78%, #c4ccdc 100%)",
        boxShadow: glow
          ? "0 60px 130px rgba(8,12,30,0.55), 0 8px 24px rgba(8,12,30,0.35), inset 0 1px 2px rgba(255,255,255,0.9)"
          : "0 30px 70px rgba(8,12,30,0.4)",
        position: "relative",
        ...style,
      }}
    >
      {/* Screen */}
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
        {children}
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
      </div>
    </div>
  );
};
