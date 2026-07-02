import React from "react";
import { AbsoluteFill, Img, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS, SHOT } from "../theme";
import { GlassBG, LiquidPanel } from "../components/Glass";
import { HeroPhone } from "../components/HeroPhone";
import { FloatCard } from "../components/FloatCard";
import { TypeOn } from "../components/TypeOn";
import { flickScroll, motionBlur, pop, velocity } from "../anim";

export type CardCfg = {
  x: number; y: number; z?: number; w?: number; crop?: number;
  scroll?: number; src?: string; rot?: number; delay?: number; tint?: string;
  children?: React.ReactNode;
};

/**
 * v4 feature scene — fast, physical, decluttered.
 * · Phone whips in from the side with real velocity blur and lands with a bounce.
 * · Scroll is human: discrete flicks with inertia + a scrollbar pill.
 * · "switch" mode swipes between screens like a real gesture.
 * · Copy = kicker + short title only (the VO carries detail). Strict safe zones.
 */
export const FeatureScene: React.FC<{
  kicker: string;
  title: string;
  screens: string[];
  mode?: "scroll" | "switch" | "single";
  typeText?: string;
  cards?: CardCfg[];
  accent?: string;
  hues?: string[];
  side?: "left" | "right"; // side the PHONE sits on
  screenWidth?: number;
}> = ({ kicker, title, screens, mode = "single", typeText, cards = [], accent = COLORS.sky, hues, side = "right", screenWidth = 310 }) => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames: dur } = useVideoConfig();

  const screenH = Math.round((screenWidth * SHOT.h) / SHOT.w);
  const dir = side === "right" ? 1 : -1;

  // ── phone whip-in (fast) ─────────────────────────────────────────
  const entry = spring({ frame, fps, config: { damping: 15, mass: 0.7, stiffness: 210 } });
  const entryXAt = (f: number) =>
    interpolate(spring({ frame: f, fps, config: { damping: 15, mass: 0.7, stiffness: 210 } }), [0, 1], [dir * 760, 0]);
  const entryX = entryXAt(frame);
  const entryBlur = motionBlur(velocity(entryXAt, frame), 0.045);
  const entryRot = interpolate(entry, [0, 1], [dir * 16, 0]);

  // continuous life after landing
  const idleYaw = (side === "right" ? -10 : 10) + Math.sin(frame / 46) * 2.2;
  const idlePitch = 4.5 + Math.cos(frame / 52) * 1.4;
  const idleBob = Math.sin(frame / 40) * 6;

  // ── typing → scroll timeline ─────────────────────────────────────
  const typeDelay = 22;
  const typeDur = typeText ? 66 : 0;
  const scrollStart = 30 + typeDur;

  const flicks = [
    { at: scrollStart, to: -screenH * 0.5 },
    { at: scrollStart + 70, to: -screenH * 1.05 },
    { at: scrollStart + 145, to: -screenH * 1.55 },
  ].filter((f) => f.at < dur - 26);

  const scrollAt = (f: number) => flickScroll(f, fps, flicks);
  const scrollAmt = mode === "scroll" ? scrollAt(frame) : 0;
  const scrollVel = mode === "scroll" ? velocity(scrollAt, frame) : 0;
  const scrollBlur = motionBlur(scrollVel, 0.05, 5);

  // total scrollable = 2 stacked shots minus 1 screen
  const maxScroll = screenH * 1.174; // (2*SHOT ratio − screen) approx

  // ── screen content ───────────────────────────────────────────────
  let content: React.ReactNode;
  if (mode === "scroll" && screens.length >= 2) {
    content = (
      <AbsoluteFill style={{ overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, transform: `translateY(${scrollAmt}px)`, filter: scrollBlur > 0.5 ? `blur(${scrollBlur}px)` : undefined, willChange: "transform" }}>
          <Img src={staticFile(screens[0])} style={{ width: "100%", display: "block" }} />
          <Img src={staticFile(screens[1])} style={{ width: "100%", display: "block", marginTop: -2 }} />
        </div>
        {/* scrollbar pill — appears while scrolling, fades out */}
        <div
          style={{
            position: "absolute",
            right: 5,
            top: `${interpolate(-scrollAmt, [0, maxScroll], [4, 62], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })}%`,
            width: 5,
            height: "34%",
            borderRadius: 99,
            background: "rgba(10,16,40,0.35)",
            opacity: Math.min(1, Math.abs(scrollVel) * 0.12),
          }}
        />
      </AbsoluteFill>
    );
  } else if (mode === "switch" && screens.length >= 2) {
    // real swipe: old screen slides out left, new slides in from right
    const swAt = (f: number) =>
      interpolate(spring({ frame: f - Math.round(dur * 0.45), fps, config: { damping: 19, mass: 0.8, stiffness: 160 } }), [0, 1], [0, 1]);
    const sw = swAt(frame);
    const swBlur = motionBlur(velocity((f) => swAt(f) * screenWidth, frame), 0.06, 6);
    content = (
      <AbsoluteFill style={{ overflow: "hidden" }}>
        <Img src={staticFile(screens[0])} style={{ position: "absolute", inset: 0, width: "100%", transform: `translateX(${-sw * screenWidth}px)`, filter: swBlur > 0.5 ? `blur(${swBlur}px)` : undefined }} />
        <Img src={staticFile(screens[1])} style={{ position: "absolute", inset: 0, width: "100%", transform: `translateX(${(1 - sw) * screenWidth}px)`, filter: swBlur > 0.5 ? `blur(${swBlur}px)` : undefined }} />
      </AbsoluteFill>
    );
  } else {
    const kb = interpolate(frame, [0, dur], [1.0, 1.055]);
    const ky = interpolate(frame, [0, dur], [0, -screenH * 0.035]);
    content = (
      <AbsoluteFill style={{ overflow: "hidden" }}>
        <Img src={staticFile(screens[0])} style={{ width: "100%", display: "block", transform: `translateY(${ky}px) scale(${kb})`, transformOrigin: "top center" }} />
      </AbsoluteFill>
    );
  }

  const typingOpacity = typeText
    ? interpolate(frame, [scrollStart - 12, scrollStart], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })
    : 0;

  const screenContent = (
    <>
      {content}
      {typeText && typingOpacity > 0 ? (
        <div
          style={{
            position: "absolute", left: "7%", right: "7%", bottom: "4.2%",
            height: screenH * 0.055, borderRadius: 999, background: "#fff",
            boxShadow: "inset 0 0 0 1.5px rgba(34,48,200,0.25), 0 4px 14px rgba(20,30,80,0.15)",
            display: "flex", alignItems: "center", paddingLeft: 14, paddingRight: 6,
            opacity: typingOpacity, fontFamily: FONTS.body, fontSize: screenH * 0.026,
            color: COLORS.ink, fontWeight: 500, overflow: "hidden", whiteSpace: "nowrap",
          }}
        >
          <div style={{ flex: 1, overflow: "hidden" }}>
            <TypeOn text={typeText} start={typeDelay} cps={30} />
          </div>
          {/* send button pulses when typing completes */}
          <div
            style={{
              width: screenH * 0.04, height: screenH * 0.04, borderRadius: 99,
              background: `linear-gradient(140deg, ${COLORS.indigo}, ${COLORS.sky})`,
              transform: `scale(${1 + 0.18 * pop(frame, fps, typeDelay + typeDur - 6)})`,
              display: "flex", alignItems: "center", justifyContent: "center", color: "#fff",
              fontSize: screenH * 0.02, fontWeight: 800,
            }}
          >
            ↑
          </div>
        </div>
      ) : null}
    </>
  );

  // ── copy: kicker + word-pop title (no sub, VO carries it) ─────────
  const words = title.replace("\n", " \n ").split(" ");

  return (
    <AbsoluteFill>
      <AuroraLight hues={hues} />

      {/* phone cluster — strictly on its side */}
      <AbsoluteFill style={{ perspective: 1900 }}>
        <div style={{ position: "absolute", left: side === "right" ? "69%" : "31%", top: "50%", transformStyle: "preserve-3d", transform: `translateY(${idleBob}px)` }}>
          {cards.filter((c) => (c.z ?? 0) < 0).map((c, i) => (
            <FloatCard key={`b${i}`} {...c} seed={i + 1} />
          ))}
          <div
            style={{
              position: "absolute", left: "50%", top: "50%",
              transform: `translate(-50%,-50%) translateX(${entryX}px) rotateY(${idleYaw + entryRot}deg) rotateX(${idlePitch}deg)`,
              transformStyle: "preserve-3d",
              filter: entryBlur > 0.5 ? `blur(${entryBlur}px) drop-shadow(0 44px 60px rgba(20,30,80,0.3))` : "drop-shadow(0 44px 60px rgba(20,30,80,0.3))",
            }}
          >
            <HeroPhone src={screens[0]} screenWidth={screenWidth} rim={accent} reflection={false} screenContent={screenContent} />
          </div>
          {cards.filter((c) => (c.z ?? 0) >= 0).map((c, i) => (
            <FloatCard key={`f${i}`} {...c} seed={i + 4} />
          ))}
        </div>
      </AbsoluteFill>

      {/* copy — the opposite side, vertically centred, nothing else in its zone */}
      <AbsoluteFill style={{ display: "flex", flexDirection: "column", justifyContent: "center", alignItems: side === "right" ? "flex-start" : "flex-end", padding: "0 7.5%", textAlign: side === "right" ? "left" : "right" }}>
        <div style={{ maxWidth: 640 }}>
          <div style={{ fontFamily: FONTS.body, fontSize: 21, letterSpacing: 5, textTransform: "uppercase", color: accent, fontWeight: 800, marginBottom: 18, opacity: pop(frame, fps, 6), transform: `translateY(${interpolate(pop(frame, fps, 6), [0, 1], [14, 0])}px)` }}>
            {kicker}
          </div>
          <div style={{ fontFamily: FONTS.display, fontSize: 86, lineHeight: 1.0, fontWeight: 800, color: COLORS.ink, letterSpacing: -2, display: "flex", flexWrap: "wrap", justifyContent: side === "right" ? "flex-start" : "flex-end", columnGap: 18 }}>
            {words.map((w, i) =>
              w === "\n" ? (
                <span key={i} style={{ flexBasis: "100%", height: 0 }} />
              ) : (
                <span
                  key={i}
                  style={{
                    display: "inline-block",
                    opacity: pop(frame, fps, 10 + i * 3),
                    transform: `translateY(${interpolate(pop(frame, fps, 10 + i * 3), [0, 1], [26, 0])}px)`,
                  }}
                >
                  {w}
                </span>
              ),
            )}
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
