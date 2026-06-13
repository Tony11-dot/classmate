import React from "react";
import { AbsoluteFill, Audio, staticFile } from "remotion";
import {
  linearTiming,
  TransitionSeries,
} from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { wipe } from "@remotion/transitions/wipe";

import { loadFonts } from "./fonts";
import { Grade } from "./components/Grade";
import { MUSIC_ENABLED, MUSIC_SRC, SCENES, TRANSITION } from "./theme";

import { ColdOpen } from "./scenes/ColdOpen";
import { Promise as PromiseScene } from "./scenes/Promise";
import { Attendance } from "./scenes/Attendance";
import { Notification } from "./scenes/Notification";
import { Checkin } from "./scenes/Checkin";
import { Graph } from "./scenes/Graph";
import { CTA } from "./scenes/CTA";

loadFonts();

const t = () => linearTiming({ durationInFrames: TRANSITION });

export const ClassMateDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: "#05080f" }}>
      <TransitionSeries>
        <TransitionSeries.Sequence durationInFrames={SCENES.coldOpen}>
          <ColdOpen />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition presentation={fade()} timing={t()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.promise}>
          <PromiseScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={slide({ direction: "from-right" })}
          timing={t()}
        />

        <TransitionSeries.Sequence durationInFrames={SCENES.attendance}>
          <Attendance />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={wipe({ direction: "from-left" })}
          timing={t()}
        />

        <TransitionSeries.Sequence durationInFrames={SCENES.notification}>
          <Notification />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={slide({ direction: "from-bottom" })}
          timing={t()}
        />

        <TransitionSeries.Sequence durationInFrames={SCENES.checkin}>
          <Checkin />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition presentation={fade()} timing={t()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.graph}>
          <Graph />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={wipe({ direction: "from-right" })}
          timing={t()}
        />

        <TransitionSeries.Sequence durationInFrames={SCENES.cta}>
          <CTA />
        </TransitionSeries.Sequence>
      </TransitionSeries>

      {/* Cinematic color grade on top of everything. */}
      <Grade />

      {/* Royalty-free music hook — off by default (see README "Music"). */}
      {MUSIC_ENABLED ? <Audio src={staticFile(MUSIC_SRC)} volume={0.55} /> : null}
    </AbsoluteFill>
  );
};
