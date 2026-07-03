import React from "react";
import { AbsoluteFill, Img, interpolate, Sequence, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS } from "../theme";
import { AppTile, APPS } from "../components/AppTile";
import { WordPop } from "../components/WordPop";
import { HeroPhone } from "../components/HeroPhone";
import { motionBlur, pop } from "../anim";

/**
 * ACT 1 — the problem, told in the light icon-led style of ref2:
 * soft warm-grey world, one big element per beat, zoom-through hand-offs.
 *
 *  b1 "These days"        small intro words
 *  b2 timetable + word    full-bleed grid, "Everywhere."
 *  b3 note icon           homework note pops, badge
 *  b4 line → icon         blue thread draws into the classroom icon
 *  b5 scattered cards     six school cards floating in depth
 *  b6 "progress slows"    kinetic, blue word
 *  b7 DARK                "clarity disappears" glow + scanlines
 *  b8 phone + orbit       school apps around a tilted phone
 *  b9 pastel pills        three notification pills stack
 *  b10 logo + tagline     white CM mark on indigo, "School. Organised."
 */
export const ABEATS = {
  these: 0,
  everywhere: 70,
  note: 185,
  thread: 270,
  cards: 355,
  slows: 485,
  dark: 585,
  phone: 715,
  pills: 835,
  logo: 940,
  end: 1070,
} as const;

const OVERLAP = 10;
const BG = "#F4F3F6";

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

/** Soft warm study — barely-there gradient + drifting soft shadows (always moving). */
const Soft: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill style={{ background: BG }}>
      <AbsoluteFill
        style={{
          background: `radial-gradient(46% 52% at ${24 + Math.sin(f / 70) * 4}% 28%, #FFE9F0aa 0%, transparent 62%),
                       radial-gradient(50% 56% at ${78 - Math.sin(f / 84) * 4}% 76%, #E3ECFFbb 0%, transparent 64%)`,
        }}
      />
      <AbsoluteFill style={{ background: "radial-gradient(75% 75% at 50% 45%, transparent 60%, rgba(120,110,140,0.10) 100%)" }} />
    </AbsoluteFill>
  );
};

// ── beats ────────────────────────────────────────────────────────────────────

const Everywhere: React.FC = () => {
  const local = useCurrentFrame();
  const cells = 7 * 4;
  const subj = ["Math", "Physics", "Hebrew", "English", "Chem", "Bio", "CS"];
  const cols = ["#DCE8FF", "#FFE3EC", "#E2F6E9", "#FFF3D6", "#EFE3FF", "#DFF3FA", "#FFE9DC"];
  const drift = local * 0.6;
  return (
    <AbsoluteFill style={{ background: BG }}>
      <div style={{ position: "absolute", inset: "-12% -6%", display: "grid", gridTemplateColumns: "repeat(7,1fr)", gap: 12, transform: `translateY(${-drift * 0.4}px) rotate(-3deg) scale(1.08)` }}>
        {Array.from({ length: cells }, (_, i) => (
          <div key={i} style={{ height: 130, borderRadius: 16, background: cols[i % 7], padding: "12px 14px", fontFamily: FONTS.body, fontWeight: 700, fontSize: 19, color: "#3a4157", opacity: 0.9 }}>
            {subj[(i * 3) % 7]}
            <div style={{ fontSize: 14, opacity: 0.55, fontWeight: 600 }}>{`0${(i % 5) + 1}:0${(i % 2) * 3}0 · Rm ${(i % 9) + 1}`}</div>
          </div>
        ))}
      </div>
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <WordPop text="Everywhere." start={8} step={10} size={132} color="#171c2e" />
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

const NoteIcon: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = pop(local, fps, 6);
  const bob = Math.sin(local / 26) * 8;
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Soft />
      <div style={{ position: "absolute", transform: `scale(${s}) translateY(${bob}px)` }}>
        <div style={{ width: 210, height: 210, borderRadius: 46, background: "#fff", boxShadow: "0 46px 90px -26px rgba(80,80,110,0.45)", overflow: "hidden" }}>
          <div style={{ height: 58, background: "linear-gradient(180deg,#FFD75E,#F8C63C)" }} />
          <div style={{ padding: "20px 24px", display: "flex", flexDirection: "column", gap: 14 }}>
            {[150, 110, 130].map((w, i) => (
              <div key={i} style={{ width: interpolate(pop(local, fps, 22 + i * 9), [0, 1], [0, w]), height: 11, borderRadius: 8, background: "rgba(40,50,80,0.18)" }} />
            ))}
          </div>
        </div>
        <div style={{ position: "absolute", top: -12, right: -12, minWidth: 46, height: 46, borderRadius: 99, background: "#FF3B30", color: "#fff", fontFamily: FONTS.body, fontWeight: 800, fontSize: 24, display: "flex", alignItems: "center", justifyContent: "center", transform: `scale(${pop(local, fps, 30)})`, boxShadow: "0 10px 24px rgba(255,59,48,0.5)" }}>7</div>
      </div>
    </AbsoluteFill>
  );
};

