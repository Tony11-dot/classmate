import React from "react";
import { AbsoluteFill, Img, interpolate, Sequence, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS } from "../theme";
import { TypeOn } from "../components/TypeOn";
import { WordPop } from "../components/WordPop";
import { pop } from "../anim";

/**
 * ACT 2 — the product, in the dark glowing-glass AI language of ref4:
 * near-black world, translucent panels with luminous borders, a pulsing ring
 * orb, typing everywhere, gentle 3D drift — everything glows and floats.
 *
 *  c1 chat            "How can I help?" pill + Ask-NOVA + typed question
 *  c2 options         three glowing chips stack (solutions/practice/exams)
 *  c3 button zoom     the ✦ Ask NOVA pill, mega-glow
 *  c4 live panels     "Real-Time Results" dual glass panels + waveform
 *  c5 orb             ring orb pulse, breath moment
 *  c6 future          "The future of your school ✦ is here"
 *  c7 end card        white CM mark + ClassMate glow + Get Started
 */
export const PBEATS = {
  chat: 0,
  options: 420,
  button: 600,
  panels: 700,
  orb: 980,
  future: 1070,
  end: 1230,
  out: 1410,
} as const;

const OVERLAP = 10;

const useCam = (local: number, dur: number, fps: number) => {
  // speed-ramp: FAST in → slow-motion drift → FAST out (tab-swipe feel)
  const enter = spring({ frame: local, fps, config: { damping: 15, mass: 0.6, stiffness: 280 } });
  const exitT = interpolate(local, [dur - 9, dur], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const drift = 1 + (local / dur) * 0.05; // the slow-mo push
  return {
    scale: interpolate(enter, [0, 1], [0.72, 1]) * drift * interpolate(exitT, [0, 1], [1, 1.45]),
    x: (1 - enter) * 340 + exitT * -420,
    blur: (1 - enter) * 7 + exitT * 14,
    opacity: interpolate(exitT, [0.5, 1], [1, 0], { extrapolateLeft: "clamp" }),
  };
};
const Beat: React.FC<{ from: number; to: number; children: React.ReactNode }> = ({ from, to, children }) => (
  <Sequence from={from} durationInFrames={to - from + OVERLAP}>
    <BeatInner>{children}</BeatInner>
  </Sequence>
);
const BeatInner: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const local = useCurrentFrame();
  const { fps, durationInFrames: dur } = useVideoConfig();
  const cam = useCam(local, dur, fps);
  return (
    <AbsoluteFill style={{ opacity: cam.opacity }}>
      <div style={{ position: "absolute", inset: 0, transform: `translateX(${cam.x}px) scale(${cam.scale})`, filter: cam.blur > 0.6 ? `blur(${cam.blur}px)` : undefined }}>{children}</div>
    </AbsoluteFill>
  );
};

/** Deep-space bg with slow luminous swirls — never still. */
const Deep: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill style={{ background: "radial-gradient(120% 100% at 50% 20%, #0b1226 0%, #05070f 55%, #03040a 100%)" }}>
      <AbsoluteFill
        style={{
          background: `radial-gradient(40% 50% at ${20 + Math.sin(f / 80) * 6}% ${70 + Math.cos(f / 95) * 5}%, rgba(80,110,220,0.16) 0%, transparent 60%),
                       radial-gradient(44% 52% at ${82 - Math.sin(f / 74) * 6}% ${26 + Math.sin(f / 66) * 5}%, rgba(120,90,230,0.13) 0%, transparent 62%)`,
          filter: "blur(10px)",
        }}
      />
      <AbsoluteFill style={{ background: `linear-gradient(115deg, transparent ${((f * 0.7) % 180) - 40}%, rgba(160,190,255,0.045) ${((f * 0.7) % 180) - 32}%, transparent ${((f * 0.7) % 180) - 24}%)`, mixBlendMode: "screen" }} />
      <AbsoluteFill style={{ background: "radial-gradient(80% 80% at 50% 45%, transparent 52%, rgba(0,0,0,0.55) 100%)" }} />
    </AbsoluteFill>
  );
};

