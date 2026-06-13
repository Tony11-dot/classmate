# ClassMate — Cinematic Demo Video

A [Remotion](https://www.remotion.dev/) project that renders the 45-second ClassMate
product demo used on [classmateapp.org](https://classmateapp.org).

The rendered files are **not** committed here (see `.gitignore`); the deployable copies
live in `../public/assets/` and are what Firebase Hosting serves.

## Scenes

| # | Scene | Beat |
|---|-------|------|
| 1 | Classroom cold open | A dark room lights up, desk by desk |
| 2 | Kinetic-type promise | "Attendance, finally, effortless." |
| 3 | Teacher attendance | One tap per student, rows check green |
| 4 | Parent notification | A push lands: "Maya is present ✓" |
| 5 | Student check-in | Tap-to-check-in with a ripple |
| 6 | Attendance graph | Line-drawn SVG, gold→green, counter to 96% |
| 7 | CTA | "Join ClassMate Today" |

Professional transitions (dissolve / slide / wipe) connect the scenes, and a warm
gold-and-green color grade with a vignette and film grain sits over everything.

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
npm run render          # → out/classmate-demo.mp4   (H.264, 1920×1080, 45s)
npm run render:poster   # → out/poster.png           (still frame, attendance graph "96%")
```

Then publish to the site (what Firebase deploys):

```bash
mkdir -p ../public/assets
cp out/classmate-demo.mp4 ../public/assets/classmate-demo.mp4
cp out/poster.png         ../public/assets/classmate-demo-poster.png
```

## Music

The composition is pre-wired for a background track but ships **muted** so it stays
royalty-clean by default.

1. Drop a **royalty-free** track at `public/music/hook.mp3`. Good sources:
   - [Uppbeat](https://uppbeat.io/) (free with attribution / credit-free on paid)
   - [Pixabay Music](https://pixabay.com/music/) (Pixabay Content License)
   - [YouTube Audio Library](https://www.youtube.com/audiolibrary)
   - Confirm the license permits commercial use and keep the receipt/license file.
2. Open `src/theme.ts` and set `MUSIC_ENABLED = true`.
   (Change `MUSIC_SRC` if you name the file differently.)
3. Re-render. The track is mixed at 55% volume — adjust `volume` in
   `src/Video.tsx` if needed.

`public/music/` is git-ignored so licensed audio is never committed by accident.

## Tweaking

- **Colors / fonts / timing** — all in [`src/theme.ts`](src/theme.ts).
- **Scene lengths** — `SCENES` in `theme.ts`; `TOTAL_FRAMES` recomputes automatically
  so the composition length always matches.
- **A specific scene** — each lives in `src/scenes/` and is self-contained.
- **Poster frame** — change `--frame=210` in the `render:poster` script.

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
