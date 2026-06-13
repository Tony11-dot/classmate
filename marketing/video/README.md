# ClassMate — Cinematic Demo Video (v2)

A [Remotion](https://www.remotion.dev/) project that renders the 90-second ClassMate
product demo used on [classmateapp.org](https://classmateapp.org). v2 animates the
**real app UI** (the screenshots in `public/screens/`) inside a light iPhone frame —
tapping, scrolling and confirming like a real user.

The rendered files are **not** committed here (see `.gitignore`); the deployable copies
live in `../public/assets/` and are what Firebase Hosting serves.

## Scenes (9 · 90s)

| # | Scene | Beat |
|---|-------|------|
| 1 | Classroom cold open | A dark room lights up, desk by desk |
| 2 | Kinetic-type promise | "Your whole school, one app." |
| 3 | Attendance → notify | Teacher marks the roster; parent's phone lights up |
| 4 | NOVA AI tutor | Phone scrolls a step-by-step math solution |
| 5 | Classrooms | Class chat scrolls live; a fresh message pops in |
| 6 | Practice | Finger taps the answer → burst → explanation reveals |
| 7 | Grades → Insights | Grades dashboard hands off to a trending-up graph |
| 8 | Feature montage | Snappy cuts: Schedule · Solutions · every role |
| 9 | CTA | "Join ClassMate Today" with a warm gold/indigo close |

Professional transitions (dissolve / slide / wipe) connect the scenes; each opens with a
warm light-leak accent, and an intensified gold-and-emerald color grade with vignette and
film grain sits over everything. Real screenshots are panned/zoomed for depth and
animated with a touch-gesture cursor (`src/components/Finger.tsx`).

## Setup

```bash
cd marketing/video
npm install
```

The first render downloads a Chrome Headless Shell automatically (one-time, ~100 MB).
Fonts (Bricolage Grotesque, Hanken Grotesk, JetBrains Mono) load from Google Fonts at
render time, so the render machine needs network access. If fonts can't be fetched the
render still completes with system-font fallbacks rather than hanging.

## Preview in the studio

```bash
npm run dev      # opens the Remotion Studio at http://localhost:3000
```

## Render

```bash
npm run render          # → out/classmate-demo-v2.mp4        (H.264, 1920×1080, 90s)
npm run render:poster   # → out/classmate-demo-v2-poster.png (NOVA hero frame)
```

Then publish to the site (what Firebase deploys):

```bash
mkdir -p ../public/assets
cp out/classmate-demo-v2.mp4        ../public/assets/classmate-demo-v2.mp4
cp out/classmate-demo-v2-poster.png ../public/assets/classmate-demo-v2-poster.png
```

## Music

The composition is pre-wired for a background track but ships **muted** so it stays
royalty-clean by default.

**Recommended vibe for this 90s cut:** upbeat but minimal, instrumental, ~110–120 BPM,
building from a soft pulse to a confident, bright drop around the NOVA/Practice hero
beats and resolving warm on the CTA. Think "modern ed-tech / Apple-keynote optimism" —
clean piano or pluck + light four-on-the-floor, no vocals.

1. Drop a **royalty-free** track at `public/music/hook.mp3`. Good sources & search terms:
   - [Uppbeat](https://uppbeat.io/) — search "inspiring corporate" / "bright tech"
     (free with attribution; credit-free on the paid tier). Strong picks: tracks tagged
     *uplifting / technology / minimal*.
   - [Pixabay Music](https://pixabay.com/music/) — Pixabay Content License (free for
     commercial, no attribution). Search "inspiring corporate technology" or "minimal
     upbeat".
   - [YouTube Audio Library](https://www.youtube.com/audiolibrary) — filter *Happy /
     Inspirational*, attribution-free.
   - Confirm the license permits commercial use and keep the receipt/license file.
2. Open `src/theme.ts` and set `MUSIC_ENABLED = true`.
   (Change `MUSIC_SRC` if you name the file differently.)
3. Re-render. The track is mixed at 50% volume — adjust `volume` in
   `src/Video.tsx` if needed. The cut's energy beats land ~24s (NOVA), ~48s (Practice)
   and ~84s (CTA) if you want to pick a track that swells there.

`public/music/` is git-ignored so licensed audio is never committed by accident.

## Tweaking

- **Colors / fonts / timing** — all in [`src/theme.ts`](src/theme.ts).
- **Scene lengths** — `SCENES` in `theme.ts`; `TOTAL_FRAMES` recomputes automatically
  so the composition length always matches.
- **A specific scene** — each lives in `src/scenes/` and is self-contained.
- **Poster frame** — change `--frame=840` in the `render:poster` script.
- **App screenshots** — live in `public/screens/` (copied from `marketing/assets`),
  addressed via `SCREENS` in `theme.ts` and animated by `src/components/Shot.tsx`.

## Project layout

```
marketing/video/
├── package.json          # render + render:poster scripts
├── remotion.config.ts    # codec / quality settings
├── tsconfig.json
├── src/
│   ├── index.ts          # registerRoot
│   ├── Root.tsx          # <Composition> registration
│   ├── Video.tsx         # main composition (TransitionSeries + grade + audio)
│   ├── theme.ts          # colors, fonts, timing, MUSIC_ENABLED
│   ├── fonts.ts          # Google Fonts loader (delayRender)
│   ├── components/       # Grade, Avatar, Device
│   └── scenes/           # the 7 scenes
└── out/                  # render output (git-ignored)
```
