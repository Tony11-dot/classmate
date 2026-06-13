import React from "react";
import { Img, staticFile } from "remotion";

/**
 * The ClassMate app icon — the CM monogram on a white rounded tile (matches the
 * real iOS app icon). Replaces the old literal "C".
 */
export const BrandMark: React.FC<{ size?: number; style?: React.CSSProperties }> = ({
  size = 150,
  style,
}) => {
  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: size * 0.225,
        background: "#FFFFFF",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        boxShadow: `inset 0 0 0 1px rgba(8,12,30,0.06)`,
        overflow: "hidden",
        ...style,
      }}
    >
      <Img
        src={staticFile("brand/cm-icon.png")}
        style={{ width: "82%", height: "82%", objectFit: "contain" }}
      />
    </div>
  );
};