/** Glowing glass panel — the ref4 signature surface. */
const Glow: React.FC<{ at?: number; local: number; w?: number; tilt?: number; style?: React.CSSProperties; children: React.ReactNode }> = ({ at = 0, local, w, tilt = 0, style, children }) => {
  const { fps } = useVideoConfig();
  const s = spring({ frame: local - at, fps, config: { damping: 14, mass: 0.7, stiffness: 190 } });
  const bob = Math.sin(local / 32 + at) * 5;
  return (
    <div
      style={{
        width: w,
        borderRadius: 24,
        background: "linear-gradient(160deg, rgba(30,40,72,0.72), rgba(14,18,38,0.78))",
        border: "1.5px solid rgba(150,180,255,0.4)",
        boxShadow: "0 0 44px rgba(110,140,255,0.22), inset 0 1px 0 rgba(200,220,255,0.28), 0 34px 80px -30px rgba(0,0,0,0.8)",
        backdropFilter: "blur(14px)",
        WebkitBackdropFilter: "blur(14px)",
        transform: `perspective(1400px) rotateX(${tilt}deg) translateY(${(1 - s) * 42 + bob}px) scale(${0.88 + 0.12 * s})`,
        opacity: Math.min(1, s * 1.5),
        ...style,
      }}
    >
      {children}
    </div>
  );
};

/** Pulsing ring orb — the AI mark. */
const Orb: React.FC<{ size?: number; local: number }> = ({ size = 64, local }) => {
  const breathe = 1 + 0.08 * Math.sin(local / 14);
  return (
    <div style={{ width: size, height: size, position: "relative", transform: `scale(${breathe}) rotate(${local * 1.2}deg)` }}>
      <div style={{ position: "absolute", inset: 0, borderRadius: "50%", border: `${size * 0.1}px solid rgba(170,195,255,0.9)`, borderTopColor: "rgba(120,150,255,0.25)", boxShadow: `0 0 ${size * 0.5}px rgba(140,170,255,0.7), inset 0 0 ${size * 0.25}px rgba(140,170,255,0.5)` }} />
      <div style={{ position: "absolute", inset: "26%", borderRadius: "50%", background: "radial-gradient(circle, rgba(200,220,255,0.9), rgba(120,150,255,0.15) 70%)", filter: "blur(2px)" }} />
    </div>
  );
};

const GlowText: React.FC<{ size?: number; children: React.ReactNode; weight?: number }> = ({ size = 30, children, weight = 700 }) => (
  <span style={{ fontFamily: FONTS.body, fontWeight: weight, fontSize: size, color: "#E7EDFF", textShadow: "0 0 22px rgba(160,190,255,0.65)" }}>{children}</span>
);

// ── beats ────────────────────────────────────────────────────────────────────

