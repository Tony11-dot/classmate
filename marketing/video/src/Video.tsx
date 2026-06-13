import React from "react";
import { AbsoluteFill, Audio, interpolate, Sequence, staticFile } from "remotion";
import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { wipe } from "@remotion/transitions/wipe";

import { loadFonts } from "./fonts";
import { Grade } from "./components/Grade";
import { TitleCard } from "./components/TitleCard";
import {
  COLORS,
  MUSIC_ENABLED,
  MUSIC_SRC,
  SCENES,
  SCREENS,
  TOTAL_FRAMES,
  TRANSITION,
} from "./theme";

import { ColdOpen } from "./scenes/ColdOpen";
import { Interaction } from "./scenes/Interaction";
import { GradesInsights } from "./scenes/GradesInsights";
import { Montage } from "./scenes/Montage";
import { CTA } from "./scenes/CTA";

loadFonts();

const t = () => linearTiming({ durationInFrames: TRANSITION });

// Scene start frames (accounting for the transition overlap), used to time SFX.
const _durs = [
  SCENES.coldOpen, SCENES.title, SCENES.attendance, SCENES.nova,
  SCENES.classroom, SCENES.practice, SCENES.gradesInsights, SCENES.montage, SCENES.cta,
];
const _starts: number[] = [];
_durs.reduce((acc, d, i) => { _starts[i] = acc; return acc + d - TRANSITION; }, 0);
const CTA_FRAME = _starts[8];
const _MONTAGE = _starts[7];
// Whooshes ride every cut, plus the two internal montage cuts (CUT = 66).
const CUT_FRAMES = [
  _starts[1], _starts[2], _starts[3], _starts[4], _starts[5], _starts[6],
  _starts[7], _MONTAGE + 66, _MONTAGE + 132, _starts[8],
];
// Tap impacts land on each interaction's tapFrame.
const TAP_FRAMES = [_starts[2] + 60, _starts[3] + 62, _starts[4] + 58, _starts[5] + 68];

/**
 * ClassMate product demo v3 — cinematic "trailer" cut. Real app UI animated
 * with finger taps (before → after), 3D camera, lens flares, beat-synced
 * pacing. ~71s.
 */
export const ClassMateDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: "#05080f" }}>
      <TransitionSeries>
        <TransitionSeries.Sequence durationInFrames={SCENES.coldOpen}>
          <ColdOpen />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={t()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.title}>
          <TitleCard line="Your whole school." gradient />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={wipe({ direction: "from-bottom" })} timing={t()} />

        {/* Attendance — mark the room, 75% → 100% */}
        <TransitionSeries.Sequence durationInFrames={SCENES.attendance}>
          <Interaction
            beforeSrc={SCREENS.attendanceBefore}
            afterSrc={SCREENS.attendanceAfter}
            kicker="Attendance"
            title="Mark the room in seconds"
            sub="Tap down the roster — present, absent, late. Saved instantly."
            side="right"
            tapXFrac={0.5}
            tapYFrac={0.85}
            tapFrame={60}
            tint={COLORS.indigoSoft}
            leakHue={COLORS.gold}
            variant="indigo"
          />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-right" })} timing={t()} />

        {/* NOVA — ask → answer */}
        <TransitionSeries.Sequence durationInFrames={SCENES.nova}>
          <Interaction
            beforeSrc={SCREENS.novaBefore}
            afterSrc={SCREENS.novaAfter}
            kicker="AI tutor"
            title="Ask NOVA anything"
            sub="Type a question — get a step-by-step answer, with real math."
            side="left"
            tapXFrac={0.9}
            tapYFrac={0.57}
            tapFrame={62}
            afterScroll={-90}
            tint={COLORS.sky}
            leakHue={COLORS.emerald}
            variant="night"
          />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-left" })} timing={t()} />

        {/* Classrooms — tab switch */}
        <TransitionSeries.Sequence durationInFrames={SCENES.classroom}>
          <Interaction
            beforeSrc={SCREENS.classroomBefore}
            afterSrc={SCREENS.classroomAssignments}
            kicker="Classrooms"
            title="Your class, organized"
            sub="Chat, assignments, materials and meetings — one tap apart."
            side="right"
            tapXFrac={0.36}
            tapYFrac={0.2}
            tapFrame={58}
            tint={COLORS.emerald}
            leakHue={COLORS.gold}
            variant="indigo"
          />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={t()} />

        {/* Practice — tap the answer (the money shot) */}
        <TransitionSeries.Sequence durationInFrames={SCENES.practice}>
          <Interaction
            beforeSrc={SCREENS.practiceBefore}
            afterSrc={SCREENS.practiceAfter}
            kicker="Practice"
            title="Learn by doing"
            sub="Tap an answer — instant feedback, streaks and a worked explanation."
            side="left"
            tapXFrac={0.5}
            tapYFrac={0.8}
            tapFrame={68}
            tint={COLORS.gold}
            leakHue={COLORS.emerald}
            variant="warm"
          />
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

      {/* ── Sound design ─────────────────────────────────────────────────
          Procedurally-synthesized SFX (see public/sfx). Whooshes ride the
          scene cuts, taps/booms hit the UI interactions, a riser builds the
          CTA. These play regardless of MUSIC_ENABLED. */}
      {CUT_FRAMES.map((f, i) => (
        <Sequence key={`w${i}`} from={Math.max(0, f - 4)} durationInFrames={16} name={`whoosh-${i}`}>
          <Audio src={staticFile("sfx/whoosh.wav")} volume={0.5} />
        </Sequence>
      ))}
      {TAP_FRAMES.map((f, i) => (
        <React.Fragment key={`tap${i}`}>
          <Sequence from={f} durationInFrames={4} name={`tap-${i}`}>
            <Audio src={staticFile("sfx/tap.wav")} volume={0.7} />
          </Sequence>
          <Sequence from={f} durationInFrames={18} name={`thud-${i}`}>
            <Audio src={staticFile("sfx/boom.wav")} volume={0.38} />
          </Sequence>
        </React.Fragment>
      ))}
      {/* Riser + boom landing the CTA */}
      <Sequence from={CTA_FRAME - 36} durationInFrames={40} name="riser">
        <Audio src={staticFile("sfx/riser.wav")} volume={0.5} />
      </Sequence>
      <Sequence from={CTA_FRAME} durationInFrames={22} name="cta-impact">
        <Audio src={staticFile("sfx/boom.wav")} volume={0.85} />
      </Sequence>

      {/* Royalty-free music hook — fades in at the open, out under the CTA. */}
      {MUSIC_ENABLED ? (
        <Audio
          src={staticFile(MUSIC_SRC)}
          volume={(f) =>
            interpolate(
              f,
              [0, 14, TOTAL_FRAMES - 30, TOTAL_FRAMES - 1],
              [0, 0.62, 0.62, 0],
              { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
            )
          }
        />
      ) : null}
    </AbsoluteFill>
  );
};
