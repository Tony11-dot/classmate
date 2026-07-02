import React from "react";
import { AbsoluteFill, Audio, interpolate, Sequence, staticFile } from "remotion";
import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";

import { loadFonts } from "./fonts";
import { SCENES, TOTAL_FRAMES, TRANSITION } from "./theme";
import { ABEATS, ActProblem } from "./scenes/ActProblem";
import { PBEATS, ActProduct } from "./scenes/ActProduct";

loadFonts();

/**
 * ClassMate demo v9 @60fps — two acts:
 *   Act 1: the problem — light, icon-led storytelling
 *   Act 2: the product — dark glowing glass AI world
 * Music drop lands on the Act-1 logo reveal (18.7s).
 */
export const ClassMateDemo: React.FC = () => {
  const S2 = SCENES.act1 - TRANSITION;
  const a = (k: keyof typeof ABEATS) => ABEATS[k];
  const p = (k: keyof typeof PBEATS) => S2 + PBEATS[k];

  const vo: Array<[string, number]> = [
    ["vo/o1.mp3", a("these") + 8],
    ["vo/o2.mp3", a("note") + 0],
    ["vo/o3.mp3", a("cards") - 17],
    ["vo/p1.mp3", a("slows") + 14],
    ["vo/p2.mp3", a("dark") + 30],
    ["vo/p3.mp3", a("logo") + 18],
    ["vo/03-nova.mp3", p("chat") + 20],
    ["vo/p4.mp3", p("options") + 24],
    ["vo/05-grades.mp3", p("panels") + 20],
    ["vo/09-teacher.mp3", p("panels") + 170],
    ["vo/p5.mp3", p("future") + 6],
    ["vo/10-cta.mp3", p("end") + 26],
  ];

  const beatStarts = [
    a("everywhere"), a("note"), a("thread"), a("cards"), a("slows"), a("dark"), a("phone"), a("pills"), a("logo"),
    p("chat"), p("options"), p("button"), p("panels"), p("orb"), p("future"), p("end"),
  ];
  const booms: Array<[number, number]> = [
    [a("note") + 30, 0.25],
    [a("dark"), 0.6], [a("dark") + 40, 0.25], [a("dark") + 80, 0.25],
    ...[8, 22, 36].map((d): [number, number] => [a("pills") + d, 0.22]),
    [a("logo") + 8, 0.6],
    ...[26, 40, 54].map((d): [number, number] => [p("options") + d, 0.2]),
    [p("button") + 8, 0.5],
    [p("panels") + 20, 0.3],
    [p("end") + 10, 0.5],
  ];
  const taps: number[] = [p("chat") + 64, p("chat") + 168, p("options") + 100, a("thread") + 10];

  return (
    <AbsoluteFill style={{ backgroundColor: "#04060d" }}>
      <TransitionSeries>
        <TransitionSeries.Sequence durationInFrames={SCENES.act1}>
          <ActProblem />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: TRANSITION })} />
        <TransitionSeries.Sequence durationInFrames={SCENES.act2}>
          <ActProduct />
        </TransitionSeries.Sequence>
      </TransitionSeries>

      {vo.map(([src, from], i) => (
        <Sequence key={`vo${i}`} from={from} name={`vo-${src}`}>
          <Audio src={staticFile(src)} volume={1} />
        </Sequence>
      ))}

      {beatStarts.map((f, i) => (
        <Sequence key={`w${i}`} from={Math.max(0, f - 2)} durationInFrames={30} name={`whoosh-${i}`}>
          <Audio src={staticFile("sfx/whoosh.wav")} volume={0.3} />
        </Sequence>
      ))}
      {booms.map(([f, v], i) => (
        <Sequence key={`b${i}`} from={f} durationInFrames={36} name={`boom-${i}`}>
          <Audio src={staticFile("sfx/boom.wav")} volume={v} />
        </Sequence>
      ))}
      {taps.map((f, i) => (
        <Sequence key={`t${i}`} from={f} durationInFrames={6} name={`tap-${i}`}>
          <Audio src={staticFile("sfx/tap.wav")} volume={0.5} />
        </Sequence>
      ))}
      {/* risers into the dark beat and the logo */}
      <Sequence from={a("dark") - 66} durationInFrames={76} name="riser-dark">
        <Audio src={staticFile("sfx/riser.wav")} volume={0.5} />
      </Sequence>
      <Sequence from={a("logo") - 66} durationInFrames={76} name="riser-logo">
        <Audio src={staticFile("sfx/riser.wav")} volume={0.6} />
      </Sequence>

      {/* composed track — drop at 18.7s = the Act-1 logo reveal */}
      <Audio
        src={staticFile("music/track.wav")}
        volume={(f) =>
          interpolate(f, [0, 24, TOTAL_FRAMES - 110, TOTAL_FRAMES - 1], [0, 0.36, 0.36, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          })
        }
      />
    </AbsoluteFill>
  );
};
