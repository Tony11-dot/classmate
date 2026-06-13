import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

/** Cinematic dark backdrop with a slow-drifting brand glow. */
export const SceneBG: React.FC<{
  tint?: string;
  variant?: "indigo" | "warm" | "night";
}> = ({ tint, variant = "indigo" }) => {
  const frame = useCurrentFrame();
  const drift = Math.sin(frame / 60) * 3;

  const base =
    variant === "warm"
      ? `linear-gradient(160deg, ${COLORS.ink}, ${COLORS.indigoDeep})`
      : variant === "night"
        ? `linear-gradient(160deg, #05080f, ${COLORS.ink})`
        : `radial-gradient(120% 120% at 50% 0%, ${COLORS.indigoDeep}, ${COLORS.ink})`;

  return (
    <AbsoluteFill style={{ background: base }}>
      <AbsoluteFill
        style={{
          background: `radial-gradient(46% 50% at ${20 + drift}% 24%, ${tint ?? COLORS.indigoSoft}55 0%, transparent 60%),
                       radial-gradient(48% 52% at ${82 - drift}% 82%, ${COLORS.sky}33 0%, transparent 62%)`,
        }}
      />
    </AbsoluteFill>
  );
};
