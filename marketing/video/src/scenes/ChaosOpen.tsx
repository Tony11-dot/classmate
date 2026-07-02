import React from "react";
import { AbsoluteFill, Img, interpolate, Sequence, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS, SHOT } from "../theme";
import { AuroraLight } from "../components/AuroraLight";
import { GlassBG } from "../components/Glass";
import { AppTile, APPS } from "../components/AppTile";
import { WordPop } from "../components/WordPop";
import { TypeOn } from "../components/TypeOn";
import { HeroPhone } from "../components/HeroPhone";
import { motionBlur, pop } from "../anim";

/**
 * The ref1-style opener, rebuilt as ONE continuous camera move (~19s @60fps).
 * Every beat hands off to the next with a forward zoom-through — no hard cuts.
 *
 *  B1 "These days"            kinetic words, phone shoves them aside
 *  B2 phone + app burst       icons explode out of the phone, badges tick
 *  B3 DARK glitch             "disconnected apps" — suspense beat
 *  B4 notification rain       pills pile up → scatter → "all over the place."
 *  B5 sticky checklist        "So..." lines type in, VO-synced
 *  B6 vacuum → flash → logo   "ClassMate changes everything." + tagline
 */

/** Beat map (scene-local frames) — exported so Video.tsx can sync VO + SFX. */
export const BEATS = {
  these: 0,
  phone: 70,
  dark: 240,
  notifs: 330,
  sticky: 505,
  impact: 715,
  flash: 761, // vacuum ends, logo lands — the music drop hits here
  tagline: 870,
  end: 975,
} as const;

const OVERLAP = 14; // beats crossfade-through-zoom for the one-take feel

/** Camera hand-off: every beat enters small+soft and exits pushing past the lens. */
const useBeatCam = (local: number, dur: number, fps: number) => {
  const enter = spring({ frame: local, fps, config: { damping: 17, mass: 0.8, stiffness: 120 } });
  const exitT = interpolate(local, [dur - OVERLAP, dur], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const scale = interpolate(enter, [0, 1], [0.88, 1]) * interpolate(exitT, [0, 1], [1, 1.28]);
  const blur = (1 - enter) * 6 + exitT * 9;
  const opacity = interpolate(exitT, [0.55, 1], [1, 0], { extrapolateLeft: "clamp" });
  return { scale, blur, opacity };
};

const Beat: React.FC<{ from: number; to: number; children: (local: number, dur: number) => React.ReactNode }> = ({ from, to, children }) => {
  const dur = to - from + OVERLAP;
  return (
    <Sequence from={from} durationInFrames={dur}>
      <BeatInner dur={dur}>{children}</BeatInner>
    </Sequence>
  );
};
const BeatInner: React.FC<{ dur: number; children: (local: number, dur: number) => React.ReactNode }> = ({ dur, children }) => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const cam = useBeatCam(local, dur, fps);
  return (
    <AbsoluteFill style={{ opacity: cam.opacity }}>
      <div style={{ position: "absolute", inset: 0, transform: `scale(${cam.scale})`, filter: cam.blur > 0.6 ? `blur(${cam.blur}px)` : undefined }}>
        {children(local, dur)}
      </div>
    </AbsoluteFill>
  );
};

// ─────────────────────────────────────────────────────────────────────────────

export const ChaosOpen: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: "#f4f7fe" }}>
      {/* B1 — "These days" */}
      <Beat from={BEATS.these} to={BEATS.phone}>
        {() => (
          <AbsoluteFill>
            <AuroraLight />
            <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
              <WordPop text="These days..." start={6} step={11} size={128} />
            </AbsoluteFill>
          </AbsoluteFill>
        )}
      </Beat>

      {/* B2 — phone whips in, apps burst out */}
      <Beat from={BEATS.phone} to={BEATS.dark}>
        {(local) => <PhoneBurst local={local} />}
      </Beat>

      {/* B3 — dark glitch beat */}
      <Beat from={BEATS.dark} to={BEATS.notifs}>
        {(local) => <DarkGlitch local={local} />}
      </Beat>

      {/* B4 — notification rain → scatter → words */}
      <Beat from={BEATS.notifs} to={BEATS.sticky}>
        {(local) => <NotifRain local={local} />}
      </Beat>

      {/* B5 — sticky checklist */}
      <Beat from={BEATS.sticky} to={BEATS.impact}>
        {(local) => <Sticky local={local} />}
      </Beat>

      {/* B6 — vacuum → flash → logo → tagline (runs to scene end) */}
      <Beat from={BEATS.impact} to={BEATS.end}>
        {(local) => <Impact local={local} />}
      </Beat>
    </AbsoluteFill>
  );
};

