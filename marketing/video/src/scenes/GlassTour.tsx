import React from "react";
import { AbsoluteFill, Img, interpolate, Sequence, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS } from "../theme";
import { GlassBG, LiquidPanel } from "../components/Glass";
import { GlassDock, Spot } from "../components/GlassDock";
import { Pointer } from "../components/Pointer";
import { TypeOn } from "../components/TypeOn";
import { WordPop } from "../components/WordPop";
import { RolesFan } from "./RolesFan";
import { CTALight } from "./CTALight";
import { pop } from "../anim";

/**
 * v8 tour — faster, always animating, minimal text.
 * One traveling camera over a parallaxed glass world. Captions are gone:
 * each station speaks through its own animation + a liquid-glass DOCK whose
 * tabs are the words of the phrase, lighting up with the VO. Cursor clicks,
 * momentum bobs and moving spotlights everywhere.
 */
export const TOUR = {
  everything: 0,
  nova: 200,
  practice: 500,
  grades: 670,
  schedule: 845,
  exam: 1005,
  solutions: 1180,
  teacher: 1345,
  roles: 1525,
  cta: 1675,
  end: 1915,
} as const;

const KEYS = ["everything", "nova", "practice", "grades", "schedule", "exam", "solutions", "teacher", "roles", "cta"] as const;
const SX = 2300;
const posOf = (i: number) => ({ x: i * SX, y: (i % 2) * 260 - 130 });
const A = 42; // arrival frame within each station (camera lands)

// ── shared blocks (all with perpetual idle motion) ──────────────────────────

const Panel: React.FC<{ at: number; local: number; w?: number; seed?: number; style?: React.CSSProperties; children: React.ReactNode }> = ({ at, local, w, seed = 0, style, children }) => {
  const { fps } = useVideoConfig();
  const s = spring({ frame: local - at, fps, config: { damping: 13, mass: 0.6, stiffness: 250 } });
  const bob = Math.sin(local / 30 + seed) * 4;
  const sway = Math.sin(local / 46 + seed) * 0.5;
  return (
    <div
      style={{
        width: w,
        background: "#ffffff",
        borderRadius: 26,
        boxShadow: "0 40px 90px -26px rgba(0,0,10,0.65), 0 6px 20px -8px rgba(0,0,10,0.4)",
        transform: `translateY(${(1 - s) * 48 + bob}px) scale(${0.86 + 0.14 * s}) rotate(${sway}deg)`,
        opacity: Math.min(1, s * 1.5),
        ...style,
      }}
    >
      {children}
    </div>
  );
};

const Chip: React.FC<{ at: number; local: number; color?: string; children: React.ReactNode }> = ({ at, local, color = "#DCE6FF", children }) => {
  const { fps } = useVideoConfig();
  const s = pop(local, fps, at);
  if (local < at - 2) return null;
  const breathe = 1 + 0.025 * Math.sin(local / 14);
  return (
    <div style={{ transform: `scale(${s * breathe}) translateY(${(1 - s) * 14 + Math.sin(local / 26) * 3}px)`, opacity: Math.min(1, s * 1.4) }}>
      <LiquidPanel pad="10px 24px">
        <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 25, color }}>{children}</span>
      </LiquidPanel>
    </div>
  );
};

const Bar: React.FC<{ at: number; local: number; frac: number; color: string; w?: number }> = ({ at, local, frac, color, w = 320 }) => {
  const { fps } = useVideoConfig();
  const s = spring({ frame: local - at, fps, config: { damping: 16, mass: 0.8, stiffness: 110 } });
  return (
    <div style={{ width: w, height: 14, borderRadius: 99, background: "rgba(20,30,60,0.1)", overflow: "hidden" }}>
      <div style={{ width: `${frac * 100 * s}%`, height: "100%", borderRadius: 99, background: color, boxShadow: `0 0 12px ${color}88` }} />
    </div>
  );
};