const Thread: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = pop(local, fps, 4);
  const draw = interpolate(local, [8, 54], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Soft />
      <svg width="100%" height="100%" style={{ position: "absolute", inset: 0 }}>
        <path d="M 1750 180 C 1400 120, 1200 420, 1010 480" stroke="#2f7bff" strokeWidth={7} fill="none" strokeLinecap="round" strokeDasharray={1200} strokeDashoffset={1200 * (1 - draw)} />
      </svg>
      <div style={{ position: "absolute", transform: `scale(${s}) translateY(${Math.sin(local / 26) * 8}px)` }}>
        <AppTile app={APPS.classroom} size={200} label={false} />
      </div>
    </AbsoluteFill>
  );
};

const ScatterCards: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const cards = [
    { t: "Grades", body: "93.5 /100", c: "#DCE8FF", x: -560, y: -210, z: 1, d: 6 },
    { t: "Schedule", body: "08:00 · Math", c: "#E2F6E9", x: 30, y: -260, z: 0.8, d: 11 },
    { t: "Group chat", body: "47 unread", c: "#FFE3EC", x: 580, y: -180, z: 1.1, d: 16 },
    { t: "Mid-term", body: "in 2 days", c: "#EFE3FF", x: -520, y: 190, z: 0.9, d: 21 },
    { t: "Solutions", body: "16 subjects", c: "#FFF3D6", x: 60, y: 250, z: 1.15, d: 26 },
    { t: "Announcement", body: "Trip Friday", c: "#DFF3FA", x: 590, y: 210, z: 0.85, d: 31 },
  ];
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Soft />
      {cards.map((c, i) => {
        const s = spring({ frame: local - c.d, fps, config: { damping: 13, mass: 0.7, stiffness: 200 } });
        const bob = Math.sin(local / 24 + i * 1.9) * 9;
        return (
          <div key={i} style={{ position: "absolute", transform: `translate(${c.x * s}px, ${c.y * s + bob}px) scale(${Math.max(0.05, s) * c.z}) rotate(${(1 - s) * 14 - 3 + Math.sin(local / 40 + i) * 2}deg)`, opacity: Math.min(1, s * 1.4), filter: c.z < 0.95 ? "blur(1.5px)" : undefined }}>
            <div style={{ width: 300, borderRadius: 20, background: "#fff", boxShadow: "0 36px 70px -24px rgba(80,80,110,0.4)", overflow: "hidden" }}>
              <div style={{ height: 76, background: c.c, padding: "16px 20px", fontFamily: FONTS.body, fontWeight: 800, fontSize: 24, color: "#2b3247" }}>{c.t}</div>
              <div style={{ padding: "14px 20px 18px", fontFamily: FONTS.body, fontWeight: 700, fontSize: 21, color: "#5a6480" }}>{c.body}</div>
            </div>
          </div>
        );
      })}
    </AbsoluteFill>
  );
};

