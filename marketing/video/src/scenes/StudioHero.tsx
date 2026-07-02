import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS, SHOT } from "../theme";
import { Studio } from "../components/Studio";
import { Podium } from "../components/Podium";
import { HeroPhone } from "../components/HeroPhone";

/**
 * Premium "product on a lit stage" hero scene (ref2 aesthetic). A rim-lit phone
 * turntables slowly on a glowing podium in a dark studio while the camera does
 * a gentle dolly + orbit. Kinetic kicker/title fly in on the side.
 */
export const StudioHero: React.FC<{
  src: string;
  kicker: string;
  title: string;
  sub?: string;
  rim?: string;
  hue2?: string;
  side?: "left" | "right";
  scroll?: number;
  screenWidth?: number;
}> = ({
  src,
  kicker,
  title,
  sub,
  rim = COLORS.sky,
  hue2 = COLORS.indigoSoft,
  side = "left",
  scroll = 0,
  screenWidth = 300,
}) => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames: dur } = useVideoConfig();

  const bezel = Math.round(screenWidth * 0.035);
  const outerH = Math.round((screenWidth * SHOT.h) / SHOT.w) + bezel * 2;

  // Camera: slow dolly-in + a gentle orbit that eases across the shot.
  const enter = spring({ frame, fps, config: { damping: 16, mass: 0.9, stiffness: 110 } });
  const dolly = interpolate(frame, [0, dur], [1.02, 1.12], { extrapolateRight: "clamp" });
  const camScale = dolly * interpolate(enter, [0, 1], [0.92, 1]);
  const orbit = interpolate(frame, [0, dur], [-9, 7]); // deg yaw across the shot
  const camPitch = 4 + Math.sin(frame / 90) * 1.2;
  const bob = Math.sin(frame / 70) * 8;

  // The phone itself turntables a touch more than the camera for parallax.
  const phoneYaw = interpolate(frame, [0, dur], [-6, 5]) + interpolate(enter, [0, 1], [10, 0]);

  const txtIn = spring({ frame: frame - 8, fps, config: { damping: 18, mass: 0.9, stiffness: 90 } });
  const txtX = interpolate(txtIn, [0, 1], [side === "left" ? -60 : 60, 0]);

  return (
    <AbsoluteFill>
      <Studio hue={hue2} hue2={rim} />

      {/* Stage */}
      <AbsoluteFill style={{ perspective: 1700 }}>
        <div
          style={{
            position: "absolute",
            inset: 0,
            transformStyle: "preserve-3d",
            transform: `scale(${camScale}) translateY(${bob}px) rotateX(${camPitch}deg) rotateY(${orbit}deg)`,
          }}
        >
          {/* Phone + podium group, offset toward the text-free side. */}
          <div
            style={{
              position: "absolute",
              left: side === "left" ? "62%" : "38%",
              top: "46%",
              transform: "translate(-50%,-50%)",
              transformStyle: "preserve-3d",
            }}
          >
            {/* Podium sits at the phone's base. */}
            <Podium width={screenWidth * 2.3} hue={rim} y={outerH * 0.5} />
            <div style={{ transform: `rotateY(${phoneYaw}deg)`, transformStyle: "preserve-3d" }}>
              <HeroPhone src={src} screenWidth={screenWidth} scroll={scroll} rim={rim} />
            </div>
          </div>
        </div>
      </AbsoluteFill>

      {/* Copy block */}
      <AbsoluteFill
        style={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          alignItems: side === "left" ? "flex-start" : "flex-end",
          padding: "0 9%",
          textAlign: side === "left" ? "left" : "right",
        }}
      >
        <div style={{ maxWidth: 560, transform: `translateX(${txtX}px)`, opacity: txtIn }}>
          <div
            style={{
              fontFamily: FONTS.body,
              fontSize: 22,
              letterSpacing: 4,
              textTransform: "uppercase",
              color: rim,
              fontWeight: 700,
              marginBottom: 18,
            }}
          >
            {kicker}
          </div>
          <div
            style={{
              fontFamily: FONTS.display,
              fontSize: 84,
              lineHeight: 0.98,
              fontWeight: 800,
              color: COLORS.white,
              letterSpacing: -1.5,
              whiteSpace: "pre-line",
              textShadow: `0 8px 40px ${rim}44`,
            }}
          >
            {title}
          </div>
          {sub ? (
            <div
              style={{
                fontFamily: FONTS.body,
                fontSize: 27,
                lineHeight: 1.4,
                color: COLORS.skyLight,
                marginTop: 26,
                opacity: 0.85,
              }}
            >
              {sub}
            </div>
          ) : null}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
