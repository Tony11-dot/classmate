import React from "react";
import { FONTS } from "../theme";

export type AppDef = {
  label: string;
  c1: string;
  c2: string;
  glyph: React.ReactNode;
};

/** Simple, recognisable brand-coloured app icon (rounded squircle + glyph). */
export const AppTile: React.FC<{ app: AppDef; size?: number; label?: boolean }> = ({
  app,
  size = 120,
  label = true,
}) => {
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: size * 0.14 }}>
      <div
        style={{
          width: size,
          height: size,
          borderRadius: size * 0.24,
          background: `linear-gradient(150deg, ${app.c1}, ${app.c2})`,
          boxShadow: `0 ${size * 0.16}px ${size * 0.3}px -${size * 0.1}px ${app.c1}88, 0 6px 16px rgba(20,30,80,0.2), inset 0 1px 2px rgba(255,255,255,0.4)`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          color: "#fff",
        }}
      >
        <div style={{ width: size * 0.56, height: size * 0.56 }}>{app.glyph}</div>
      </div>
      {label ? (
        <div style={{ fontFamily: FONTS.body, fontSize: size * 0.15, fontWeight: 600, color: "#334", opacity: 0.75 }}>
          {app.label}
        </div>
      ) : null}
    </div>
  );
};

const S = (p: React.SVGProps<SVGSVGElement>) => ({ viewBox: "0 0 24 24", width: "100%", height: "100%", ...p });

/** The disconnected school tools. Hand-drawn glyphs (no external assets). */
export const APPS: Record<string, AppDef> = {
  whatsapp: {
    label: "WhatsApp",
    c1: "#25D366",
    c2: "#128C4B",
    glyph: (
      <svg {...S()} fill="#fff">
        <path d="M12 2a10 10 0 0 0-8.5 15.2L2 22l4.9-1.5A10 10 0 1 0 12 2Zm5.3 14c-.2.6-1.2 1.2-1.7 1.2-.5.1-1 .1-1.7-.1-.4-.1-1-.3-1.6-.6a9 9 0 0 1-3.6-3.3c-.3-.4-.7-1.1-.7-2.1s.5-1.5.7-1.7c.2-.2.4-.3.6-.3h.4c.2 0 .3 0 .5.4l.6 1.5c.1.1.1.3 0 .4l-.3.4-.3.3c-.1.1-.2.2-.1.4.1.2.5.9 1.2 1.5.9.8 1.6 1 1.8 1.1.2.1.3.1.4-.1l.6-.7c.1-.2.3-.2.4-.1l1.5.7c.2.1.4.2.4.3.1.1.1.5-.1 1Z" />
      </svg>
    ),
  },
  zoom: {
    label: "Zoom",
    c1: "#4A8CFF",
    c2: "#2D6BE0",
    glyph: (
      <svg {...S()} fill="none">
        <rect x="2" y="7" width="13" height="10" rx="2.5" fill="#fff" />
        <path d="M16 10.5 21 8v8l-5-2.5Z" fill="#fff" />
      </svg>
    ),
  },
  classroom: {
    label: "Classroom",
    c1: "#2BB673",
    c2: "#0F9D58",
    glyph: (
      <svg {...S()} fill="none">
        <rect x="3" y="4.5" width="18" height="15" rx="2" fill="#fff" />
        <circle cx="12" cy="11" r="2.4" fill="#0F9D58" />
        <path d="M7.5 17c0-2 2-3 4.5-3s4.5 1 4.5 3" stroke="#0F9D58" strokeWidth="1.6" strokeLinecap="round" />
      </svg>
    ),
  },
  chatgpt: {
    label: "ChatGPT",
    c1: "#19C37D",
    c2: "#0E8A5A",
    glyph: (
      <svg {...S()} fill="none" stroke="#fff" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 4.5c1.6-1 3.7-.4 4.6 1.2M12 4.5c-1.6-1-3.7-.4-4.6 1.2M12 4.5v5M16.6 5.7c1.9.3 3 2.3 2.3 4.1M16.6 5.7l-4.3 2.5M7.4 5.7c-1.9.3-3 2.3-2.3 4.1M18.9 9.8c1.2 1.4.9 3.6-.7 4.6M18.9 9.8l-4.3 2.5M5.1 9.8c-1.2 1.4-.9 3.6.7 4.6M12 19.5c-1.6 1-3.7.4-4.6-1.2M12 19.5c1.6 1 3.7.4 4.6-1.2M12 19.5v-5M7.4 18.3c-1.9-.3-3-2.3-2.3-4.1M7.4 18.3l4.3-2.5" />
      </svg>
    ),
  },
  livetop: {
    label: "LiveTop",
    c1: "#8B5CF6",
    c2: "#6D28D9",
    glyph: (
      <svg {...S()} fill="none">
        <circle cx="12" cy="12" r="8.5" stroke="#fff" strokeWidth="1.8" />
        <circle cx="12" cy="12" r="3" fill="#fff" />
      </svg>
    ),
  },
};
