import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS, SCREENS } from "../theme";
import { AuroraLight } from "../components/AuroraLight";
import { FloatCard } from "../components/FloatCard";
import { HeroPhone } from "../components/HeroPhone";

/**
 * The signature ref1 shot: a hero phone at centre with app-screen cards
 * exploding outward into 3D space, drifting on a bright airy stage. Dramatic,
 * energetic, "one app for the whole school".
 */
export const ExplodeHero: React.FC<{
  heroSrc?: string;
  title?: string;
  sub?: string;
  bg?: boolean;
}> = ({ heroSrc = SCREENS.grades, title = "Your whole school,\nin one app.", sub, bg = true }) => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames: dur } = useVideoConfig();

  const enter = spring({ frame, fps, config: { damping: 13, mass: 0.7, stiffness: 190 } });
  // Push-in + drift — faster at 60fps.
  const camScale = interpolate(frame, [0, dur], [0.97, 1.09], { extrapolateRight: "clamp" }) *
    interpolate(enter, [0, 1], [0.82, 1]);
  const camYaw = interpolate(frame, [0, dur], [6, -6]);
  const bob = Math.sin(frame / 42) * 9;
  const phoneYaw = -12 + Math.sin(frame / 52) * 3 + interpolate(enter, [0, 1], [-18, 0]);
  const phonePitch = 6 + Math.cos(frame / 60) * 1.6;

  const titleIn = spring({ frame: frame - 4, fps, config: { damping: 14, stiffness: 180 } });

  // Cards blasting out around the phone — tight stagger, kept clear of the title zone.
  const cards = [
    { src: SCREENS.practice, x: -540, y: -130, z: 40, w: 240, crop: 0.5, scroll: -120, rot: -7, delay: 8, tint: COLORS.gold },
    { src: SCREENS.schedule, x: 540, y: -150, z: 10, w: 250, crop: 0.46, scroll: -60, rot: 8, delay: 10, tint: COLORS.sky },
    { src: SCREENS.solutions, x: -620, y: 230, z: -30, w: 230, crop: 0.44, scroll: -40, rot: 6, delay: 12, tint: COLORS.emerald },
    { src: SCREENS.exam, x: 610, y: 240, z: 30, w: 240, crop: 0.48, scroll: -80, rot: -6, delay: 14, tint: COLORS.indigoSoft },
    { src: SCREENS.attendance, x: -350, y: 380, z: -60, w: 200, crop: 0.36, scroll: -160, rot: -4, delay: 16, tint: COLORS.sky },
    { src: SCREENS.admin, x: 350, y: 385, z: -70, w: 200, crop: 0.36, scroll: -100, rot: 5, delay: 18, tint: COLORS.gold },
  ];

  return (
    <AbsoluteFill>
      {bg ? <AuroraLight /> : null}

      <AbsoluteFill style={{ perspective: 1800 }}>
        <div
          style={{
            position: "absolute",
            inset: 0,
            transformStyle: "preserve-3d",
            transform: `scale(${camScale}) translateY(${bob}px) rotateY(${camYaw}deg)`,
          }}
        >
          {/* Cluster centre */}
          <div style={{ position: "absolute", left: "50%", top: "56%", transformStyle: "preserve-3d" }}>
            {/* Back cards first (painter's order via translateZ). */}
            {cards.filter((c) => (c.z ?? 0) < 0).map((c, i) => (
              <FloatCard key={`b${i}`} {...c} seed={i + 1} />
            ))}

            {/* Hero phone */}
            <div
              style={{
                position: "absolute",
                left: "50%",
                top: "50%",
                transform: `translate(-50%,-50%) rotateY(${phoneYaw}deg) rotateX(${phonePitch}deg)`,
                transformStyle: "preserve-3d",
                filter: "drop-shadow(0 50px 70px rgba(20,30,80,0.35))",
              }}
            >
              <HeroPhone src={heroSrc} screenWidth={300} rim={COLORS.sky} reflection={false} />
            </div>

            {/* Front cards last. */}
            {cards.filter((c) => (c.z ?? 0) >= 0).map((c, i) => (
              <FloatCard key={`f${i}`} {...c} seed={i + 4} />
            ))}
          </div>
        </div>
      </AbsoluteFill>

      {/* Kinetic headline — pinned top-centre, clear of the card field */}
      <AbsoluteFill>
        <div
          style={{
            position: "absolute",
            top: "5.5%",
            left: 0,
            right: 0,
            transform: `translateY(${interpolate(titleIn, [0, 1], [40, 0])}px)`,
            opacity: titleIn,
            textAlign: "center",
          }}
        >
          <div
            style={{
              fontFamily: FONTS.display,
              fontSize: 76,
              lineHeight: 0.98,
              fontWeight: 800,
              letterSpacing: -1.6,
              whiteSpace: "pre-line",
              background: "linear-gradient(120deg, #9DBBFF, #F2F5FF)",
              WebkitBackgroundClip: "text",
              backgroundClip: "text",
              color: "transparent",
              textShadow: "0 2px 30px rgba(91,141,239,0.25)",
            }}
          >
            {title}
          </div>
          {sub ? (
            <div style={{ fontFamily: FONTS.body, fontSize: 26, color: COLORS.ink, opacity: 0.62, marginTop: 18 }}>{sub}</div>
          ) : null}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