const Tick: React.FC<{ at: number; local: number }> = ({ at, local }) => {
  const { fps } = useVideoConfig();
  const s = pop(local, fps, at);
  return (
    <div style={{ width: 34, height: 34, borderRadius: 99, background: local >= at ? "#23C16B" : "rgba(20,30,60,0.12)", display: "flex", alignItems: "center", justifyContent: "center", color: "#fff", fontWeight: 900, fontSize: 20, transform: `scale(${local >= at ? 0.8 + 0.2 * s : 1})` }}>
      {local >= at ? "✓" : ""}
    </div>
  );
};

// ── stations ─────────────────────────────────────────────────────────────────

const Everything: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const logo = pop(local, fps, 6);
  const breathe = 1 + 0.025 * Math.sin(local / 22);
  const minis = [
    { t: "Grades", v: "93.5", c: COLORS.emerald, x: -520, y: -140 },
    { t: "Schedule", v: "08:00", c: COLORS.sky, x: 520, y: -160 },
    { t: "NOVA", v: "✦", c: "#8B5CF6", x: -600, y: 150 },
    { t: "Practice", v: "✓", c: COLORS.gold, x: 600, y: 160 },
    { t: "Exams", v: "12", c: "#E36BAE", x: -300, y: 330 },
    { t: "Chat", v: "3", c: COLORS.indigoSoft, x: 300, y: 340 },
    { t: "Solutions", v: "16", c: COLORS.goldDeep, x: 0, y: -290 },
  ];
  return (
    <AbsoluteFill>
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <div style={{ transform: `scale(${logo * breathe})`, width: 190, height: 190, borderRadius: 48, background: `linear-gradient(150deg, ${COLORS.indigo}, ${COLORS.indigoDeep})`, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: `0 40px 90px -20px ${COLORS.indigo}bb` }}>
          <Img src={staticFile("brand/cm-icon.png")} style={{ width: 124, height: 124, objectFit: "contain" }} />
        </div>
        {minis.map((m, i) => {
          const s = spring({ frame: local - (12 + i * 3), fps, config: { damping: 12, mass: 0.6, stiffness: 220 } });
          const bobY = Math.sin(local / 24 + i * 1.7) * 11;
          const bobR = Math.sin(local / 38 + i) * 2.4;
          return (
            <div key={i} style={{ position: "absolute", transform: `translate(${m.x * s}px, ${m.y * s + bobY}px) scale(${Math.max(0.05, s)}) rotate(${(1 - s) * 20 - 2 + bobR}deg)`, opacity: Math.min(1, s * 1.4) }}>
              <div style={{ background: "#fff", borderRadius: 22, padding: "18px 26px", display: "flex", alignItems: "center", gap: 14, boxShadow: "0 30px 60px -22px rgba(0,0,10,0.6)" }}>
                <div style={{ width: 46, height: 46, borderRadius: 13, background: `linear-gradient(150deg, ${m.c}, ${m.c}bb)`, display: "flex", alignItems: "center", justifyContent: "center", color: "#fff", fontFamily: FONTS.body, fontWeight: 800, fontSize: 22 }}>{m.v}</div>
                <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 26, color: "#22293d" }}>{m.t}</span>
              </div>
            </div>
          );
        })}
      </AbsoluteFill>
      <div style={{ position: "absolute", top: "8%", left: 0, right: 0, display: "flex", justifyContent: "center" }}>
        <WordPop text="Now you have |everything." offsets={[8, 16, 24, 34]} size={78} color="#F2F5FF" highlight="#9DBBFF" />
      </div>
    </AbsoluteFill>
  );
};

