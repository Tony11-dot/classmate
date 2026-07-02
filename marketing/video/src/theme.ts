/**
 * Central design tokens for the ClassMate demo video (v2).
 * Keep every magic colour / timing number here so scenes stay declarative.
 */

export const FPS = 30;
export const WIDTH = 1920;
export const HEIGHT = 1080;

/** Native resolution of the app screenshots in public/screens. */
export const SHOT = { w: 1206, h: 2622 } as const;

/** Master switch for the background music hook (see README "Music").
 *  Off until a track is dropped at public/music/hook.mp3 (the old one was
 *  removed — re-enable once the new score/bed is in place). */
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

/**
 * App screenshots, addressed via staticFile('screens/<file>').
 * The *-before/-after pairs are real captures used for "someone using it"
 * morphs (tap → state change). The bare names are the original hi-res shots.
 */
export const SCREENS = {
  // hi-res originals
  nova: "screens/nova.png",
  schedule: "screens/schedule.png",
  classroom: "screens/classroom.png",
  grades: "screens/grades.png",
  practice: "screens/practice.png",
  solutions: "screens/solutions.png",
  menu: "screens/menu.png",
  // real before/after interaction pairs
  attendanceBefore: "screens/attendance-before.png",
  attendanceAfter: "screens/attendance-after.png",
  novaBefore: "screens/nova-before.png",
  novaAfter: "screens/nova-after.png",
  practiceBefore: "screens/practice-before.png",
  practiceAfter: "screens/practice-after.png",
  classroomBefore: "screens/classroom-before.png",
  classroomAssignments: "screens/classroom-assignments.png",
  scheduleBefore: "screens/schedule-before.png",
  scheduleDetail: "screens/schedule-detail.png",
  gradesScrolled: "screens/grades-scrolled.png",
  solutionsBooks: "screens/solutions-books.png",
} as const;

/**
 * Scene timeline. Durations are the *base* length of each scene; adjacent
 * scenes overlap by TRANSITION frames inside the TransitionSeries, so the
 * composition's true length is sum(scenes) - (n-1) * TRANSITION.
 */
export const TRANSITION = 11;

export const SCENES = {
  coldOpen: 100,
  title: 80,
  attendance: 150,
  nova: 165,
  classroom: 150,
  practice: 170,
  gradesInsights: 150,
  montage: 200,
  cta: 150,
} as const;

const sceneList = Object.values(SCENES);
export const TOTAL_FRAMES =
  sceneList.reduce((a, b) => a + b, 0) - (sceneList.length - 1) * TRANSITION;
// 1315 - 8*11 = 1227 frames = 40.9s @ 30fps
