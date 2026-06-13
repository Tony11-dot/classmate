import { continueRender, delayRender } from "remotion";

/**
 * Loads Bricolage Grotesque, Hanken Grotesk and JetBrains Mono from the
 * Google Fonts CDN and blocks the render until the glyphs are ready.
 *
 * If the network is unavailable the render still proceeds (it falls back to
 * system fonts) instead of hanging forever — a demo that renders with a
 * fallback face beats a render that times out.
 */
let started = false;

export function loadFonts(): void {
  if (started || typeof document === "undefined") return;
  started = true;

  const handle = delayRender("Loading Google Fonts");
  const href =
    "https://fonts.googleapis.com/css2?" +
    "family=Bricolage+Grotesque:opsz,wght@12..96,200..800&" +
    "family=Hanken+Grotesk:wght@300..800&" +
    "family=JetBrains+Mono:wght@400..700&display=swap";

  const finish = () => continueRender(handle);

  const link = document.createElement("link");
  link.rel = "stylesheet";
  link.href = href;
  link.onload = async () => {
    try {
      await Promise.all([
        document.fonts.load('700 64px "Bricolage Grotesque"'),
        document.fonts.load('800 64px "Bricolage Grotesque"'),
        document.fonts.load('600 32px "Hanken Grotesk"'),
        document.fonts.load('400 28px "Hanken Grotesk"'),
        document.fonts.load('500 28px "JetBrains Mono"'),
      ]);
      await document.fonts.ready;
    } catch {
      // ignore — fall back to system fonts
    }
    finish();
  };
  link.onerror = finish;
  document.head.appendChild(link);
}
