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
import { KineticLabel } from "../components/KineticLabel";
import { SceneBG } from "../components/SceneBG";
import { LightLeak } from "../components/LightLeak";
import { COLORS, SCREENS, SHOT } from "../theme";

/**
 * Scene — NOVA AI tutor.
 * The phone glides in and the math solution scrolls past as NOVA "thinks".
 */
export const Nova: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const screenW = 386;
  const screenH = (screenW * SHOT.h) / SHOT.w;
  const zoom = 1.12;
  const panRange = screenH * (zoom - 1); // px of vertical room

  const enter = spring({ frame, fps, config: { damping: 18, mass: 1 } });
  const phoneX = interpolate(enter, [0, 1], [120, 0]);
  const phoneRot = interpolate(enter, [0, 1], [6, -2.5]);
  const float = Math.sin(frame / 40) * 8;

  // Scroll the solution: settle, then pan down through the steps.
  const scroll = interpolate(frame, [40, 300], [0, -panRange], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill>
      <SceneBG tint={COLORS.indigoSoft} />
      <LightLeak life={46} hue={COLORS.gold} from="left" />

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
          kicker="AI tutor"
          title="Ask NOVA anything"
          sub="Step-by-step help with real math & code rendering — in your language."
          delay={18}
          align="left"
        />

        <div
          style={{
            transform: `translateX(${phoneX}px) translateY(${float}px) rotate(${phoneRot}deg)`,
            filter: "drop-shadow(0 40px 90px rgba(0,0,0,0.5))",
          }}
        >
          <PhoneLight screenWidth={screenW}>
            <Shot src={SCREENS.nova} scroll={scroll} zoom={zoom} />
          </PhoneLight>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
