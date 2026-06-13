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
import { COLORS, FONTS, SCREENS, SHOT } from "../theme";

/**
 * Scene — Classrooms.
 * A class chat scrolls like a live conversation (swipe gesture), and a fresh
 * message bubble pops in at the end.
 */
export const Classroom: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const screenW = 380;
  const screenH = (screenW * SHOT.h) / SHOT.w;
  const zoom = 1.1;
  const panRange = screenH * (zoom - 1);

  const enter = spring({ frame, fps, config: { damping: 18, mass: 1 } });
  const phoneX = interpolate(enter, [0, 1], [-120, 0]);
  const phoneRot = interpolate(enter, [0, 1], [-6, 2.5]);
  const float = Math.sin(frame / 38 + 1) * 8;

  const scroll = interpolate(frame, [44, 250], [0, -panRange], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Fresh outgoing bubble pops in near the end.
  const bubble = spring({
    frame: frame - 270,
    fps,
    config: { damping: 13, stiffness: 150 },
  });

  return (
    <AbsoluteFill>
      <SceneBG tint={COLORS.sky} variant="indigo" />
      <LightLeak life={46} hue={COLORS.emerald} from="right" />

      <AbsoluteFill
        style={{
          flexDirection: "row",
          alignItems: "center",
          justifyContent: "center",
          gap: 110,
          padding: "0 120px",
        }}
      >
        <div
          style={{
            position: "relative",
            transform: `translateX(${phoneX}px) translateY(${float}px) rotate(${phoneRot}deg)`,
            filter: "drop-shadow(0 40px 90px rgba(0,0,0,0.5))",
          }}
        >
          <PhoneLight screenWidth={screenW}>
            <Shot src={SCREENS.classroom} scroll={scroll} zoom={zoom} />
            {/* Fresh outgoing message */}
            <div
              style={{
                position: "absolute",
                right: 16,
                bottom: 92,
                maxWidth: screenW * 0.62,
                padding: "12px 16px",
                borderRadius: 18,
                borderBottomRightRadius: 6,
                background: `linear-gradient(135deg, ${COLORS.sky}, ${COLORS.indigo})`,
                color: "#fff",
                fontFamily: FONTS.body,
                fontWeight: 600,
                fontSize: 19,
                boxShadow: "0 10px 24px rgba(8,12,30,0.35)",
                transform: `translateY(${interpolate(bubble, [0, 1], [40, 0])}px) scale(${interpolate(bubble, [0, 1], [0.8, 1])})`,
                opacity: bubble,
                zIndex: 4,
              }}
            >
              On my way! 🎒
            </div>
          </PhoneLight>

          {/* Swipe-up gesture motivating the scroll */}
          <Finger
            fromX={screenW * 0.5 + 22}
            fromY={screenH * 0.72 + 22}
            toX={screenW * 0.5 + 22}
            toY={screenH * 0.4 + 22}
            start={60}
            tapAt={140}
          />
        </div>

        <KineticLabel
          kicker="Classrooms"
          title="Your class, in real time"
          sub="Announcements, assignments, materials and chat — organized per class."
          delay={18}
          align="right"
        />
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