const Slows: React.FC = () => (
  <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
    <Soft />
    <div style={{ position: "absolute", top: "38%" }}>
      <WordPop text="So..." start={4} step={8} size={54} color="#8a90a8" weight={700} />
    </div>
    <div style={{ position: "absolute", top: "47%" }}>
      <WordPop text="progress |slows" offsets={[20, 32]} size={120} color="#171c2e" highlight="#2f7bff" />
    </div>
  </AbsoluteFill>
);

const Dark: React.FC = () => {
  const local = useCurrentFrame();
  return (
    <AbsoluteFill style={{ background: "#050608" }}>
      <AbsoluteFill style={{ background: "repeating-linear-gradient(0deg, rgba(255,255,255,0.05) 0 1px, transparent 1px 5px)", opacity: 0.55 }} />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", transform: `scale(${1 + local * 0.0014})` }}>
        <div style={{ textShadow: "0 0 28px rgba(255,255,255,0.8), 0 0 80px rgba(160,180,255,0.45)" }}>
          <WordPop text="clarity disappears" start={6} step={10} size={96} color="#ffffff" />
        </div>
      </AbsoluteFill>
      <AbsoluteFill style={{ background: `radial-gradient(60% 60% at 50% 50%, transparent 40%, rgba(0,0,0,${0.35 + 0.1 * Math.sin(local / 22)}) 100%)` }} />
    </AbsoluteFill>
  );
};

const PhoneOrbit: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const inS = spring({ frame: local, fps, config: { damping: 15, mass: 0.8, stiffness: 160 } });
  const yIn = interpolate(inS, [0, 1], [700, 0]);
  const orbit = [
    { app: APPS.whatsapp, x: -430, y: -140, d: 14 },
    { app: APPS.zoom, x: 420, y: -170, d: 19 },
    { app: APPS.classroom, x: -470, y: 170, d: 24 },
    { app: APPS.chatgpt, x: 460, y: 160, d: 29 },
    { app: APPS.livetop, x: -20, y: -300, d: 34 },
  ];
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Soft />
      <div style={{ transform: `translateY(${yIn + Math.sin(local / 34) * 8}px) rotate(${interpolate(inS, [0, 1], [-12, -5])}deg)`, filter: motionBlur(Math.abs(yIn - interpolate(spring({ frame: local - 1, fps, config: { damping: 15, mass: 0.8, stiffness: 160 } }), [0, 1], [700, 0])), 0.04) > 0.5 ? "blur(3px)" : undefined }}>
        <HeroPhone src="" screenWidth={300} rim={COLORS.sky} reflection={false} screenContent={<Grid />} />
      </div>
      {orbit.map((o, i) => {
        const s = spring({ frame: local - o.d, fps, config: { damping: 11, mass: 0.6, stiffness: 210 } });
        const bob = Math.sin(local / 28 + i * 1.9) * 12;
        return (
          <div key={i} style={{ position: "absolute", transform: `translate(${o.x * s}px, ${o.y * s + bob}px) scale(${Math.max(0.03, s)}) rotate(${(1 - s) * 30 - 5}deg)`, opacity: Math.min(1, s * 1.4) }}>
            <AppTile app={o.app} size={112} label={false} />
          </div>
        );
      })}
    </AbsoluteFill>
  );
};

const Grid: React.FC = () => {
  const hues = ["#5B8DEF", "#F4B23E", "#23C16B", "#8B5CF6", "#EF6461", "#38BDF8", "#F59E0B", "#94A3B8"];
  return (
    <AbsoluteFill style={{ background: "linear-gradient(180deg,#EAF0FC,#DCE6F9)", padding: "16% 9% 9%" }}>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", gap: "10%" }}>
        {Array.from({ length: 20 }, (_, i) => (
          <div key={i} style={{ aspectRatio: "1", borderRadius: "24%", background: `linear-gradient(150deg, ${hues[i % 8]}cc, ${hues[(i + 3) % 8]}99)` }} />
        ))}
      </div>
    </AbsoluteFill>
  );
};

