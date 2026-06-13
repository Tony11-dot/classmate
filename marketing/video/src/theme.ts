/**
 * Central design tokens for the ClassMate demo video (v2).
 * Keep every magic colour / timing number here so scenes stay declarative.
 */

export const FPS = 30;
export const WIDTH = 1920;
export const HEIGHT = 1080;

/** Native resolution of the app screenshots in public/screens. */
export const SHOT = { w: 1206, h: 2622 } as const;

/** Master switch for the background music hook (see README "Music"). */
export const MUSIC_ENABLED = false;
/** Path under public/ for the royalty-free track when MUSIC_ENABLED is true. */
export const MUSIC_SRC = "music/hook.mp3";

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

/** App screenshots, addressed via staticFile('screens/<file>'). */
export const SCREENS = {
  nova: "screens/nova.png",
  schedule: "screens/schedule.png",
  classroom: "screens/classroom.png",
  grades: "screens/grades.png",
  practice: "screens/practice.png",
  solutions: "screens/solutions.png",
  menu: "screens/menu.png",
} as const;

/**
 * Scene timeline. Durations are the *base* length of each scene; adjacent
 * scenes overlap by TRANSITION frames inside the TransitionSeries, so the
 * composition's true length is sum(scenes) - (n-1) * TRANSITION.
 */
export const TRANSITION = 18;

export const SCENES = {
  coldOpen: 210,
  promise: 160,
  nova: 360,
  classroom: 340,
  practice: 350,
  attnotify: 400,
  gradesInsights: 380,
  montage: 380,
  cta: 264,
} as const;

const sceneList = Object.values(SCENES);
export const TOTAL_FRAMES =
  sceneList.reduce((a, b) => a + b, 0) - (sceneList.length - 1) * TRANSITION;
// 2844 - 8*18 = 2700 frames = 90.0s @ 30fps
