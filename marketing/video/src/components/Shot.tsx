import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";

/**
 * Renders an app screenshot that fills the phone screen and can be panned /
 * zoomed to simulate scrolling. The screenshot is a single full-screen capture,
 * so we zoom slightly (>1) to create vertical room, then translate to reveal
 * different parts of the screen.
 *
 * `scroll` is a px offset applied as translateY (negative = scroll down/up the
 * page). `zoom` controls how much room there is to move.
 */
export const Shot: React.FC<{
  src: string; // e.g. SCREENS.nova
  scroll?: number;
  zoom?: number;
  /** Extra horizontal drift for parallax depth. */
  driftX?: number;
}> = ({ src, scroll = 0, zoom = 1, driftX = 0 }) => {
  return (
    <AbsoluteFill style={{ overflow: "hidden" }}>
      <Img
        src={staticFile(src)}
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "auto",
          transformOrigin: "top center",
          transform: `translate(${driftX}px, ${scroll}px) scale(${zoom})`,
          willChange: "transform",
        }}
      />
    </AbsoluteFill>
  );
};
