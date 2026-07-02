import React from "react";
import { AbsoluteFill, Img, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS, SCREENS, SHOT } from "../theme";
import { GlassBG, LiquidPanel } from "../components/Glass";
import { HeroPhone } from "../components/HeroPhone";
import { flickScroll, motionBlur, pop, velocity } from "../anim";

/**
 * NOVA flagship shot (Apple liquid-glass language):
 *  1. Spotlight close-up — a huge crisp "Message NOVA" pill; the prompt types
 *     itself while the CAMERA TRACKS THE CARET; send button pulses.
 *  2. The pill morphs down into the phone, which whips in behind it.
 *  3. The real answer scrolls with fast flicks (nova1 → nova2) + scrollbar.
 */
export const NovaSpotlight: React.FC<{ bg?: boolean }> = ({ bg = true }) => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames: dur } = useVideoConfig();

  const TEXT = "Explain integrals step by step";
  const TYPE_START = 22;
  const CPS = 26;
  const typeFrames = Math.ceil((TEXT.length / CPS) * fps); // ~69
  const TYPE_END = TYPE_START + typeFrames;
  const MORPH = TYPE_END + 24; // send pulse, then morph
  const F = 62; // close-up font size

  // typed chars (stepped) + continuous progress (for smooth camera)
  const typed = Math.max(0, Math.min(TEXT.length, Math.floor(((frame - TYPE_START) / fps) * CPS)));
  const prog = interpolate(frame, [TYPE_START, TYPE_END], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const caretXAt = (f: number) =>
    interpolate(f, [TYPE_START, TYPE_END], [0, TEXT.length * F * 0.5], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const caretX = caretXAt(frame);
  // camera pans once the caret passes centre-ish; slight lead
  const camXAt = (f: number) => -Math.max(0, caretXAt(f) - 430) * 0.92;
  const camX = camXAt(frame);
  const camBlur = motionBlur(velocity(camXAt, frame), 0.09, 3.5);
  const camZoom = interpolate(prog, [0, 1], [1.06, 1.0]);

  const sendPulse = pop(frame, fps, TYPE_END + 4);
  const morph = spring({ frame: frame - MORPH, fps, config: { damping: 16, mass: 0.85, stiffness: 150 } });

  // phone geometry
  const screenW = 310;
  const screenH = Math.round((screenW * SHOT.h) / SHOT.w);

  // phone whips in during morph
  const phoneX = interpolate(morph, [0, 1], [720, 0]);
  const phoneBlur = motionBlur(velocity((f) => interpolate(spring({ frame: f - MORPH, fps, config: { damping: 16, mass: 0.85, stiffness: 150 } }), [0, 1], [720, 0]), frame), 0.05);

  // pill morph: from big centre pill → the phone's input slot
  const pillW = interpolate(morph, [0, 1], [1240, screenW * 0.86]);
  const pillH = interpolate(morph, [0, 1], [128, screenH * 0.055]);
  const pillX = interpolate(morph, [0, 1], [camX, 458]); // ends over phone input
  const pillY = interpolate(morph, [0, 1], [0, screenH * 0.435]);
  const pillFont = interpolate(morph, [0, 1], [F, screenH * 0.026]);
  const pillOpacity = interpolate(morph, [0.82, 1], [1, 0], { extrapolateLeft: "clamp" });

  // answer scroll — fast flicks after the phone lands
  const flicks = [
    { at: MORPH + 46, to: -screenH * 0.55 },
    { at: MORPH + 120, to: -screenH * 1.08 },
    { at: MORPH + 194, to: -screenH * 1.55 },
  ];
  const scrollAt = (f: number) => flickScroll(f, fps, flicks);
  const scroll = scrollAt(frame);
  const scrollVel = velocity(scrollAt, frame);
  const scrollBlur = motionBlur(scrollVel, 0.05, 5);
  const maxScroll = screenH * 1.174;

  // caption
  const titleIn = pop(frame, fps, MORPH + 14);
  const kickIn = pop(frame, fps, MORPH + 6);

  const blink = Math.floor((frame / fps) * 2.4) % 2 === 0;

  return (
    <AbsoluteFill>
      {bg ? <GlassBG accent={COLORS.sky} accent2="#8B5CF6" /> : null}

      {/* ── Stage 2/3: phone with scrolling answer ── */}
      <div
        style={{
          position: "absolute",
          left: "66%",
          top: "50%",
          transform: `translate(-50%,-50%) translateX(${phoneX}px) rotateY(${-9 + Math.sin(frame / 40) * 2}deg) rotateX(${4 + Math.cos(frame / 46) * 1.2}deg) translateY(${Math.sin(frame / 36) * 6}px)`,
          filter: phoneBlur > 0.5 ? `blur(${phoneBlur}px) drop-shadow(0 44px 66px rgba(0,0,10,0.6))` : "drop-shadow(0 44px 66px rgba(0,0,10,0.6))",
          opacity: morph > 0.02 ? 1 : 0,
        }}
      >
        <HeroPhone
          src={SCREENS.nova1}
          screenWidth={screenW}
          rim={COLORS.sky}
          reflection={false}
          screenContent={
            <AbsoluteFill style={{ overflow: "hidden" }}>
              <div style={{ position: "absolute", inset: 0, transform: `translateY(${scroll}px)`, filter: scrollBlur > 0.5 ? `blur(${scrollBlur}px)` : undefined }}>
                <Img src={staticFile(SCREENS.nova1)} style={{ width: "100%", display: "block" }} />
                <Img src={staticFile(SCREENS.nova2)} style={{ width: "100%", display: "block", marginTop: -2 }} />
              </div>
              <div
                style={{
                  position: "absolute",
                  right: 5,
                  top: `${interpolate(-scroll, [0, maxScroll], [4, 62], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })}%`,
                  width: 5,
                  height: "34%",
                  borderRadius: 99,
                  background: "rgba(10,16,40,0.4)",
                  opacity: Math.min(1, Math.abs(scrollVel) * 0.12),
                }}
              />
            </AbsoluteFill>
          }
        />
      </div>

      {/* ── Stage 1: spotlight typing pill (camera-tracked) ── */}
      {pillOpacity > 0 ? (
        <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", filter: camBlur > 0.5 ? `blur(${camBlur}px)` : undefined }}>
          <div
            style={{
              transform: `translate(${pillX}px, ${pillY}px) scale(${camZoom})`,
              opacity: pillOpacity,
              width: pillW,
              height: pillH,
              borderRadius: 999,
              background: "linear-gradient(135deg, rgba(255,255,255,0.16), rgba(255,255,255,0.07))",
              border: "1.5px solid rgba(255,255,255,0.24)",
              boxShadow: "inset 0 1.5px 0 rgba(255,255,255,0.35), 0 40px 90px -30px rgba(0,0,0,0.7), 0 0 90px -20px rgba(91,141,239,0.4)",
              backdropFilter: "blur(18px)",
              WebkitBackdropFilter: "blur(18px)",
              display: "flex",
              alignItems: "center",
              paddingLeft: pillH * 0.36,
              paddingRight: pillH * 0.14,
              overflow: "hidden",
            }}
          >
            <div style={{ flex: 1, overflow: "hidden", whiteSpace: "nowrap", fontFamily: FONTS.body, fontWeight: 600, fontSize: pillFont, color: "#F2F5FF" }}>
              {typed === 0 ? <span style={{ opacity: 0.45 }}>Message NOVA</span> : TEXT.slice(0, typed)}
              <span style={{ opacity: typed >= TEXT.length ? (blink ? 1 : 0) : 1, fontWeight: 300, color: COLORS.sky }}>|</span>
            </div>
            {/* send */}
            <div
              style={{
                width: pillH * 0.72,
                height: pillH * 0.72,
                borderRadius: 999,
                background: `linear-gradient(140deg, ${COLORS.sky}, ${COLORS.indigo})`,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                color: "#fff",
                fontSize: pillH * 0.34,
                fontWeight: 800,
                transform: `scale(${1 + 0.22 * sendPulse})`,
                boxShadow: `0 0 ${26 * sendPulse}px ${COLORS.sky}`,
                flexShrink: 0,
              }}
            >
              ↑
            </div>
          </div>
        </AbsoluteFill>
      ) : null}

      {/* NOVA sparkle badge above the pill during typing */}
      {pillOpacity > 0.99 ? (
        <div style={{ position: "absolute", left: "50%", top: "31%", transform: `translateX(calc(-50% + ${camX * 0.3}px))` }}>
          <LiquidPanel pad="10px 22px">
            <span style={{ fontSize: 26 }}>✦</span>
            <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 24, letterSpacing: 3, color: "#DCE6FF" }}>NOVA</span>
          </LiquidPanel>
        </div>
      ) : null}

      {/* ── caption (after morph) ── */}
      <AbsoluteFill style={{ justifyContent: "center", padding: "0 7.5%" }}>
        <div style={{ maxWidth: 620 }}>
          <div style={{ opacity: kickIn, transform: `translateY(${interpolate(kickIn, [0, 1], [14, 0])}px)`, marginBottom: 20 }}>
            <LiquidPanel pad="10px 24px">
              <span style={{ fontFamily: FONTS.body, fontSize: 20, letterSpacing: 5, textTransform: "uppercase", color: COLORS.skyLight, fontWeight: 800 }}>AI Tutor</span>
            </LiquidPanel>
          </div>
          <div style={{ fontFamily: FONTS.display, fontSize: 88, lineHeight: 1.0, fontWeight: 800, color: "#F2F5FF", letterSpacing: -2, whiteSpace: "pre-line", opacity: titleIn, transform: `translateY(${interpolate(titleIn, [0, 1], [30, 0])}px)`, textShadow: "0 8px 50px rgba(91,141,239,0.35)" }}>
            Ask NOVA{"\n"}anything.
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
