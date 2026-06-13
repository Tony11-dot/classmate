import React from "react";
import {
  AbsoluteFill,
  interpolate,
  Sequence,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { PhoneLight } from "../components/PhoneLight";
import { Shot } from "../components/Shot";
import { SceneBG } from "../components/SceneBG";
import { LightLeak } from "../components/LightLeak";
import { COLORS, FONTS, SCREENS, SHOT } from "../theme";

const CUT = 66;

const Cut: React.FC<{
  kicker: string;
  title: string;
  src?: string;
  dir: number; // slide direction
  tint: string;
  variant: "indigo" | "warm" | "night";
}> = ({ kicker, title, src, dir, tint, variant }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const screenW = 300;
  const screenH = (screenW * SHOT.h) / SHOT.w;

  const enter = spring({ frame, fps, config: { damping: 16, stiffness: 130 } });
  const x = interpolate(enter, [0, 1], [dir * 160, 0]);
  const out = interpolate(frame, [CUT - 14, CUT], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const titleIn = spring({ frame: frame - 6, fps, config: { damping: 14 } });

  return (
    <AbsoluteFill style={{ opacity: out }}>
      <SceneBG tint={tint} variant={variant} />
      <LightLeak life={26} hue={COLORS.gold} from={dir > 0 ? "left" : "right"} />
      <AbsoluteFill
        style={{
          flexDirection: "row",
          alignItems: "center",
          justifyContent: "center",
          gap: 90,
          padding: "0 140px",
        }}
      >
        <div
          style={{
            order: dir > 0 ? 1 : 0,
            maxWidth: 560,
            textAlign: dir > 0 ? "right" : "left",
            transform: `translateY(${interpolate(titleIn, [0, 1], [40, 0])}px)`,
            opacity: titleIn,
          }}
        >
          <div style={{ fontFamily: FONTS.mono, color: COLORS.gold, letterSpacing: "0.26em", fontSize: 22, textTransform: "uppercase" }}>
            {kicker}
          </div>
          <div style={{ fontFamily: FONTS.display, fontWeight: 800, fontSize: 82, color: "#fff", letterSpacing: "-0.045em", lineHeight: 1.02, marginTop: 10 }}>
            {title}
          </div>
        </div>
        {src ? (
          <div style={{ transform: `translateX(${x}px) rotate(${dir * -2}deg)`, filter: "drop-shadow(0 36px 80px rgba(0,0,0,0.5))" }}>
            <PhoneLight screenWidth={screenW}>
              <Shot src={src} scroll={interpolate(frame, [0, CUT], [0, -screenH * 0.06])} zoom={1.06} />
            </PhoneLight>
          </div>
        ) : null}
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

/** Scene — fast feature montage. */
export const Montage: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: COLORS.ink }}>
      <Sequence from={0} durationInFrames={CUT}>
        <Cut kicker="Schedule" title="Your whole day" src={SCREENS.schedule} dir={1} tint={COLORS.indigoSoft} variant="indigo" />
      </Sequence>
      <Sequence from={CUT} durationInFrames={CUT}>
        <Cut kicker="Solutions" title="A library of answers" src={SCREENS.solutions} dir={-1} tint={COLORS.sky} variant="night" />
      </Sequence>
      <Sequence from={CUT * 2} durationInFrames={CUT}>
        <Cut kicker="One app" title="Every role" src={SCREENS.menu} dir={1} tint={COLORS.emerald} variant="warm" />
      </Sequence>
    </AbsoluteFill>
  );
};