const Chat: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const TEXT = "How can I get ready for my math exam?";
  const F = 34;
  const TYPE_START = 96, CPS = 30;
  const typeFrames = Math.ceil((TEXT.length / CPS) * fps);
  const SEND = TYPE_START + typeFrames + 10; // ≈182
  const ZOOM_OUT = SEND + 14;

  // star flies in on an arc, spinning, then docks as the header orb
  const starIn = spring({ frame: local - 4, fps, config: { damping: 13, mass: 0.7, stiffness: 170 } });
  const dock = spring({ frame: local - 66, fps, config: { damping: 15, mass: 0.7, stiffness: 190 } });
  const starX = interpolate(starIn, [0, 1], [900, 0]) ;
  const starY = interpolate(starIn, [0, 1], [-560, 0]) + interpolate(dock, [0, 1], [0, -250]);
  const starScale = interpolate(starIn, [0, 1], [0.3, 1.6]) * interpolate(dock, [0, 1], [1, 0.45]);

  // camera: zoomed into the pill while typing, follows the caret, zooms out fast on send
  const typed = Math.max(0, Math.min(TEXT.length, Math.floor(((local - TYPE_START) / fps) * CPS)));
  const caretX = interpolate(local, [TYPE_START, TYPE_START + typeFrames], [0, TEXT.length * F * 0.47], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const zoomOut = spring({ frame: local - ZOOM_OUT, fps, config: { damping: 15, mass: 0.7, stiffness: 200 } });
  const zoomIn = spring({ frame: local - 78, fps, config: { damping: 16, mass: 0.8, stiffness: 150 } });
  const zoom = 1 + zoomIn * 0.55 * (1 - zoomOut);
  const followX = -Math.max(0, caretX - 260) * 0.75 * (zoom - 1);
  const sendPop = pop(local, fps, SEND);

  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Deep />
      {/* flying star → docks into header */}
      <div style={{ position: "absolute", transform: `translate(${starX}px, ${starY}px) scale(${starScale}) rotate(${local * 4}deg)`, zIndex: 6, filter: "drop-shadow(0 0 26px rgba(150,180,255,0.9))" }}>
        <div style={{ fontSize: 64, color: "#DCE6FF" }}>✦</div>
      </div>
      {/* Meet NOVA */}
      <div style={{ position: "absolute", top: "17%", opacity: (1 - dock) * interpolate(starIn, [0.5, 1], [0, 1], { extrapolateLeft: "clamp" }) }}>
        <WordPop text="Meet |NOVA" offsets={[26, 40]} size={110} color="#EEF2FF" highlight="#9DBBFF" />
      </div>
      {/* docked header */}
      <div style={{ position: "absolute", top: "13%", opacity: dock, display: "flex", alignItems: "center", gap: 16 }}>
        <Orb size={44} local={local} />
        <span style={{ fontFamily: FONTS.display, fontWeight: 800, fontSize: 46, color: "#EEF2FF", textShadow: "0 0 30px rgba(150,180,255,0.7)" }}>NOVA AI</span>
      </div>

      {/* camera-tracked stage */}
      <div style={{ position: "absolute", top: "40%", width: 780, transform: `scale(${zoom}) translateX(${followX}px)` }}>
        {/* prompt pill with typing + send */}
        <Glow at={70} local={local} style={{ padding: "18px 16px 18px 28px", borderRadius: 999, display: "flex", alignItems: "center", gap: 14 }}>
          <div style={{ flex: 1, fontFamily: FONTS.body, fontWeight: 600, fontSize: F, color: "#EEF2FF", whiteSpace: "nowrap", overflow: "hidden" }}>
            {typed === 0 ? <span style={{ opacity: 0.4 }}>Message NOVA</span> : TEXT.slice(0, typed)}
            <span style={{ opacity: local > SEND ? 0 : 1, fontWeight: 300, color: "#9DBBFF" }}>|</span>
          </div>
          <div style={{ width: 56, height: 56, borderRadius: 99, background: "rgba(205,220,255,0.95)", display: "flex", alignItems: "center", justifyContent: "center", color: "#141c3c", fontWeight: 900, fontSize: 26, flexShrink: 0, transform: `scale(${1 + 0.25 * sendPop})`, boxShadow: `0 0 ${20 + 34 * sendPop}px rgba(170,195,255,0.9)` }}>↑</div>
        </Glow>

        {/* convo revealed after zoom-out */}
        {local >= ZOOM_OUT + 4 ? (
          <div style={{ display: "flex", justifyContent: "flex-end", marginTop: 18 }}>
            <div style={{ transform: `scale(${pop(local, fps, ZOOM_OUT + 4)})`, transformOrigin: "right", borderRadius: "20px 20px 6px 20px", padding: "13px 20px", background: "linear-gradient(140deg, rgba(90,125,240,0.9), rgba(60,80,200,0.9))", boxShadow: "0 0 30px rgba(100,130,255,0.5)", fontFamily: FONTS.body, fontWeight: 600, fontSize: 23, color: "#fff" }}>{TEXT}</div>
          </div>
        ) : null}
        {local >= ZOOM_OUT + 16 ? (
          <Glow at={ZOOM_OUT + 16} local={local} style={{ marginTop: 16, padding: "16px 22px" }}>
            <div style={{ display: "flex", gap: 12, alignItems: "flex-start" }}>
              <Orb size={28} local={local} />
              <div style={{ flex: 1, fontFamily: FONTS.body, fontWeight: 500, fontSize: 22, lineHeight: 1.45, color: "#C9D4F5" }}>
                <TypeOn text="Let's build a plan — I'll explain every step, in your language." start={ZOOM_OUT + 22} cps={36} caret={local < ZOOM_OUT + 130} />
              </div>
            </div>
          </Glow>
        ) : null}
        {/* suggestion chips keep the scene alive */}
        {local >= ZOOM_OUT + 120 ? (
          <div style={{ display: "flex", gap: 12, marginTop: 16 }}>
            {["Study plan", "5 practice Qs", "Explain again"].map((c, i) => (
              <div key={i} style={{ transform: `scale(${pop(local, fps, ZOOM_OUT + 120 + i * 8)}) translateY(${Math.sin(local / 24 + i * 2) * 3}px)`, borderRadius: 999, padding: "10px 20px", border: "1.5px solid rgba(150,180,255,0.45)", background: "rgba(30,40,72,0.6)", fontFamily: FONTS.body, fontWeight: 700, fontSize: 20, color: "#C9D4F5", boxShadow: "0 0 18px rgba(110,140,255,0.2)" }}>{c}</div>
            ))}
          </div>
        ) : null}
      </div>
    </AbsoluteFill>
  );
};