// ── B2 ───────────────────────────────────────────────────────────────────────

const HomeGrid: React.FC = () => {
  const tiles = Array.from({ length: 24 }, (_, i) => i);
  const hues = ["#5B8DEF", "#F4B23E", "#23C16B", "#8B5CF6", "#EF6461", "#38BDF8", "#F59E0B", "#94A3B8"];
  const brand = [APPS.whatsapp, APPS.zoom, APPS.classroom, APPS.chatgpt, APPS.livetop];
  return (
    <AbsoluteFill style={{ background: "linear-gradient(180deg,#EAF0FC,#DCE6F9)", padding: "14% 8% 8%" }}>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", gap: "9%" }}>
        {tiles.map((i) => {
          const b = i % 5 === 2 && i / 5 < 5 ? brand[Math.floor(i / 5)] : null;
          return b ? (
            <div key={i} style={{ aspectRatio: "1", borderRadius: "24%", background: `linear-gradient(150deg, ${b.c1}, ${b.c2})`, display: "flex", alignItems: "center", justifyContent: "center", padding: "18%" }}>{b.glyph}</div>
          ) : (
            <div key={i} style={{ aspectRatio: "1", borderRadius: "24%", background: `linear-gradient(150deg, ${hues[i % 8]}cc, ${hues[(i + 3) % 8]}99)` }} />
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

const PhoneBurst: React.FC<{ local: number }> = ({ local }) => {
  const { fps } = useVideoConfig();
  const inAt = (f: number) => spring({ frame: f, fps, config: { damping: 15, mass: 0.9, stiffness: 150 } });
  const yIn = interpolate(inAt(local), [0, 1], [860, 0]);
  const blur = motionBlur(Math.abs(interpolate(inAt(local), [0, 1], [860, 0]) - interpolate(inAt(local - 1), [0, 1], [860, 0])), 0.04);
  const orbit = [
    { app: APPS.whatsapp, x: -470, y: -150, d: 26 },
    { app: APPS.zoom, x: 455, y: -185, d: 32 },
    { app: APPS.classroom, x: -520, y: 190, d: 38 },
    { app: APPS.chatgpt, x: 505, y: 175, d: 44 },
    { app: APPS.livetop, x: -30, y: -335, d: 50 },
  ];
  return (
    <AbsoluteFill>
      <AuroraLight />
      {/* phone */}
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <div style={{ transform: `translateY(${yIn + Math.sin(local / 38) * 8}px) rotate(${interpolate(inAt(local), [0, 1], [-10, -4])}deg)`, filter: blur > 0.5 ? `blur(${blur}px)` : undefined }}>
          <HeroPhone src="" screenWidth={330} rim={COLORS.sky} reflection={false} screenContent={<HomeGrid />} />
        </div>
      </AbsoluteFill>
      {/* bursting tiles */}
      {orbit.map((o, i) => {
        const s = spring({ frame: local - o.d, fps, config: { damping: 11, mass: 0.65, stiffness: 210 } });
        const wob = Math.sin(local / 30 + i * 1.9) * 14;
        const v = Math.abs(s - spring({ frame: local - 1 - o.d, fps, config: { damping: 11, mass: 0.65, stiffness: 210 } })) * Math.hypot(o.x, o.y);
        return (
          <div key={i} style={{ position: "absolute", left: "50%", top: "50%", transform: `translate(-50%,-50%) translate(${o.x * s}px, ${o.y * s + wob}px) scale(${Math.max(0.01, s)}) rotate(${(1 - s) * 40 - 8 + wob * 0.4}deg)`, filter: v > 12 ? `blur(${Math.min(8, v * 0.05)}px)` : undefined }}>
            <div style={{ position: "relative" }}>
              <AppTile app={o.app} size={124} label={false} />
              <div style={{ position: "absolute", top: -8, right: -8, minWidth: 32, height: 32, borderRadius: 99, background: "#FF3B30", color: "#fff", fontFamily: FONTS.body, fontWeight: 800, fontSize: 18, display: "flex", alignItems: "center", justifyContent: "center", padding: "0 7px", transform: `scale(${1 + 0.14 * Math.abs(Math.sin((local - o.d) / 16))})`, opacity: s }}>
                {Math.min(9 + i * 4, 3 + Math.floor(Math.max(0, local - o.d) / 22) * 4)}
              </div>
            </div>
          </div>
        );
      })}
    </AbsoluteFill>
  );
};

// ── B3 ───────────────────────────────────────────────────────────────────────

const DarkGlitch: React.FC<{ local: number }> = ({ local }) => {
  const shakeX = Math.sin(local / 28) * 6;
  const shakeY = Math.cos(local / 34) * 4;
  const glitch = local < 12 || (local > 40 && local < 46) || (local > 74 && local < 79);
  const blobs = [APPS.whatsapp.c1, APPS.zoom.c1, APPS.classroom.c1, APPS.chatgpt.c1, APPS.livetop.c1];
  return (
    <AbsoluteFill style={{ background: "#06070c" }}>
      {/* blurred glowing app-colour blobs drifting (the icons, out of focus) */}
      {blobs.map((c, i) => (
        <div key={i} style={{ position: "absolute", left: `${18 + i * 16 + Math.sin(local / 34 + i) * 3}%`, top: `${28 + (i % 2) * 34 + Math.cos(local / 40 + i * 2) * 4}%`, width: 150, height: 150, borderRadius: "50%", background: c, filter: "blur(46px)", opacity: 0.34 }} />
      ))}
      {/* scanlines */}
      <AbsoluteFill style={{ background: "repeating-linear-gradient(0deg, rgba(255,255,255,0.04) 0 1px, transparent 1px 4px)", opacity: 0.5 }} />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", transform: `translate(${shakeX}px, ${shakeY}px) scale(${1 + local * 0.0012})` }}>
        <div style={{ position: "relative" }}>
          {glitch ? (
            <>
              <div style={{ position: "absolute", inset: 0, transform: "translate(4px,0)", opacity: 0.55, filter: "blur(1px)" }}>
                <WordPop text="disconnected apps" start={4} step={9} size={92} color="#ff5c5c" weight={800} />
              </div>
              <div style={{ position: "absolute", inset: 0, transform: "translate(-4px,0)", opacity: 0.55, filter: "blur(1px)" }}>
                <WordPop text="disconnected apps" start={4} step={9} size={92} color="#5cc8ff" weight={800} />
              </div>
            </>
          ) : null}
          <div style={{ textShadow: "0 0 26px rgba(255,255,255,0.75), 0 0 70px rgba(120,150,255,0.5)" }}>
            <WordPop text="disconnected apps" start={4} step={9} size={92} color="#ffffff" weight={800} />
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

// ── B4 ───────────────────────────────────────────────────────────────────────

const NOTIFS = [
  { app: APPS.whatsapp, t: "Parents Group", s: "47 unread messages", when: "9m" },
  { app: APPS.zoom, t: "Meeting started", s: "Physics · Grade 12", when: "now" },
  { app: APPS.classroom, t: "New assignment", s: "Due tomorrow, 23:59", when: "2m" },
  { app: APPS.chatgpt, t: "Answer ready", s: "…but is it even right?", when: "5m" },
  { app: APPS.livetop, t: "Class going live", s: "Join now", when: "now" },
];

const NotifRain: React.FC<{ local: number }> = ({ local }) => {
  const { fps } = useVideoConfig();
  const SCATTER = 100;
  return (
    <AbsoluteFill>
      <AuroraLight />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        {NOTIFS.map((n, i) => {
          const at = 6 + i * 15;
          const s = spring({ frame: local - at, fps, config: { damping: 12, mass: 0.7, stiffness: 230 } });
          const sc = spring({ frame: local - SCATTER - i * 2, fps, config: { damping: 16, mass: 0.8, stiffness: 130 } });
          const dirX = (i % 2 === 0 ? -1 : 1) * (520 + i * 140);
          const dirY = (i - 2) * 190;
          const stackY = (i - (NOTIFS.length - 1) / 2) * 108;
          const v = Math.abs(sc - spring({ frame: local - 1 - SCATTER - i * 2, fps, config: { damping: 16, mass: 0.8, stiffness: 130 } })) * Math.hypot(dirX, dirY);
          return (
            <div
              key={i}
              style={{
                position: "absolute",
                transform: `translate(${sc * dirX}px, ${interpolate(s, [0, 1], [-420, stackY]) + sc * dirY}px) scale(${0.7 + 0.3 * s}) rotate(${(1 - s) * -6 + sc * (i % 2 ? 10 : -10)}deg)`,
                opacity: Math.min(1, s * 1.4) * (1 - interpolate(sc, [0.7, 1], [0, 1], { extrapolateLeft: "clamp" })),
                filter: v > 12 ? `blur(${Math.min(9, v * 0.05)}px)` : undefined,
                width: 560,
                background: "rgba(28,32,44,0.94)",
                borderRadius: 22,
                padding: "16px 20px",
                display: "flex",
                alignItems: "center",
                gap: 16,
                boxShadow: "0 24px 50px -16px rgba(10,16,40,0.45)",
              }}
            >
              <div style={{ width: 52, height: 52, borderRadius: 13, background: `linear-gradient(150deg, ${n.app.c1}, ${n.app.c2})`, display: "flex", alignItems: "center", justifyContent: "center", padding: 11, flexShrink: 0 }}>{n.app.glyph}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 24, color: "#fff" }}>{n.t}</div>
                <div style={{ fontFamily: FONTS.body, fontWeight: 500, fontSize: 21, color: "#B9C1D4" }}>{n.s}</div>
              </div>
              <div style={{ fontFamily: FONTS.body, fontSize: 18, color: "#8A93A8" }}>{n.when}</div>
            </div>
          );
        })}
        {/* words land in the cleared centre, synced to the VO tail */}
        <div style={{ position: "absolute" }}>
          <WordPop text="all over the |place." offsets={[108, 117, 127, 138]} size={104} />
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

// ── B5 ───────────────────────────────────────────────────────────────────────

const Sticky: React.FC<{ local: number }> = ({ local }) => {
  const { fps } = useVideoConfig();
  const inS = pop(local, fps, 6);
  const lines = [
    { t: "Work gets messy", at: 60 },
    { t: "Parents miss out", at: 116 },
    { t: "Everyone slows down", at: 172 },
  ];
  return (
    <AbsoluteFill>
      <AuroraLight hues={[COLORS.gold, COLORS.goldDeep, COLORS.sky, COLORS.indigoSoft]} />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <div style={{ width: 640, transform: `scale(${inS}) rotate(${interpolate(inS, [0, 1], [-7, -2])}deg)`, opacity: Math.min(1, inS * 1.3), borderRadius: 26, overflow: "hidden", boxShadow: "0 46px 90px -22px rgba(120,90,10,0.4), 0 10px 26px -8px rgba(20,30,80,0.25)" }}>
          {/* header */}
          <div style={{ background: "linear-gradient(180deg,#FFD75E,#F8C63C)", padding: "16px 24px", display: "flex", justifyContent: "space-between", alignItems: "center", fontFamily: FONTS.body, fontWeight: 700, fontSize: 20, color: "#6b5310" }}>
            <span>Wed, 2 Jul</span>
            <span style={{ opacity: 0.75 }}>··· Done</span>
          </div>
          <div style={{ background: "#FFFDF4", padding: "26px 30px 34px" }}>
            <div style={{ fontFamily: FONTS.display, fontWeight: 800, fontSize: 46, color: COLORS.ink, marginBottom: 6 }}>
              <TypeOn text="So..." start={22} cps={14} />
            </div>
            <div style={{ height: 2, background: "rgba(20,30,60,0.12)", margin: "12px 0 18px" }} />
            {lines.map((l, i) => {
              const rowIn = pop(local, fps, l.at - 6);
              if (local < l.at - 10) return null;
              return (
                <div key={i} style={{ display: "flex", alignItems: "center", gap: 16, marginBottom: 16, transform: `translateY(${interpolate(rowIn, [0, 1], [16, 0])}px) scale(${0.9 + 0.1 * rowIn})`, opacity: Math.min(1, rowIn * 1.4) }}>
                  <div style={{ width: 26, height: 26, borderRadius: 99, border: "2.5px solid rgba(20,30,60,0.3)", flexShrink: 0 }} />
                  <div style={{ fontFamily: FONTS.body, fontWeight: 600, fontSize: 30, color: "#2b3247" }}>
                    <TypeOn text={l.t} start={l.at} cps={26} caret={local < l.at + 40} />
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

// ── B6 ───────────────────────────────────────────────────────────────────────

const Impact: React.FC<{ local: number }> = ({ local }) => {
  const { fps } = useVideoConfig();
  const FLASH = BEATS.flash - BEATS.impact; // 46
  const TAG = BEATS.tagline - BEATS.impact; // 198

  // vacuum: chaos tokens spiral into the centre
  const suck = spring({ frame: local, fps, config: { damping: 16, mass: 1, stiffness: 64 }, durationInFrames: FLASH + 6 });
  const tokens = [
    { c: APPS.whatsapp, x: -560, y: -180 }, { c: APPS.zoom, x: 540, y: -210 },
    { c: APPS.classroom, x: -600, y: 230 }, { c: APPS.chatgpt, x: 580, y: 240 }, { c: APPS.livetop, x: 0, y: -330 },
  ];
  const flash = interpolate(local, [FLASH - 2, FLASH + 3, FLASH + 18], [0, 1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const ring = spring({ frame: local - FLASH, fps, config: { damping: 22, mass: 1, stiffness: 55 } });
  const logo = spring({ frame: local - FLASH - 2, fps, config: { damping: 10.5, mass: 0.7, stiffness: 230 } });
  const lightIn = interpolate(local, [FLASH, FLASH + 22], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  return (
    <AbsoluteFill style={{ background: "#06070c" }}>
      {/* the GLASS world floods in after the flash — hand-off to the tour */}
      <AbsoluteFill style={{ opacity: lightIn }}>
        <GlassBG />
      </AbsoluteFill>

      {/* vacuum tokens */}
      {local < FLASH + 4
        ? tokens.map((t, i) => {
            const px = t.x * (1 - suck);
            const py = t.y * (1 - suck);
            const v = Math.abs(suck - spring({ frame: local - 1, fps, config: { damping: 16, mass: 1, stiffness: 64 }, durationInFrames: FLASH + 6 })) * Math.hypot(t.x, t.y);
            return (
              <div key={i} style={{ position: "absolute", left: "50%", top: "50%", transform: `translate(-50%,-50%) translate(${px}px, ${py}px) scale(${Math.max(0.05, 1 - suck)}) rotate(${suck * 160}deg)`, filter: `blur(${Math.min(10, v * 0.06)}px)` }}>
                <AppTile app={t.c} size={110} label={false} />
              </div>
            );
          })
        : null}

      {/* shockwave */}
      {local >= FLASH ? (
        <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", pointerEvents: "none" }}>
          <div style={{ width: 160 + ring * 1500, height: 160 + ring * 1500, borderRadius: "50%", border: `4px solid ${COLORS.indigoSoft}`, opacity: (1 - ring) * 0.8 }} />
        </AbsoluteFill>
      ) : null}

      {/* logo + wordmark */}
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 42 }}>
          <div style={{ transform: `scale(${logo})`, width: 216, height: 216, borderRadius: 52, background: `linear-gradient(150deg, ${COLORS.indigo}, ${COLORS.indigoDeep})`, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: `0 44px 100px -22px ${COLORS.indigo}bb` }}>
            <Img src={staticFile("brand/cm-icon.png")} style={{ width: 142, height: 142, objectFit: "contain" }} />
          </div>
          {/* VO-synced: "ClassMate changes everything." */}
          <WordPop text="ClassMate changes |everything." offsets={[FLASH + 6, FLASH + 26, FLASH + 52]} size={84} color="#F2F5FF" highlight="#9DBBFF" />
          {/* tagline second line — always mounted so the column never reflows */}
          <WordPop text="Now you have |everything." offsets={[TAG + 4, TAG + 13, TAG + 22, TAG + 34]} size={56} color="#A8B2D0" highlight="#9DBBFF" weight={700} />
        </div>
      </AbsoluteFill>

      {/* white flash on top */}
      <AbsoluteFill style={{ background: "#fff", opacity: flash, pointerEvents: "none" }} />
    </AbsoluteFill>
  );
};
