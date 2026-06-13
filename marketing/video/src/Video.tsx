import React from "react";
import { AbsoluteFill, Audio, staticFile } from "remotion";
import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { wipe } from "@remotion/transitions/wipe";

import { loadFonts } from "./fonts";
import { Grade } from "./components/Grade";
import { MUSIC_ENABLED, MUSIC_SRC, SCENES, TRANSITION } from "./theme";

import { ColdOpen } from "./scenes/ColdOpen";
import { Promise as PromiseScene } from "./scenes/Promise";
import { AttendanceNotify } from "./scenes/AttendanceNotify";
import { Nova } from "./scenes/Nova";
import { Classroom } from "./scenes/Classroom";
import { Practice } from "./scenes/Practice";
import { GradesInsights } from "./scenes/GradesInsights";
import { Montage } from "./scenes/Montage";
import { CTA } from "./scenes/CTA";

loadFonts();

const t = () => linearTiming({ durationInFrames: TRANSITION });

/**
 * ClassMate product demo v2 — 90s, 9 scenes, real app UI animated inside a
 * light iPhone frame. Cold open → promise → attendance/notify → NOVA →
 * classroom → practice → grades/insights → feature montage → CTA.
 */
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
        <TransitionSeries.Transition presentation={wipe({ direction: "from-bottom" })} timing={t()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.attnotify}>
          <AttendanceNotify />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-right" })} timing={t()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.nova}>
          <Nova />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-left" })} timing={t()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.classroom}>
          <Classroom />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={t()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.practice}>
          <Practice />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={wipe({ direction: "from-right" })} timing={t()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.gradesInsights}>
          <GradesInsights />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={t()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.montage}>
          <Montage />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-bottom" })} timing={t()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.cta}>
          <CTA />
        </TransitionSeries.Sequence>
      </TransitionSeries>

      {/* Cinematic color grade on top of everything. */}
      <Grade />

      {/* Royalty-free music hook — off by default (see README "Music"). */}
      {MUSIC_ENABLED ? <Audio src={staticFile(MUSIC_SRC)} volume={0.5} /> : null}
    </AbsoluteFill>
  );
};