const Options: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opts = [
    { t: "Step-by-step solutions", lit: true, d: 26 },
    { t: "Practice questions", lit: false, d: 40 },
    { t: "Exam study plans", lit: false, d: 54 },
  ];
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Deep />
      <div style={{ position: "absolute", left: "8%", top: "30%", opacity: 0.85 }}><Orb size={90} local={local} /></div>
      <div style={{ width: 780 }}>
        <Glow at={6} local={local} style={{ padding: "16px 26px", borderRadius: 999, marginBottom: 22 }}>
          <GlowText size={27}>NOVA can help with…</GlowText>
        </Glow>
        {opts.map((o, i) => {
          const s = spring({ frame: local - o.d, fps, config: { damping: 12, mass: 0.65, stiffness: 220 } });
          if (local < o.d - 2) return null;
          return (
            <div key={i} style={{ transform: `translateY(${(1 - s) * 36 + Math.sin(local / 30 + i * 2) * 4}px) scale(${0.9 + 0.1 * s})`, opacity: Math.min(1, s * 1.4), marginBottom: 14, borderRadius: 18, padding: "20px 26px", display: "flex", alignItems: "center", gap: 16, background: o.lit ? "linear-gradient(140deg, rgba(105,135,250,0.85), rgba(70,95,225,0.85))" : "linear-gradient(160deg, rgba(30,40,72,0.75), rgba(14,18,38,0.8))", border: `1.5px solid ${o.lit ? "rgba(190,205,255,0.75)" : "rgba(150,180,255,0.35)"}`, boxShadow: o.lit ? "0 0 44px rgba(120,150,255,0.55)" : "0 0 24px rgba(110,140,255,0.16)" }}>
              <Orb size={26} local={local + i * 7} />
              <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 28, color: o.lit ? "#fff" : "#C9D4F5", textShadow: o.lit ? "0 0 18px rgba(255,255,255,0.5)" : undefined }}>{o.t}</span>
            </div>
          );
        })}
        <div style={{ marginTop: 20, opacity: pop(local, fps, 96), fontFamily: FONTS.body, fontWeight: 500, fontSize: 21, lineHeight: 1.5, color: "#8fa0cf", maxWidth: 700 }}>
          <TypeOn text="NOVA is a personal AI tutor for every student — 16 subjects, 5 languages, always available." start={100} cps={38} caret={local < 210} />
        </div>
      </div>
    </AbsoluteFill>
  );
};

const ButtonZoom: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = pop(local, fps, 6);
  const glow = 40 + 26 * Math.sin(local / 9);
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Deep />
      <div style={{ transform: `scale(${1.4 * s + 0.04 * Math.sin(local / 18)})`, borderRadius: 999, padding: "26px 54px", display: "flex", alignItems: "center", gap: 18, background: "rgba(205,220,255,0.95)", boxShadow: `0 0 ${glow}px rgba(170,195,255,0.95), 0 0 ${glow * 2.4}px rgba(120,150,255,0.5)` }}>
        <Orb size={40} local={local} />
        <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 40, color: "#141c3c" }}>Ask NOVA</span>
      </div>
    </AbsoluteFill>
  );
};