const Pills: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const pills = [
    { t: "Parent meeting", s: "Today at 8:00", bg: "#FFDDE6", ic: "#E8618C", d: 8 },
    { t: "Homework due", s: "Tomorrow, 23:59", bg: "#D9E6FF", ic: "#4A78E0", d: 22 },
    { t: "Grade posted", s: "Mathematics · 93.5", bg: "#DCF5E4", ic: "#2FA968", d: 36 },
  ];
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Soft />
      <div style={{ display: "flex", flexDirection: "column", gap: 18 }}>
        {pills.map((p, i) => {
          const s = spring({ frame: local - p.d, fps, config: { damping: 12, mass: 0.65, stiffness: 230 } });
          if (local < p.d - 2) return null;
          return (
            <div key={i} style={{ width: 560, transform: `translateY(${(1 - s) * -46 + Math.sin(local / 30 + i * 2) * 4}px) scale(${0.85 + 0.15 * s}) rotate(${(1 - s) * -3}deg)`, opacity: Math.min(1, s * 1.4), background: p.bg, borderRadius: 22, padding: "18px 24px", display: "flex", alignItems: "center", gap: 18, boxShadow: "0 26px 54px -20px rgba(80,80,110,0.45)" }}>
              <div style={{ width: 52, height: 52, borderRadius: 14, background: p.ic, opacity: 0.9, flexShrink: 0, display: "flex", alignItems: "center", justifyContent: "center", color: "#fff", fontWeight: 900, fontSize: 24, fontFamily: FONTS.body }}>{p.t[0]}</div>
              <div>
                <div style={{ fontFamily: FONTS.body, fontWeight: 800, fontSize: 26, color: "#33304a" }}>{p.t}</div>
                <div style={{ fontFamily: FONTS.body, fontWeight: 600, fontSize: 20, color: "#33304a", opacity: 0.55 }}>{p.s}</div>
              </div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

const Logo: React.FC = () => {
  const local = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = pop(local, fps, 6);
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Soft />
      <div style={{ display: "flex", alignItems: "center", gap: 30 }}>
        <div style={{ transform: `scale(${s})`, width: 150, height: 150, borderRadius: 38, background: `linear-gradient(150deg, ${COLORS.indigo}, ${COLORS.indigoDeep})`, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: `0 36px 80px -22px ${COLORS.indigo}99` }}>
          <Img src={staticFile("brand/icon_light.png")} style={{ width: 100, height: 100, objectFit: "contain" }} />
        </div>
        <WordPop text="School. |Organised." offsets={[26, 44]} size={84} color="#171c2e" highlight={COLORS.indigo} />
      </div>
    </AbsoluteFill>
  );
};

export const ActProblem: React.FC = () => (
  <AbsoluteFill style={{ background: BG }}>
    <Beat from={ABEATS.these} to={ABEATS.everywhere}>
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <Soft />
        <WordPop text="These days..." start={6} step={10} size={110} color="#171c2e" />
      </AbsoluteFill>
    </Beat>
    <Beat from={ABEATS.everywhere} to={ABEATS.note}><Everywhere /></Beat>
    <Beat from={ABEATS.note} to={ABEATS.thread}><NoteIcon /></Beat>
    <Beat from={ABEATS.thread} to={ABEATS.cards}><Thread /></Beat>
    <Beat from={ABEATS.cards} to={ABEATS.slows}><ScatterCards /></Beat>
    <Beat from={ABEATS.slows} to={ABEATS.dark}><Slows /></Beat>
    <Beat from={ABEATS.dark} to={ABEATS.phone}><Dark /></Beat>
    <Beat from={ABEATS.phone} to={ABEATS.pills}><PhoneOrbit /></Beat>
    <Beat from={ABEATS.pills} to={ABEATS.logo}><Pills /></Beat>
    <Beat from={ABEATS.logo} to={ABEATS.end}><Logo /></Beat>
  </AbsoluteFill>
);
