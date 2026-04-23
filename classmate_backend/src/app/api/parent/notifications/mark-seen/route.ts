import { NextResponse } from "next/server";

import { requireAuth, requireRole } from "@/lib/authz";

export async function PATCH(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["PARENT", "ADMIN"]);
  if (forb) return forb;

  await req.json().catch(() => ({}));
  return NextResponse.json({ updated: 0 });
}