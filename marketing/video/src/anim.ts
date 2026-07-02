import { spring } from "remotion";

/** Snappy pop-in spring (fast attack, slight overshoot). */
export const pop = (frame: number, fps: number, delay = 0) =>
  spring({ frame: frame - delay, fps, config: { damping: 13, mass: 0.6, stiffness: 240 } });

/** Softer settle spring for larger moves. */
export const glide = (frame: number, fps: number, delay = 0) =>
  spring({ frame: frame - delay, fps, config: { damping: 17, mass: 0.8, stiffness: 150 } });

export type Flick = { at: number; to: number };

/**
 * Human-feeling scroll: a series of "flicks", each springing to the next
 * offset with inertia + a slight settle. Returns the current offset (px).
 */
export const flickScroll = (frame: number, fps: number, flicks: Flick[]): number => {
  let out = 0;
  let prev = 0;
  for (const f of flicks) {
    const s = spring({
      frame: frame - f.at,
      fps,
      config: { damping: 15, mass: 0.9, stiffness: 90 },
    });
    out += (f.to - prev) * s;
    prev = f.to;
  }
  return out;
};

/** Numeric velocity of any frame-driven scalar — for motion blur. */
export const velocity = (fn: (f: number) => number, frame: number): number =>
  frame <= 0 ? 0 : fn(frame) - fn(frame - 1);

/** Map |velocity| to a CSS blur px value, capped. */
export const motionBlur = (vel: number, k = 0.05, cap = 7): number =>
  Math.min(cap, Math.abs(vel) * k);
