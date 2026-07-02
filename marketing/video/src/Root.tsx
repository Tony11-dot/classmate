import React from "react";
import { Composition } from "remotion";
import { ClassMateDemo } from "./Video";
import { loadFonts } from "./fonts";
import { FPS, HEIGHT, TOTAL_FRAMES, WIDTH } from "./theme";

loadFonts();

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="ClassMateDemo"
      component={ClassMateDemo}
      durationInFrames={TOTAL_FRAMES}
      fps={FPS}
      width={WIDTH}
      height={HEIGHT}
    />
  );
};
