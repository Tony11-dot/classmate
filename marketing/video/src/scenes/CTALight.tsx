import React from "react";
import { AbsoluteFill, Img, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS } from "../theme";
import { AuroraLight } from "../components/AuroraLight";

/** Closing card — mark, wordmark, tagline, CTA button, URL. */
export const CTALight: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const pop = spring({ frame, fps, config: { damping: 12, stiffness: 120 } });
  const up = (d: number) => spring({ frame: frame - d, fps, config: { damping: 18, stiffness: 90 } });

  return (
    <AbsoluteFill>
      <AuroraLight hues={[COLORS.indigoSoft, COLORS.sky, COLORS.gold, COLORS.emerald]} />
      <AbsoluteFill style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 8 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 22, transform: `scale(${interpolate(pop, [0, 1], [0.7, 1])})`, opacity: pop }}>
          <div style={{ width: 118, height: 118, borderRadius: 30, background: `linear-gradient(150deg, ${COLORS.indigo}, ${COLORS.indigoDeep})`, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: `0 30px 66px -18px ${COLORS.indigo}aa` }}>
            <Img src={staticFile("brand/cm-icon.png")} style={{ width: 78, height: 78, objectFit: "contain" }} />
          </div>
          <div style={{ fontFamily: FONTS.display, fontSize: 96, fontWeight: 800, color: COLORS.ink, letterSpacing: -2 }}>ClassMate</div>
        </div>

        <div style={{ fontFamily: FONTS.body, fontSize: 32, color: COLORS.ink, opacity: interpolate(up(8), [0, 1], [0, 0.62]), transform: `translateY(${interpolate(up(8), [0, 1], [16, 0])}px)`, marginTop: 14 }}>
          Your whole school — in one app.
        </div>

        <div
          style={{
            marginTop: 40, opacity: up(16), transform: `translateY(${interpolate(up(16), [0, 1], [18, 0])}px)`,
            fontFamily: FONTS.body, fontSize: 30, fontWeight: 700, color: "#fff",
            background: `linear-gradient(120deg, ${COLORS.indigo}, ${COLORS.sky})`,
            padding: "20px 44px", borderRadius: 999,
            boxShadow: `0 22px 50px -16px ${COLORS.indigo}cc`,
          }}
        >
          Get the app →
        </div>

        <div style={{ marginTop: 26, opacity: up(24), fontFamily: FONTS.mono, fontSize: 26, letterSpacing: 2, color: COLORS.indigo, fontWeight: 600 }}>
          classmateapp.org
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
