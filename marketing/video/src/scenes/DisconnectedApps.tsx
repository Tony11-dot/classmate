import React from "react";
import { AbsoluteFill, Img, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONTS } from "../theme";
import { AuroraLight } from "../components/AuroraLight";
import { AppTile, APPS } from "../components/AppTile";
import { pop } from "../anim";

/**
 * v4 opener — punchy and decluttered.
 * Beats (580f @60fps): tiles POP in one-by-one with badges ticking up →
 * jitter builds → tiles get sucked into the centre with velocity blur →
 * white flash + shockwave → ClassMate mark bounces in → closing line.
 */
export const DisconnectedApps: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames: dur } = useVideoConfig();

  const CONV_START = Math.round(dur * 0.52); // ≈300
  const IMPACT = CONV_START + 66;

  // Convergence progress with an aggressive spring (sucked in, not eased in).
  const convAt = (f: number) =>
    spring({ frame: f - CONV_START, fps, config: { damping: 15, mass: 0.9, stiffness: 70 }, durationInFrames: 90 });
  const conv = convAt(frame);
  const convVel = convAt(frame) - convAt(frame - 1);

  const tiles = [
    { app: APPS.whatsapp, x: -560, y: -140, s: 3, in: 8, badge: 12 },
    { app: APPS.zoom, x: 540, y: -170, s: 1, in: 16, badge: 3 },
    { app: APPS.classroom, x: -600, y: 210, s: 4, in: 24, badge: 7 },
    { app: APPS.chatgpt, x: 580, y: 220, s: 2, in: 32, badge: 5 },
    { app: APPS.livetop, x: 0, y: -250, s: 5, in: 40, badge: 9 },
  ];

  const flash = interpolate(frame, [IMPACT - 2, IMPACT + 3, IMPACT + 16], [0, 0.85, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const ring = spring({ frame: frame - IMPACT, fps, config: { damping: 20, mass: 1, stiffness: 60 } });
  const logoPop = pop(frame, fps, IMPACT + 2);

  return (
    <AbsoluteFill>
      <AuroraLight hues={[COLORS.gold, COLORS.sky, COLORS.emerald, COLORS.indigoSoft]} />

      {/* Tangle lines while chaotic. */}
      <AbsoluteFill style={{ opacity: interpolate(conv, [0, 0.4], [0.45, 0], { extrapolateRight: "clamp" }) }}>
        <svg width="100%" height="100%" style={{ position: "absolute", inset: 0 }}>
          {tiles.map((a, i) =>
            tiles.slice(i + 1).map((b, j) => {
              const on = interpolate(frame, [Math.max(a.in, b.in) + 14, Math.max(a.in, b.in) + 30], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
              return (
                <line key={`${i}-${j}`} x1={`${50 + a.x / 19.2}%`} y1={`${52 + a.y / 10.8}%`} x2={`${50 + b.x / 19.2}%`} y2={`${52 + b.y / 10.8}%`} stroke={COLORS.muted} strokeWidth={1.5} strokeDasharray="4 8" strokeDashoffset={-frame * 0.8} opacity={0.5 * on} />
              );
            }),
          )}
        </svg>
      </AbsoluteFill>

      {/* Two notification pills only — parked in clear gaps. */}
      {[
        { t: "Where's the grade?", x: -250, y: 30, at: 70, c: COLORS.sky },
        { t: "Zoom link??", x: 265, y: 40, at: 130, c: COLORS.gold },
      ].map((n, i) => {
        const on = pop(frame, fps, n.at);
        const off = interpolate(frame, [CONV_START - 20, CONV_START], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
        if (frame < n.at) return null;
        return (
          <div key={i} style={{ position: "absolute", left: `calc(50% + ${n.x}px)`, top: `calc(52% + ${n.y}px)`, transform: `translate(-50%,-50%) scale(${on})`, opacity: on * off, background: "#fff", borderRadius: 14, padding: "10px 18px", fontFamily: FONTS.body, fontSize: 21, fontWeight: 700, color: COLORS.ink, boxShadow: "0 16px 34px -12px rgba(20,30,80,0.35)", display: "flex", alignItems: "center", gap: 10 }}>
            <span style={{ width: 9, height: 9, borderRadius: 99, background: n.c }} />
            {n.t}
          </div>
        );
      })}

      {/* App tiles */}
      <AbsoluteFill>
        {tiles.map((t, i) => {
          const inS = pop(frame, fps, t.in);
          // jitter builds over the chaos phase
          const heat = interpolate(frame, [60, CONV_START], [0.3, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
          const jx = (Math.sin(frame / 5 + t.s * 2) * 5 + Math.sin(frame / 13 + t.s) * 6) * heat * (1 - conv);
          const jy = Math.cos(frame / 6 + t.s * 1.3) * 6 * heat * (1 - conv);
          const x = interpolate(conv, [0, 1], [t.x, 0]) + jx;
          const y = interpolate(conv, [0, 1], [t.y, 0]) + jy;
          const scale = inS * interpolate(conv, [0, 1], [1, 0.1]);
          const opacity = interpolate(conv, [0.75, 1], [1, 0], { extrapolateLeft: "clamp" });
          const blur = Math.min(9, Math.abs(convVel) * Math.hypot(t.x, t.y) * 0.045);
          const badgeN = Math.min(t.badge, 1 + Math.floor(Math.max(0, frame - t.in - 20) / 40));
          return (
            <div key={i} style={{ position: "absolute", left: "50%", top: "52%", transform: `translate(-50%,-50%) translate(${x}px, ${y}px) scale(${scale})`, opacity, filter: blur > 0.5 ? `blur(${blur}px)` : undefined }}>
              <div style={{ position: "relative" }}>
                <AppTile app={t.app} size={132} label={conv < 0.2} />
                {/* red badge ticking up */}
                <div style={{ position: "absolute", top: -10, right: -10, minWidth: 34, height: 34, borderRadius: 99, background: "#FF3B30", color: "#fff", fontFamily: FONTS.body, fontWeight: 800, fontSize: 19, display: "flex", alignItems: "center", justifyContent: "center", padding: "0 8px", boxShadow: "0 6px 16px rgba(255,59,48,0.5)", transform: `scale(${1 + 0.25 * Math.abs(Math.sin((frame - t.in) / 9))})`, opacity: inS * (1 - conv) }}>
                  {badgeN}
                </div>
              </div>
            </div>
          );
        })}
      </AbsoluteFill>

      {/* Shockwave ring on impact */}
      {frame >= IMPACT ? (
        <AbsoluteFill style={{ display: "flex", alignItems: "center", justifyContent: "center", pointerEvents: "none" }}>
          <div style={{ width: 200 + ring * 900, height: 200 + ring * 900, borderRadius: "50%", border: `3px solid ${COLORS.indigoSoft}`, opacity: (1 - ring) * 0.7 }} />
        </AbsoluteFill>
      ) : null}

      {/* ClassMate mark bounces in on impact */}
      <AbsoluteFill style={{ display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div style={{ transform: `scale(${logoPop})`, opacity: frame >= IMPACT ? 1 : 0, width: 230, height: 230, borderRadius: 56, background: `linear-gradient(150deg, ${COLORS.indigo}, ${COLORS.indigoDeep})`, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: `0 40px 90px -20px ${COLORS.indigo}aa` }}>
          <Img src={staticFile("brand/cm-icon.png")} style={{ width: 156, height: 156, objectFit: "contain" }} />
        </div>
      </AbsoluteFill>

      {/* White flash */}
      <AbsoluteFill style={{ background: "#fff", opacity: flash, pointerEvents: "none" }} />

      {/* Captions — dedicated zones, never over tiles */}
      <Cap frame={frame} show={[14, 34, CONV_START - 24, CONV_START - 4]} y="5.5%" text="School runs on a dozen disconnected apps." dark />
      <Cap frame={frame} show={[IMPACT + 10, IMPACT + 26, dur - 20, dur - 1]} y="79%" text="ClassMate brings it all into one." gradient />
    </AbsoluteFill>
  );
};

const Cap: React.FC<{ frame: number; show: number[]; y: string; text: string; gradient?: boolean; dark?: boolean }> = ({ frame, show, y, text, gradient }) => {
  const o = interpolate(frame, show, [0, 1, 1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  if (o <= 0) return null;
  return (
    <div
      style={{
        position: "absolute", top: y, left: 0, right: 0, textAlign: "center",
        transform: `translateY(${interpolate(o, [0, 1], [16, 0])}px)`, opacity: o,
        fontFamily: FONTS.display, fontSize: 56, fontWeight: 800, letterSpacing: -1.2,
        ...(gradient
          ? { background: `linear-gradient(120deg, ${COLORS.indigo}, ${COLORS.sky})`, WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent" }
          : { color: COLORS.ink }),
      }}
    >
      {text}
    </div>
  );
};
