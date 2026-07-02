import React from "react";
import { AbsoluteFill, Composition } from "remotion";
import { ClassMateDemo } from "./Video";
import { StudioHero } from "./scenes/StudioHero";
import { loadFonts } from "./fonts";
import { COLORS, FPS, HEIGHT, SCREENS, TOTAL_FRAMES, WIDTH } from "./theme";

loadFonts();

/** Preview harness for the new premium studio look (one scene). */
const HeroPreview: React.FC = () => (
  <AbsoluteFill style={{ backgroundColor: "#03050b" }}>
    <StudioHero
      src={SCREENS.nova}
      kicker="AI Tutor"
      title={"Ask NOVA\nanything"}
      sub="A step-by-step tutor for every student — in five languages."
      rim={COLORS.sky}
      hue2={COLORS.indigoSoft}
      side="left"
    />
  </AbsoluteFill>
);

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="ClassMateDemo"
        component={ClassMateDemo}
        durationInFrames={TOTAL_FRAMES}
        fps={FPS}
        width={WIDTH}
        height={HEIGHT}
      />
      <Composition
        id="HeroPreview"
        component={HeroPreview}
        durationInFrames={150}
        fps={FPS}
        width={WIDTH}
        height={HEIGHT}
      />
    </>
  );
};