const Nova: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const TEXT = "Explain integrals step by step";
  const pillIn = pop(local, fps, A + 2);
  const sent = pop(local, fps, A + 70);
  // wheel-scroll ticks as the answer grows
  const shift = -(spring({ frame: local - (A + 140), fps, config: { damping: 15, stiffness: 130 } }) * 60 + spring({ frame: local - (A + 180), fps, config: { damping: 15, stiffness: 130 } }) * 70);
  const steps = [
    { at: A + 104, head: "What is an Integral?" },
    { at: A + 118, mono: "∫ f(x) dx = F(x) + C" },
    { at: A + 132, w: 460, h: 15 },
    { at: A + 148, chip: "Step 1 — Find the antiderivative" },
    { at: A + 164, mono: "x³/3 + C" },
    { at: A + 180, done: "Solution ✓" },
  ];
  return (
    <AbsoluteFill>
      <Spot keys={[{ at: A + 2, x: 0, y: -150, r: 560 }, { at: A + 96, x: 0, y: 60, r: 600 }]} />
      <div style={{ position: "absolute", left: "50%", top: "46%", width: 720, transform: `translate(-50%,-50%) translateY(${shift + Math.sin(local / 34) * 4}px)` }}>
        <div style={{ transform: `scale(${pillIn})`, opacity: pillIn, borderRadius: 999, padding: "20px 15px 20px 28px", background: "linear-gradient(135deg, rgba(255,255,255,0.16), rgba(255,255,255,0.07))", border: "1.5px solid rgba(255,255,255,0.24)", boxShadow: "inset 0 1.5px 0 rgba(255,255,255,0.35), 0 34px 80px -28px rgba(0,0,0,0.7)", backdropFilter: "blur(18px)", WebkitBackdropFilter: "blur(18px)", display: "flex", alignItems: "center" }}>
          <div style={{ flex: 1, fontFamily: FONTS.body, fontWeight: 600, fontSize: 32, color: "#F2F5FF", whiteSpace: "nowrap", overflow: "hidden" }}>
            <TypeOn text={TEXT} start={A + 8} cps={34} caret={local < A + 80} />
          </div>
          <div style={{ width: 50, height: 50, borderRadius: 99, background: `linear-gradient(140deg, ${COLORS.sky}, ${COLORS.indigo})`, display: "flex", alignItems: "center", justifyContent: "center", color: "#fff", fontWeight: 800, fontSize: 23, transform: `scale(${1 + 0.2 * sent})`, boxShadow: `0 0 ${24 * sent}px ${COLORS.sky}` }}>↑</div>
        </div>
        {local >= A + 80 ? (
          <div style={{ display: "flex", justifyContent: "flex-end", marginTop: 18 }}>
            <div style={{ transform: `scale(${pop(local, fps, A + 80)})`, transformOrigin: "right", background: `linear-gradient(140deg, ${COLORS.indigo}, ${COLORS.indigoSoft})`, color: "#fff", fontFamily: FONTS.body, fontWeight: 600, fontSize: 23, padding: "12px 20px", borderRadius: "22px 22px 6px 22px", boxShadow: "0 20px 44px -16px rgba(34,48,200,0.6)" }}>{TEXT}</div>
          </div>
        ) : null}
        {local >= A + 92 ? (
          <Panel at={A + 92} local={local} seed={2} style={{ marginTop: 18, padding: "24px 28px" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 14 }}>
              <span style={{ color: "#8B5CF6", fontSize: 25, transform: `rotate(${Math.sin(local / 18) * 12}deg)`, display: "inline-block" }}>✦</span>
              <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 19, letterSpacing: 3, color: "#8B5CF6" }}>NOVA</span>
            </div>
            {steps.map((st, i) => {
              if (local < st.at) return null;
              const s = pop(local, fps, st.at);
              const base = { transform: `translateY(${(1 - s) * 18}px)`, opacity: Math.min(1, s * 1.4), marginBottom: 12 } as React.CSSProperties;
              if (st.head) return <div key={i} style={{ ...base, fontFamily: FONTS.display, fontWeight: 800, fontSize: 29, color: "#161c30" }}>{st.head}</div>;
              if (st.mono) return <div key={i} style={{ ...base, fontFamily: FONTS.mono, fontWeight: 600, fontSize: 26, color: COLORS.indigo, background: "#EFF4FF", borderRadius: 12, padding: "10px 16px", display: "inline-block" }}>{st.mono}</div>;
              if (st.chip) return <div key={i} style={{ ...base, fontFamily: FONTS.body, fontWeight: 700, fontSize: 22, color: "#3d4663", background: "rgba(20,30,60,0.06)", borderRadius: 999, padding: "10px 18px", display: "inline-block" }}>{st.chip}</div>;
              if (st.done) return <div key={i} style={{ ...base, fontFamily: FONTS.body, fontWeight: 800, fontSize: 24, color: "#0E9E54", background: "#E7F9EF", borderRadius: 12, padding: "12px 18px", display: "inline-block" }}>{st.done}</div>;
              return <div key={i} style={{ ...base, width: st.w, height: st.h, borderRadius: 8, background: "rgba(20,30,60,0.08)" }} />;
            })}
          </Panel>
        ) : null}
      </div>
      <GlassDock words={["Ask", "NOVA", "anything"]} at={[A + 18, A + 32, A + 46]} accent={COLORS.sky} />
    </AbsoluteFill>
  );
};

