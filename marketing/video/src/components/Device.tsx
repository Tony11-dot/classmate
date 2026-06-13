import React from "react";
import { COLORS } from "../theme";

/** A clean phone mock used by the teacher / parent / student scenes. */
export const Device: React.FC<{
  children: React.ReactNode;
  width?: number;
  style?: React.CSSProperties;
}> = ({ children, width = 460, style }) => {
  const height = width * 2.06;
  return (
    <div
      style={{
        width,
        height,
        borderRadius: width * 0.13,
        padding: width * 0.03,
        background: "linear-gradient(160deg, #1b2333, #070b14)",
        boxShadow:
          "0 60px 120px rgba(6,9,22,0.6), inset 0 1px 0 rgba(255,255,255,0.12)",
        border: "1px solid rgba(255,255,255,0.08)",
        position: "relative",
        ...style,
      }}
    >
      {/* Notch */}
      <div
        style={{
          position: "absolute",
          top: width * 0.045,
          left: "50%",
          transform: "translateX(-50%)",
          width: width * 0.34,
          height: width * 0.05,
          borderRadius: 999,
          background: "#05080f",
          zIndex: 3,
        }}
      />
      {/* Screen */}
      <div
        style={{
          width: "100%",
          height: "100%",
          borderRadius: width * 0.1,
          overflow: "hidden",
          background: COLORS.paper,
          position: "relative",
        }}
      >
        {children}
      </div>
    </div>
  );
};
