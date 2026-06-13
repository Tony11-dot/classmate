import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { PhoneLight } from "../components/PhoneLight";
import { Shot } from "../components/Shot";
import { Finger } from "../components/Finger";
import { KineticLabel } from "../components/KineticLabel";
import { SceneBG } from "../components/SceneBG";
import { LightLeak } from "../components/LightLeak";
import { Flare } from "../components/Flare";
import { CameraRig } from "../components/CameraRig";
import { COLORS, SHOT } from "../theme";

export type InteractionProps = {
  beforeSrc: string;
  afterSrc: string;
  kicker: string;
  title: string;
  sub?: string;
  side?: "left" | "right";
  /** Tap target as a fraction of the screen (0..1). */
  tapXFrac?: number;
  tapYFrac?: number;
  /** Frame the tap lands; the screen crossfades to `after` here. */
  tapFrame?: number;
  screenWidth?: number;
  /** Optional pan (px) applied to the after-screen to reveal long content. */
  afterScroll?: number;
  tint?: string;
  leakHue?: string;
  variant?: "indigo" | "warm" | "night";
};

/**
 * A real "someone using it" beat: phone shows the BEFORE screen, a finger taps,
 * and the screen crossfades to the AFTER screen — all under a cinematic camera.
 */
export const Interaction: React.FC<InteractionProps> = ({
  beforeSrc,
  afterSrc,
  kicker,
  title,
  sub,
  side = "right",
  tapXFrac = 0.5,
  tapYFrac = 0.6,
  tapFrame = 80,
  screenWidth = 290,
  afterScroll = 0,
  tint = COLORS.indigoSoft,
  leakHue = COLORS.gold,
  variant = "indigo",
}) => {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();
  const screenH = (screenWidth * SHOT.h) / SHOT.w;
  const tapX = screenWidth * tapXFrac;
  const tapY = screenH * tapYFrac;

  const afterOpacity = interpolate(frame, [tapFrame, tapFrame + 12], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  // Pan the after-screen open a touch once it has settled (reveals long content).
  const settleScroll = interpolate(
    frame,
    [tapFrame + 18, durationInFrames - 6],
    [0, afterScroll],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  );

  const phone = (
    <CameraRig push={[1.0, 1.07]} tilt={side === "right" ? 4 : -4} whip={1} durationInFrames={durationInFrames}>
      <div style={{ position: "relative", filter: "drop-shadow(0 50px 100px rgba(0,0,0,0.55))" }}>
        <PhoneLight screenWidth={screenWidth}>
          <Shot src={beforeSrc} />
          <AbsoluteFill style={{ opacity: afterOpacity }}>
            <Shot src={afterSrc} scroll={settleScroll} />
          </AbsoluteFill>
          <Finger
            fromX={tapX + 70}
            fromY={tapY + 130}
            toX={tapX}
            toY={tapY}
            start={tapFrame - 46}
            tapAt={tapFrame}
          />
        </PhoneLight>
      </div>
    </CameraRig>
  );

  const label = (
    <KineticLabel kicker={kicker} title={title} sub={sub} delay={14} align={side === "right" ? "left" : "right"} />
  );

  return (
    <AbsoluteFill>
      <SceneBG tint={tint} variant={variant} />
      <LightLeak life={46} hue={leakHue} from={side === "right" ? "left" : "right"} />
      <AbsoluteFill
        style={{
          flexDirection: "row",
          alignItems: "center",
          justifyContent: "center",
          gap: 110,
          padding: "0 130px",
        }}
      >
        {side === "right" ? (
          <>
            {label}
            {phone}
          </>
        ) : (
          <>
            {phone}
            {label}
          </>
        )}
      </AbsoluteFill>
      <Flare at={tapFrame} x={50} y={50} hue={leakHue} />
    </AbsoluteFill>
  );
};