const Practice: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opts = ["x = 4", "x = 6", "x = 18", "x = 3"];
  const TAP = A + 52;
  return (
    <AbsoluteFill>
      <Spot keys={[{ at: A + 2, x: 0, y: -60, r: 560 }, { at: TAP - 8, x: 20, y: 20, r: 430 }]} />
      <div style={{ position: "absolute", left: "50%", top: "45%", width: 660, transform: "translate(-50%,-50%)" }}>
        <Panel at={A + 2} local={local} seed={1} style={{ padding: "24px 30px" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
            <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 18, letterSpacing: 2, color: COLORS.goldDeep, background: "#FFF4DC", padding: "6px 14px", borderRadius: 999 }}>ALGEBRA</span>
            <Bar at={A + 8} local={local} frac={local >= TAP + 8 ? 1 : 6 / 7} color={COLORS.gold} w={200} />
          </div>
          <div style={{ fontFamily: FONTS.display, fontWeight: 800, fontSize: 34, color: "#161c30", marginBottom: 16 }}>Solve: 3x − 7 = 11</div>
          {opts.map((o, i) => {
            const s = pop(local, fps, A + 14 + i * 5);
            const isRight = i === 1;
            const green = isRight && local >= TAP + 4;
            const dim = !isRight && local >= TAP + 4;
            return (
              <div key={i} style={{ position: "relative", transform: `translateY(${(1 - s) * 22}px) scale(${isRight && local >= TAP - 3 && local < TAP + 5 ? 0.96 : 1})`, opacity: Math.min(1, s * 1.4) * (dim ? 0.4 : 1), background: green ? "#23C16B" : "rgba(20,30,60,0.06)", color: green ? "#fff" : "#2b3247", borderRadius: 999, padding: "14px 22px", fontFamily: FONTS.body, fontWeight: 700, fontSize: 26, marginBottom: 10, display: "flex", justifyContent: "space-between" }}>
                {o}
                {green ? <span>✓</span> : null}
              </div>
            );
          })}
        </Panel>
        <div style={{ display: "flex", justifyContent: "center", marginTop: 16 }}>
          <Chip at={TAP + 16} local={local} color="#7CFFB8">Correct! +10 XP · 7-day streak</Chip>
        </div>
      </div>
      <Pointer waypoints={[{ at: A + 30, x: 430, y: 330 }, { at: A + 40, x: 60, y: -8 }]} clicks={[TAP]} />
      <GlassDock words={["Learn", "by", "doing"]} at={[A + 16, A + 28, A + 40]} accent={COLORS.gold} />
    </AbsoluteFill>
  );
};