const Panels: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const rows = [
    { t: "Mathematics", v: 100 }, { t: "Physics", v: 99 }, { t: "English", v: 95 },
  ];
  const students = ["Amir K.", "Sarah L.", "Dana M.", "Yousef H."];
  const wave = Array.from({ length: 60 }, (_, i) => 6 + Math.abs(Math.sin(i * 0.55 + local / 6)) * 22 * (0.4 + 0.6 * Math.abs(Math.sin(i * 0.13 + local / 40))));
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Deep />
      <div style={{ position: "absolute", top: "9%", display: "flex", alignItems: "center", gap: 16, opacity: pop(local, fps, 6) }}>
        <Orb size={40} local={local} />
        <span style={{ fontFamily: FONTS.display, fontWeight: 800, fontSize: 56, color: "#DEE7FF", letterSpacing: -0.5, textShadow: "0 0 34px rgba(150,180,255,0.75)" }}>Real-Time Results</span>
      </div>
      <div style={{ display: "flex", gap: 26, transform: `perspective(1500px) rotateX(${5 + Math.sin(local / 60) * 1.5}deg)` }}>
        <Glow at={18} local={local} w={520} tilt={0} style={{ padding: "22px 26px" }}>
          <div style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 20, letterSpacing: 2, color: "#8fa0cf", marginBottom: 14 }}>INSIGHTS</div>
          <div style={{ fontFamily: FONTS.display, fontWeight: 800, fontSize: 62, color: "#EEF2FF", fontVariantNumeric: "tabular-nums", textShadow: "0 0 26px rgba(150,180,255,0.6)", lineHeight: 1 }}>
            {interpolate(local, [24, 66], [0, 93.5], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }).toFixed(1)}
            <span style={{ fontSize: 26, opacity: 0.5 }}> /100</span>
          </div>
          {rows.map((r, i) => {
            const at = 40 + i * 12;
            const bs = spring({ frame: local - at, fps, config: { damping: 16, stiffness: 110 } });
            if (local < at - 2) return null;
            return (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: 14, marginTop: 13, opacity: Math.min(1, bs * 1.4) }}>
                <span style={{ fontFamily: FONTS.body, fontWeight: 600, fontSize: 21, color: "#C9D4F5", width: 150 }}>{r.t}</span>
                <div style={{ flex: 1, height: 9, borderRadius: 99, background: "rgba(150,180,255,0.14)" }}>
                  <div style={{ width: `${r.v * bs}%`, height: "100%", borderRadius: 99, background: "linear-gradient(90deg, #7FA2FF, #B9CCFF)", boxShadow: "0 0 14px rgba(140,170,255,0.8)" }} />
                </div>
                <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 21, color: "#B9CCFF", width: 44, textAlign: "right" }}>{Math.round(r.v * Math.min(1, bs))}</span>
              </div>
            );
          })}
        </Glow>
        <Glow at={30} local={local} w={520} tilt={0} style={{ padding: "22px 26px" }}>
          <div style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 20, letterSpacing: 2, color: "#8fa0cf", marginBottom: 14 }}>ATTENDANCE · LIVE</div>
          {students.map((n, i) => {
            const at = 44 + i * 12;
            const cs = pop(local, fps, at + 26);
            const rs = pop(local, fps, at);
            if (local < at - 2) return null;
            return (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: 14, marginBottom: 13, opacity: Math.min(1, rs * 1.4), transform: `translateX(${(1 - rs) * 30}px)` }}>
                <div style={{ width: 40, height: 40, borderRadius: 99, background: `hsl(${215 + i * 30}, 55%, 55%)`, display: "flex", alignItems: "center", justifyContent: "center", color: "#fff", fontFamily: FONTS.body, fontWeight: 800, fontSize: 18, boxShadow: "0 0 16px rgba(120,150,255,0.4)" }}>{n[0]}</div>
                <span style={{ flex: 1, fontFamily: FONTS.body, fontWeight: 600, fontSize: 22, color: "#C9D4F5" }}>{n}</span>
                <div style={{ width: 30, height: 30, borderRadius: 99, background: local >= at + 26 ? "#37D183" : "rgba(150,180,255,0.15)", display: "flex", alignItems: "center", justifyContent: "center", color: "#04150c", fontWeight: 900, fontSize: 17, transform: `scale(${local >= at + 26 ? 0.8 + 0.2 * cs : 1})`, boxShadow: local >= at + 26 ? "0 0 16px rgba(55,209,131,0.7)" : undefined }}>{local >= at + 26 ? "✓" : ""}</div>
              </div>
            );
          })}
        </Glow>
      </div>
      {/* waveform */}
      <div style={{ position: "absolute", bottom: "9%", display: "flex", alignItems: "flex-end", gap: 5, opacity: pop(local, fps, 50) }}>
        {wave.map((h, i) => (
          <div key={i} style={{ width: 5, height: h, borderRadius: 99, background: "rgba(140,170,255,0.75)", boxShadow: "0 0 8px rgba(140,170,255,0.6)" }} />
        ))}
      </div>
    </AbsoluteFill>
  );
};

