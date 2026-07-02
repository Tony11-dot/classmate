/**
 * Central design tokens for the ClassMate demo video (v2).
 * Keep every magic colour / timing number here so scenes stay declarative.
 */

export const FPS = 60;
export const WIDTH = 1920;
export const HEIGHT = 1080;

/** Native resolution of the app screenshots in public/screens. */
export const SHOT = { w: 1206, h: 2622 } as const;

/** Master switch for the background music hook (see README "Music").
 *  Off until a track is dropped at public/music/hook.mp3 (the old one was
 *  removed — re-enable once the new score/bed is in place). */
export const MUSIC_ENABLED = false;
/** Path under public/ for the track when MUSIC_ENABLED is true. */
export const MUSIC_SRC = "music/bed.mp3";

export const COLORS = {
  // Brand
  indigo: "#2230C8",
  indigoDeep: "#161E7A",
  indigoSoft: "#3B49E0",
  // Sky tints
  sky: "#5B8DEF",
  skyLight: "#BBD4FF",
  skyMist: "#EAF2FF",
  // Warm accents (used for the color grade + graph) — emerald + gold
  gold: "#F4B23E",
  goldDeep: "#E08A1E",
  green: "#23C16B",
  greenDeep: "#0E9E54",
  emerald: "#0FB97D",
  // Neutrals
  ink: "#0B1020",
  paper: "#F7F9FF",
  white: "#FFFFFF",
  muted: "#9AA6C4",
} as const;

/** Reusable brand gradient (indigo → sky). */
export const BRAND_GRADIENT = `linear-gradient(135deg, ${COLORS.indigo} 0%, ${COLORS.sky} 100%)`;
/** Warm accent gradient (gold → emerald) used by the attendance graph. */
export const WARM_GRADIENT = `linear-gradient(90deg, ${COLORS.gold} 0%, ${COLORS.emerald} 100%)`;

export const FONTS = {
  display: "'Bricolage Grotesque', system-ui, sans-serif",
  body: "'Hanken Grotesk', system-ui, sans-serif",
  mono: "'JetBrains Mono', ui-monospace, monospace",
} as const;

/**
 * App screenshots, addressed via staticFile('screens/<file>').
 * The *-before/-after pairs are real captures used for "someone using it"
 * morphs (tap → state change). The bare names are the original hi-res shots.
 */
export const SCREENS = {
  // Fresh 2026 captures (1206×2622). nova1→nova2 are one conversation at two
  // scroll positions — stacked, they read as a single continuous scroll.
  nova1: "screens/nova1.PNG",
  nova2: "screens/nova2.PNG",
  practice: "screens/practice.png",
  grades: "screens/grades.png",
  schedule: "screens/schedule.png",
  exam: "screens/exam.png",
  solutions: "screens/solutions.png",
  attendance: "screens/attendance.png",
  classroom: "screens/classroom1.png",
  classroom2: "screens/classroom2.png",
  admin: "screens/admin.png",
} as const;

/**
 * Scene timeline. Durations are the *base* length of each scene; adjacent
 * scenes overlap by TRANSITION frames inside the TransitionSeries, so the
 * composition's true length is sum(scenes) - (n-1) * TRANSITION.
 */
export const TRANSITION = 10;

/** v9 timeline @ 60fps — Act 1 (ref2-style problem) → Act 2 (ref4-style product). */
export const SCENES = {
  act1: 1260,
  act2: 1500,
} as const;

const sceneList = Object.values(SCENES);
export const TOTAL_FRAMES =
  sceneList.reduce((a, b) => a + b, 0) - (sceneList.length - 1) * TRANSITION;
// 2760 - 10 = 2750 frames ≈ 45.8s @ 60fps