const Grades: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const n = interpolate(local, [A + 6, A + 46], [0, 93.5], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const rows = [
    { t: "Mathematics", v: 100, c: COLORS.emerald, at: A + 20 },
    { t: "Physics", v: 99, c: COLORS.sky, at: A + 30 },
    { t: "English", v: 95, c: COLORS.gold, at: A + 40 },
  ];
  return (
    <AbsoluteFill>
      <Spot keys={[{ at: A + 2, x: 0, y: -110, r: 520 }, { at: A + 22, x: 0, y: 40, r: 560 }]} />
      <div style={{ position: "absolute", left: "50%", top: "45%", width: 640, transform: "translate(-50%,-50%)" }}>
        <Panel at={A + 2} local={local} seed={3} style={{ padding: "28px 32px" }}>
          <div style={{ fontFamily: FONTS.display, fontWeight: 800, fontSize: 80, color: "#161c30", letterSpacing: -2, fontVariantNumeric: "tabular-nums", lineHeight: 1 }}>
            {n.toFixed(1)}<span style={{ fontSize: 32, opacity: 0.45 }}> /100</span>
          </div>
          <div style={{ height: 1.5, background: "rgba(20,30,60,0.1)", margin: "18px 0" }} />
          {rows.map((r, i) => {
            const s = pop(local, fps, r.at);
            const val = Math.round(interpolate(local, [r.at, r.at + 26], [0, r.v], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }));
            if (local < r.at - 2) return null;
            return (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: 18, marginBottom: 15, transform: `translateY(${(1 - s) * 20}px)`, opacity: Math.min(1, s * 1.4) }}>
                <span style={{ fontFamily: FONTS.body, fontWeight: 700, fontSize: 25, color: "#2b3247", width: 185 }}>{r.t}</span>
                <Bar at={r.at + 3} local={local} frac={r.v / 100} color={r.c} w={250} />
                <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 25, color: r.c, fontVariantNumeric: "tabular-nums", width: 66, textAlign: "right" }}>{val}</span>
              </div>
            );
          })}
        </Panel>
        <div style={{ display: "flex", gap: 14, justifyContent: "center", marginTop: 16 }}>
          <Chip at={A + 62} local={local} color="#7CFFB8">▲ Top subject · Mathematics</Chip>
          <Chip at={A + 76} local={local}>Published just now</Chip>
        </div>
      </div>
      <GlassDock words={["Grades", "go", "live"]} at={[A + 16, A + 28, A + 40]} accent={COLORS.emerald} />
    </AbsoluteFill>
  );
};

const Schedule: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const rows = [
    { time: "08:00", t: "Mathematics", sub: "Room 4 · Period 1", c: COLORS.sky, at: A + 6 },
    { time: "08:45", t: "Physics", sub: "Lab 2 · Period 2", c: "#8B5CF6", at: A + 16 },
    { time: "10:15", t: "Chemistry", sub: "Room 9 · Period 3", c: COLORS.emerald, at: A + 26 },
  ];
  const line = interpolate(local, [A + 8, A + 58], [0, 100], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  return (
    <AbsoluteFill>
      <Spot keys={[{ at: A + 2, x: 0, y: -80, r: 520 }, { at: A + 40, x: 0, y: -140, r: 460 }]} />
      <div style={{ position: "absolute", left: "50%", top: "44%", width: 640, transform: "translate(-50%,-50%)" }}>
        <div style={{ position: "absolute", left: 118, top: 10, bottom: 10, width: 3, background: "rgba(255,255,255,0.12)", borderRadius: 99 }}>
          <div style={{ width: "100%", height: `${line}%`, background: `linear-gradient(180deg, ${COLORS.sky}, ${COLORS.indigoSoft})`, borderRadius: 99, boxShadow: `0 0 16px ${COLORS.sky}` }} />
        </div>
        {rows.map((r, i) => {
          const s = pop(local, fps, r.at);
          if (local < r.at - 2) return null;
          const bob = Math.sin(local / 30 + i * 2) * 4;
          return (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: 26, marginBottom: 20, transform: `translateX(${(1 - s) * -60}px) translateY(${bob}px)`, opacity: Math.min(1, s * 1.4) }}>
              <span style={{ fontFamily: FONTS.mono, fontWeight: 700, fontSize: 26, color: "#9DBBFF", width: 92 }}>{r.time}</span>
              <div style={{ width: 18, height: 18, borderRadius: 99, background: r.c, boxShadow: `0 0 18px ${r.c}`, flexShrink: 0, marginLeft: -4, transform: `scale(${1 + 0.15 * Math.sin(local / 12 + i)})` }} />
              <div style={{ flex: 1, background: "#fff", borderRadius: 20, padding: "14px 22px", boxShadow: "0 26px 60px -22px rgba(0,0,10,0.6)", position: "relative" }}>
                <div style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 26, color: "#161c30" }}>{r.t}</div>
                <div style={{ fontFamily: FONTS.body, fontWeight: 500, fontSize: 19, color: "#7a86a8" }}>{r.sub}</div>
                {i === 0 ? (
                  <div style={{ position: "absolute", right: 16, top: -16, opacity: pop(local, fps, A + 42), transform: `scale(${1 + 0.04 * Math.sin(local / 11)})` }}>
                    <LiquidPanel pad="6px 16px" style={{ background: `linear-gradient(140deg, ${COLORS.sky}, ${COLORS.indigo})` }}>
                      <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 18, color: "#fff" }}>Next up</span>
                    </LiquidPanel>
                  </div>
                ) : null}
              </div>
            </div>
          );
        })}
      </div>
      <GlassDock words={["The week", "at a glance"]} at={[A + 16, A + 34]} accent={COLORS.sky} />
    </AbsoluteFill>
  );
};