const OrbBreath: React.FC = () => {
  const local = useCurrentFrame();
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Deep />
      <Orb size={110} local={local} />
    </AbsoluteFill>
  );
};

const Future: React.FC = () => {
  const local = useCurrentFrame();
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Deep />
      <div style={{ display: "flex", alignItems: "center", gap: 24 }}>
        <div style={{ textShadow: "0 0 30px rgba(170,195,255,0.7)" }}>
          <WordPop text="The future of your school" start={6} step={7} size={64} color="#EEF2FF" />
        </div>
        <div style={{ opacity: interpolate(local, [40, 90], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }) }}><Orb size={54} local={local} /></div>
        <div style={{ textShadow: "0 0 30px rgba(170,195,255,0.7)" }}>
          <WordPop text="is here" start={100} step={9} size={64} color="#EEF2FF" />
        </div>
      </div>
    </AbsoluteFill>
  );
};

const EndCard: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = pop(local, fps, 8);
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Deep />
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 20 }}>
        <div style={{ transform: `scale(${s * (1 + 0.02 * Math.sin(local / 20))})`, width: 140, height: 140, borderRadius: 36, background: `linear-gradient(150deg, ${COLORS.indigo}, ${COLORS.indigoDeep})`, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: "0 0 70px rgba(90,120,240,0.6)" }}>
          <Img src={staticFile("brand/icon_light.png")} style={{ width: 92, height: 92, objectFit: "contain" }} />
        </div>
        <div style={{ opacity: pop(local, fps, 22), fontFamily: FONTS.display, fontWeight: 800, fontSize: 100, letterSpacing: -2, color: "#EEF2FF", textShadow: "0 0 44px rgba(160,190,255,0.8), 0 0 120px rgba(120,150,255,0.5)" }}>
          ClassMate
        </div>
        <div style={{ opacity: pop(local, fps, 40) * (0.75 + 0.25 * Math.sin(local / 16)), fontFamily: FONTS.body, fontWeight: 700, fontSize: 30, color: "#93A3D8", letterSpacing: 3 }}>
          Get Started
        </div>
        <div style={{ opacity: pop(local, fps, 54), fontFamily: FONTS.mono, fontWeight: 600, fontSize: 24, color: "#6f7fb2", letterSpacing: 2 }}>
          classmateapp.org
        </div>
      </div>
    </AbsoluteFill>
  );
};

export const ActProduct: React.FC = () => (
  <AbsoluteFill style={{ background: "#04060d" }}>
    <Beat from={PBEATS.chat} to={PBEATS.options}><Chat /></Beat>
    <Beat from={PBEATS.options} to={PBEATS.button}><Options /></Beat>
    <Beat from={PBEATS.button} to={PBEATS.panels}><ButtonZoom /></Beat>
    <Beat from={PBEATS.panels} to={PBEATS.orb}><Panels /></Beat>
    <Beat from={PBEATS.orb} to={PBEATS.future}><OrbBreath /></Beat>
    <Beat from={PBEATS.future} to={PBEATS.end}><Future /></Beat>
    <Beat from={PBEATS.end} to={PBEATS.out}><EndCard /></Beat>
  </AbsoluteFill>
);
