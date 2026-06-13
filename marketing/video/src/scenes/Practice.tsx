import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { PhoneLight } from "../components/PhoneLight";
import { Shot } from "../components/Shot";
import { Finger } from "../components/Finger";
import { KineticLabel } from "../components/KineticLabel";
import { SceneBG } from "../components/SceneBG";
import { LightLeak } from "../components/LightLeak";
import { COLORS, SCREENS, SHOT } from "../theme";

/**
 * Scene — Practice.
 * Finger taps the correct answer; a burst fires and the explanation reveals.
 */
export const Practice: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const screenW = 384;
  const screenH = (screenW * SHOT.h) / SHOT.w;
  const zoom = 1.08;
  const panRange = screenH * (zoom - 1);

  const enter = spring({ frame, fps, config: { damping: 18, mass: 1 } });
  const phoneX = interpolate(enter, [0, 1], [120, 0]);
  const phoneRot = interpolate(enter, [0, 1], [5, -2]);
  const float = Math.sin(frame / 42) * 7;

  const TAP = 120;
  // Haptic shake right after the tap.
  const shake =
    frame > TAP && frame < TAP + 16
      ? Math.sin((frame - TAP) * 1.6) * interpolate(frame, [TAP, TAP + 16], [5, 0])
      : 0;

  // Reveal the explanation after the answer is chosen.
  const scroll = interpolate(frame, [TAP + 14, 300], [0, -panRange], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Green burst rings at the answer.
  const burst = interpolate(frame, [TAP, TAP + 36], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const answerY = screenH * 0.53;
  const answerX = screenW * 0.5;

  return (
    <AbsoluteFill>
      <SceneBG tint={COLORS.emerald} variant="warm" />
      <LightLeak life={44} hue={COLORS.gold} from="left" />

      <AbsoluteFill
        style={{
          flexDirection: "row",
          alignItems: "center",
          justifyContent: "center",
          gap: 110,
          padding: "0 120px",
        }}
      >
        <KineticLabel
          kicker="Practice"
          title="Learn by doing"
          sub="Adaptive questions with instant feedback, streaks and explanations."
          delay={18}
          align="left"
        />

        <div
          style={{
            position: "relative",
            transform: `translateX(${phoneX + shake}px) translateY(${float}px) rotate(${phoneRot}deg)`,
            filter: "drop-shadow(0 40px 90px rgba(0,0,0,0.5))",
          }}
        >
          <PhoneLight screenWidth={screenW}>
            <Shot src={SCREENS.practice} scroll={scroll} zoom={zoom} />
            {/* Burst rings on the correct answer */}
            {[0, 0.18, 0.36].map((d, i) => {
              const b = Math.max(0, Math.min(1, burst - d));
              return (
                <div
                  key={i}
                  style={{
                    position: "absolute",
                    left: answerX,
                    top: answerY,
                    width: 60,
                    height: 60,
                    marginLeft: -30,
                    marginTop: -30,
                    borderRadius: "50%",
                    border: `3px solid ${COLORS.green}`,
                    transform: `scale(${0.4 + b * 2.4})`,
                    opacity: (1 - b) * 0.65,
                    zIndex: 4,
                    pointerEvents: "none",
                  }}
                />
              );
            })}
          </PhoneLight>

          <Finger
            fromX={answerX + 90}
            fromY={answerY + 150}
            toX={answerX}
            toY={answerY}
            start={70}
            tapAt={TAP}
          />
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