const Exam: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const TAP = A + 50;
  const press = 1 - 0.06 * Math.sin(Math.PI * interpolate(local, [TAP - 4, TAP + 10], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }));
  const plan = [
    { t: "Review integrals with NOVA", at: A + 74 },
    { t: "10 practice questions", at: A + 90 },
    { t: "Past exam · Question 3", at: A + 106 },
  ];
  return (
    <AbsoluteFill>
      <Spot keys={[{ at: A + 2, x: 0, y: -80, r: 520 }, { at: TAP - 8, x: 0, y: -10, r: 420 }, { at: A + 70, x: 0, y: 80, r: 520 }]} />
      <div style={{ position: "absolute", left: "50%", top: "44%", width: 620, transform: "translate(-50%,-50%)" }}>
        <Panel at={A + 2} local={local} seed={4} style={{ overflow: "hidden" }}>
          <div style={{ background: "linear-gradient(140deg, #B583FF, #8B5CF6)", padding: "16px 26px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <span style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 25, color: "#fff" }}>Mid-term · Mathematics</span>
            <span style={{ fontFamily: FONTS.body, fontWeight: 700, fontSize: 19, color: "rgba(255,255,255,0.85)", transform: `scale(${1 + 0.05 * Math.sin(local / 10)})` }}>in 2 days</span>
          </div>
          <div style={{ padding: "20px 26px" }}>
            <div style={{ position: "relative", transform: `scale(${press})`, borderRadius: 999, padding: "16px 0", textAlign: "center", background: `linear-gradient(140deg, ${COLORS.indigo}, ${COLORS.sky})`, color: "#fff", fontFamily: FONTS.body, fontWeight: 800, fontSize: 28, boxShadow: `0 24px 60px -20px ${COLORS.indigo}, 0 0 ${interpolate(local, [TAP, TAP + 16], [0, 46], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })}px ${COLORS.sky}77` }}>
              ✦ Study with NOVA
            </div>
            {plan.map((p, i) => {
              if (local < p.at - 4) return null;
              const s = pop(local, fps, p.at - 4);
              return (
                <div key={i} style={{ display: "flex", alignItems: "center", gap: 14, marginTop: i === 0 ? 20 : 12, transform: `translateY(${(1 - s) * 16}px)`, opacity: Math.min(1, s * 1.4) }}>
                  <Tick at={p.at + 6} local={local} />
                  <span style={{ fontFamily: FONTS.body, fontWeight: 600, fontSize: 23, color: "#2b3247" }}>{p.t}</span>
                </div>
              );
            })}
          </div>
        </Panel>
      </div>
      <Pointer waypoints={[{ at: A + 28, x: 400, y: 300 }, { at: A + 38, x: 0, y: -12 }]} clicks={[TAP]} />
      <GlassDock words={["Every exam", "a study plan"]} at={[A + 16, A + 36]} accent="#B583FF" />
    </AbsoluteFill>
  );
};

const Solutions: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const books = [
    { t: "Mathematics", n: "4 books", c: COLORS.sky, at: A + 44 },
    { t: "Chemistry", n: "4 books", c: COLORS.emerald, at: A + 51 },
    { t: "Physics", n: "1 book", c: "#8B5CF6", at: A + 58 },
    { t: "Hebrew", n: "2 books", c: COLORS.gold, at: A + 65 },
  ];
  const CLICK = A + 84;
  return (
    <AbsoluteFill>
      <Spot keys={[{ at: A + 2, x: 0, y: -140, r: 500 }, { at: A + 44, x: 0, y: 40, r: 560 }, { at: CLICK - 8, x: -160, y: 30, r: 420 }]} />
      <div style={{ position: "absolute", left: "50%", top: "44%", width: 680, transform: "translate(-50%,-50%)" }}>
        <div style={{ opacity: pop(local, fps, A + 2), transform: `translateY(${Math.sin(local / 32) * 4}px)`, borderRadius: 999, padding: "16px 26px", background: "linear-gradient(135deg, rgba(255,255,255,0.15), rgba(255,255,255,0.06))", border: "1.5px solid rgba(255,255,255,0.22)", backdropFilter: "blur(16px)", WebkitBackdropFilter: "blur(16px)", display: "flex", alignItems: "center", gap: 14, marginBottom: 20 }}>
          <span style={{ fontSize: 26, opacity: 0.7, color: "#fff" }}>⌕</span>
          <span style={{ fontFamily: FONTS.body, fontWeight: 600, fontSize: 27, color: "#F2F5FF" }}>
            <TypeOn text="algebra · book 2 · page 42" start={A + 6} cps={32} caret={local < A + 60} />
          </span>
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 15 }}>
          {books.map((b, i) => {
            const s = pop(local, fps, b.at);
            if (local < b.at - 2) return null;
            const lift = i === 0 ? spring({ frame: local - CLICK, fps, config: { damping: 14, stiffness: 200 } }) : 0;
            return (
              <div key={i} style={{ transform: `translateY(${(1 - s) * 26 + Math.sin(local / 28 + i * 2) * 4 - lift * 10}px) scale(${0.9 + 0.1 * s + lift * 0.04})`, opacity: Math.min(1, s * 1.4), background: "#fff", borderRadius: 20, padding: "16px 20px", display: "flex", alignItems: "center", gap: 15, boxShadow: lift > 0.1 ? `0 30px 70px -20px ${b.c}aa` : "0 26px 60px -22px rgba(0,0,10,0.6)" }}>
                <div style={{ width: 42, height: 56, borderRadius: 8, background: `linear-gradient(160deg, ${b.c}, ${b.c}99)`, boxShadow: "inset -6px 0 0 rgba(0,0,0,0.15)" }} />
                <div>
                  <div style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 23, color: "#161c30" }}>{b.t}</div>
                  <div style={{ fontFamily: FONTS.body, fontWeight: 600, fontSize: 18, color: "#7a86a8" }}>{b.n}</div>
                </div>
              </div>
            );
          })}
        </div>
        <div style={{ display: "flex", justifyContent: "center", marginTop: 18 }}>
          <Chip at={CLICK + 14} local={local} color="#7CFFB8">Q3 · Worked solution found ✓</Chip>
        </div>
      </div>
      <Pointer waypoints={[{ at: A + 62, x: 400, y: 320 }, { at: A + 72, x: -170, y: 40 }]} clicks={[CLICK]} />
      <GlassDock words={["A library", "of answers"]} at={[A + 16, A + 36]} accent={COLORS.gold} />
    </AbsoluteFill>
  );
};

