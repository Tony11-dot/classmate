import { NextResponse } from "next/server";
import { verifyToken, type TokenPayload } from "@/lib/auth";

export type Auth = TokenPayload;

export function requireAuth(req: Request): Auth | NextResponse {
  const auth = req.headers.get("authorization") || "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
  const p = verifyToken(token);
  if (!p) return NextResponse.json({ error: "UNAUTHORIZED" }, { status: 401 });
  return p;
}

export function requireRole(a: Auth, roles: string[]): NextResponse | null {
  if (!roles.includes(a.role)) return NextResponse.json({ error: "FORBIDDEN" }, { status: 403 });
  return null;
}
