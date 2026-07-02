import React from "react";
import { AbsoluteFill, Audio, interpolate, Sequence, staticFile } from "remotion";
import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";

import { loadFonts } from "./fonts";
import { COLORS, MUSIC_ENABLED, MUSIC_SRC, SCENES, SCREENS, TOTAL_FRAMES, TRANSITION } from "./theme";

import { DisconnectedApps } from "./scenes/DisconnectedApps";
import { ExplodeHero } from "./scenes/ExplodeHero";
import { FeatureScene, CardCfg } from "./scenes/FeatureScene";
import { RolesFan } from "./scenes/RolesFan";
import { CTALight } from "./scenes/CTALight";

loadFonts();

const cut = () => linearTiming({ durationInFrames: TRANSITION });

// Two small support cards hugging the phone (never cross the text zone).
const support = (side: "left" | "right", a: string, b: string, t1: string, t2: string): CardCfg[] => {
  const s = side === "right" ? 1 : -1;
  return [
    { src: a, x: s * 285, y: -185, z: 25, w: 170, crop: 0.4, scroll: -80, rot: s * 6, delay: 26, tint: t1 },
    { src: b, x: s * 245, y: 205, z: -45, w: 165, crop: 0.38, scroll: -40, rot: -s * 5, delay: 34, tint: t2 },
  ];
};

/** ClassMate demo v4 @60fps — punchy ref1 cut with ElevenLabs narration. */
export const ClassMateDemo: React.FC = () => {
  const durs = Object.values(SCENES);
  const starts: number[] = [];
  durs.reduce((acc, d, i) => { starts[i] = acc; return acc + d - TRANSITION; }, 0);
  const [S_DISC, , S_NOVA, S_PRACTICE, S_GRADES, S_SCHEDULE, S_EXAM, S_SOLUTIONS, S_TEACHER, , S_CTA] = starts;
  const IMPACT = S_DISC + Math.round(SCENES.disconnected * 0.52) + 66;

  const vo: Array<[string, number]> = [
    ["vo/01-disconnected.mp3", S_DISC + 20],
    ["vo/02-one.mp3", IMPACT + 24],
    ["vo/03-nova.mp3", S_NOVA + 14],
    ["vo/04-practice.mp3", S_PRACTICE + 12],
    ["vo/05-grades.mp3", S_GRADES + 12],
    ["vo/06-schedule.mp3", S_SCHEDULE + 12],
    ["vo/07-exam.mp3", S_EXAM + 12],
    ["vo/08-solutions.mp3", S_SOLUTIONS + 12],
    ["vo/09-teacher.mp3", S_TEACHER + 12],
    ["vo/10-cta.mp3", S_CTA + 26],
  ];

  return (
    <AbsoluteFill style={{ backgroundColor: "#eef3fc" }}>
      <TransitionSeries>
        <TransitionSeries.Sequence durationInFrames={SCENES.disconnected}>
          <DisconnectedApps />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={cut()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.explode}>
          <ExplodeHero heroSrc={SCREENS.grades} title={"Your whole school,\nin one app."} />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-right" })} timing={cut()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.nova}>
          <FeatureScene
            kicker="AI Tutor" title={"Ask NOVA \n anything."}
            screens={[SCREENS.nova1, SCREENS.nova2]} mode="scroll"
            typeText="Explain integrals step by step"
            accent={COLORS.sky} side="right"
            cards={support("right", SCREENS.practice, SCREENS.exam, COLORS.sky, COLORS.emerald)}
          />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-left" })} timing={cut()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.practice}>
          <FeatureScene kicker="Practice" title={"Learn by \n doing."}
            screens={[SCREENS.practice]} accent={COLORS.goldDeep} side="left"
            hues={[COLORS.gold, COLORS.emerald, COLORS.sky, COLORS.indigoSoft]}
            cards={support("left", SCREENS.grades, SCREENS.solutions, COLORS.gold, COLORS.emerald)} />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-right" })} timing={cut()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.grades}>
          <FeatureScene kicker="Grades" title={"Live results, \n by semester."}
            screens={[SCREENS.grades]} accent={COLORS.emerald} side="right"
            cards={support("right", SCREENS.schedule, SCREENS.practice, COLORS.emerald, COLORS.sky)} />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-left" })} timing={cut()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.schedule}>
          <FeatureScene kicker="Schedule" title={"The week, \n at a glance."}
            screens={[SCREENS.schedule]} accent={COLORS.sky} side="left"
            cards={support("left", SCREENS.exam, SCREENS.grades, COLORS.sky, COLORS.gold)} />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-right" })} timing={cut()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.exam}>
          <FeatureScene kicker="Exam Prep" title={"Every exam, \n a study plan."}
            screens={[SCREENS.exam]} accent={COLORS.indigoSoft} side="right"
            hues={[COLORS.indigoSoft, COLORS.sky, COLORS.gold, COLORS.emerald]}
            cards={support("right", SCREENS.nova1, SCREENS.schedule, COLORS.indigoSoft, COLORS.sky)} />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-left" })} timing={cut()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.solutions}>
          <FeatureScene kicker="Solutions" title={"A library \n of answers."}
            screens={[SCREENS.solutions]} accent={COLORS.goldDeep} side="left"
            cards={support("left", SCREENS.classroom, SCREENS.grades, COLORS.gold, COLORS.indigoSoft)} />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={slide({ direction: "from-right" })} timing={cut()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.teacher}>
          <FeatureScene kicker="Teachers & Admins" title={"Built for \n every role."}
            screens={[SCREENS.attendance, SCREENS.admin]} mode="switch"
            accent={COLORS.emerald} side="right"
            cards={support("right", SCREENS.classroom, SCREENS.classroom2, COLORS.emerald, COLORS.sky)} />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={cut()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.roles}>
          <RolesFan />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={cut()} />

        <TransitionSeries.Sequence durationInFrames={SCENES.cta}>
          <CTALight />
        </TransitionSeries.Sequence>
      </TransitionSeries>

      {/* ── Narration ── */}
      {vo.map(([src, from], i) => (
        <Sequence key={`vo${i}`} from={from} name={`vo-${src}`}>
          <Audio src={staticFile(src)} volume={1} />
        </Sequence>
      ))}

      {/* Whoosh on each cut. */}
      {starts.slice(1).map((f, i) => (
        <Sequence key={`w${i}`} from={Math.max(0, f - 6)} durationInFrames={30} name={`whoosh-${i}`}>
          <Audio src={staticFile("sfx/whoosh.wav")} volume={0.3} />
        </Sequence>
      ))}

      {/* Music bed (drop a track at public/music/bed.mp3 + enable in theme). */}
      {MUSIC_ENABLED ? (
        <Audio
          src={staticFile(MUSIC_SRC)}
          volume={(f) =>
            interpolate(f, [0, 30, TOTAL_FRAMES - 60, TOTAL_FRAMES - 1], [0, 0.16, 0.16, 0], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            })
          }
        />
      ) : null}
    </AbsoluteFill>
  );
};