const Teacher: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const names = ["Amir K.", "Sarah L.", "Dana M.", "Yousef H."];
  return (
    <AbsoluteFill>
      <Spot keys={[{ at: A + 2, x: 0, y: -60, r: 540 }, { at: A + 44, x: 0, y: 20, r: 480 }]} />
      <div style={{ position: "absolute", left: "50%", top: "44%", width: 620, transform: "translate(-50%,-50%)" }}>
        <Panel at={A + 2} local={local} seed={5} style={{ padding: "22px 26px" }}>
          <div style={{ display: "flex", gap: 8, background: "rgba(20,30,60,0.06)", borderRadius: 999, padding: 7, marginBottom: 16, fontFamily: FONTS.body, fontWeight: 800, fontSize: 19 }}>
            <div style={{ flex: 1, textAlign: "center", padding: "8px 0", borderRadius: 999, background: "#23C16B", color: "#fff", boxShadow: "0 4px 14px rgba(35,193,107,0.5)" }}>Present</div>
            <div style={{ flex: 1, textAlign: "center", padding: "8px 0", color: "#7a86a8" }}>Absent</div>
            <div style={{ flex: 1, textAlign: "center", padding: "8px 0", color: "#7a86a8" }}>Late</div>
          </div>
          {names.map((n, i) => {
            const at = A + 10 + i * 6;
            const checkAt = A + 44 + i * 9;
            const s = pop(local, fps, at);
            if (local < at - 2) return null;
            return (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: 16, marginBottom: 12, transform: `translateX(${(1 - s) * 50}px)`, opacity: Math.min(1, s * 1.4) }}>
                <div style={{ width: 44, height: 44, borderRadius: 99, background: `hsl(${210 + i * 34}, 60%, 62%)`, display: "flex", alignItems: "center", justifyContent: "center", color: "#fff", fontFamily: FONTS.body, fontWeight: 800, fontSize: 20 }}>{n[0]}</div>
                <span style={{ flex: 1, fontFamily: FONTS.body, fontWeight: 700, fontSize: 24, color: "#2b3247" }}>{n}</span>
                <Tick at={checkAt} local={local} />
              </div>
            );
          })}
        </Panel>
        <div style={{ display: "flex", gap: 14, justifyContent: "center", marginTop: 16 }}>
          <Chip at={A + 86} local={local} color="#7CFFB8">24/24 · Saved instantly</Chip>
          <Chip at={A + 100} local={local}>7 students · 2 teachers · 2 classes</Chip>
        </div>
      </div>
      <GlassDock words={["Every role", "in sync"]} at={[A + 16, A + 36]} accent={COLORS.emerald} />
    </AbsoluteFill>
  );
};

