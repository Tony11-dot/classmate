import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS } from "../theme";

/**
 * Kinetic typography — words bounce in one-by-one (scale overshoot + rise +
 * blur-in), timed to the VO. Prefix a word with "|" to tint it with
 * `highlight`. Pass `offsets` (frames, per word) to hand-sync to narration.
 */
export const WordPop: React.FC<{
  text: string;
  start?: number;
  step?: number;
  offsets?: number[];
  size?: number;
  color?: string;
  highlight?: string;
  weight?: number;
  /** Fade the whole line out at this local frame (optional). */
  out?: number;
}> = ({ text, start = 0, step = 8, offsets, size = 96, color = COLORS.ink, highlight = COLORS.indigo, weight = 800, out }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const words = text.split(" ").filter(Boolean);

  const exit = out !== undefined
    ? interpolate(frame, [out, out + 14], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })
    : 1;
  if (exit <= 0) return null;

  return (
    <div
      style={{
        display: "flex",
        flexWrap: "wrap",
        justifyContent: "center",
        columnGap: size * 0.26,
        rowGap: size * 0.08,
        fontFamily: FONTS.display,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: -size * 0.022,
        lineHeight: 1.04,
        opacity: exit,
        transform: `scale(${interpolate(exit, [0, 1], [1.06, 1])})`,
      }}
    >
      {words.map((raw, i) => {
        const hl = raw.startsWith("|");
        const w = hl ? raw.slice(1) : raw;
        const at = offsets ? offsets[Math.min(i, offsets.length - 1)] : start + i * step;
        const s = spring({ frame: frame - at, fps, config: { damping: 11, mass: 0.6, stiffness: 260 } });
        const blur = (1 - Math.min(1, s * 1.3)) * 10;
        return (
          <span
            key={i}
            style={{
              display: "inline-block",
              color: hl ? highlight : color,
              opacity: Math.min(1, s * 1.5),
              transform: `translateY(${interpolate(s, [0, 1], [size * 0.42, 0])}px) scale(${interpolate(s, [0, 1], [0.6, 1])})`,
              filter: blur > 0.5 ? `blur(${blur}px)` : undefined,
            }}
          >
            {w}
          </span>
        );
      })}
    </div>
  );
};
