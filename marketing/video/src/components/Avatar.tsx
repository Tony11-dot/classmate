import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { FONTS } from "../theme";

type AvatarProps = {
  initials: string;
  /** Two-stop gradient for the disc. */
  colors: [string, string];
  size?: number;
  /** Frames to wait before the pop-in spring fires. */
  delay?: number;
  ring?: boolean;
};

/** A gradient disc with centered initials — pops in with a spring. */
export const Avatar: React.FC<AvatarProps> = ({
  initials,
  colors,
  size = 120,
  delay = 0,
  ring = false,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const pop = spring({
    frame: frame - delay,
    fps,
    config: { damping: 12, stiffness: 140, mass: 0.7 },
  });
  const scale = interpolate(pop, [0, 1], [0.4, 1]);
  const opacity = interpolate(pop, [0, 1], [0, 1]);

  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: "50%",
        background: `linear-gradient(140deg, ${colors[0]}, ${colors[1]})`,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        color: "#fff",
        fontFamily: FONTS.display,
        fontWeight: 700,
        fontSize: size * 0.4,
        letterSpacing: "-0.02em",
        transform: `scale(${scale})`,
        opacity,
        boxShadow: ring
          ? `0 0 0 ${size * 0.05}px rgba(255,255,255,0.16), 0 18px 40px rgba(8,12,30,0.45)`
          : "0 18px 40px rgba(8,12,30,0.45)",
      }}
    >
      {initials}
    </div>
  );
};
