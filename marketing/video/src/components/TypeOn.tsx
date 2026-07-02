import React from "react";
import { useCurrentFrame, useVideoConfig } from "remotion";

/**
 * Types a string out character-by-character with a blinking caret, driven by
 * the frame. Used to make the NOVA message box look like it's being typed.
 */
export const TypeOn: React.FC<{
  text: string;
  /** Frame to begin typing. */
  start?: number;
  /** Characters per second. */
  cps?: number;
  style?: React.CSSProperties;
  caret?: boolean;
}> = ({ text, start = 0, cps = 22, style, caret = true }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const elapsed = Math.max(0, frame - start);
  const n = Math.min(text.length, Math.floor((elapsed / fps) * cps));
  const shown = text.slice(0, n);
  const blink = Math.floor((frame / fps) * 2) % 2 === 0;
  const done = n >= text.length;

  return (
    <span style={style}>
      {shown}
      {caret && (!done || blink) ? (
        <span style={{ opacity: done ? (blink ? 1 : 0) : 1, fontWeight: 300 }}>|</span>
      ) : null}
    </span>
  );
};