// ── the traveling world ──────────────────────────────────────────────────────

export const GlassTour: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const camAt = (f: number) => {
    let x = 0, y = 0;
    for (let i = 1; i < KEYS.length; i++) {
      const s = spring({ frame: f - TOUR[KEYS[i]], fps, config: { damping: 18, mass: 0.85, stiffness: 130 } });
      const a = posOf(i - 1), b = posOf(i);
      x += (b.x - a.x) * s;
      y += (b.y - a.y) * s;
    }
    return { x, y };
  };
  const cam = camAt(frame);
  const prev = camAt(frame - 1);
  const v = Math.hypot(cam.x - prev.x, cam.y - prev.y);
  const blur = Math.min(14, v * 0.13);
  const dip = 1 - Math.min(0.055, v * 0.001);

  const stations: Array<[keyof typeof TOUR, React.ReactNode]> = [
    ["everything", <Everything key="s0" />],
    ["nova", <Nova key="s1" />],
    ["practice", <Practice key="s2" />],
    ["grades", <Grades key="s3" />],
    ["schedule", <Schedule key="s4" />],
    ["exam", <Exam key="s5" />],
    ["solutions", <Solutions key="s6" />],
    ["teacher", <Teacher key="s7" />],
    ["roles", <RolesFan key="s8" />],
    ["cta", <CTALight key="s9" />],
  ];

  return (
    <AbsoluteFill>
      <GlassBG camX={cam.x} camY={cam.y} />
      <AbsoluteFill style={{ transform: `scale(${dip})`, filter: blur > 0.6 ? `blur(${blur}px)` : undefined }}>
        <div style={{ position: "absolute", inset: 0, transform: `translate(${-(posOf(0).x + cam.x)}px, ${-(posOf(0).y + cam.y)}px)` }}>
          {stations.map(([k, node], i) => {
            const start = TOUR[k];
            const next = i + 1 < KEYS.length ? TOUR[KEYS[i + 1]] : TOUR.end;
            const p = posOf(i);
            return (
              <Sequence key={k} from={Math.max(0, start - A)} durationInFrames={next - start + A + 70}>
                <div style={{ position: "absolute", left: p.x, top: p.y, width: 1920, height: 1080 }}>{node}</div>
              </Sequence>
            );
          })}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
