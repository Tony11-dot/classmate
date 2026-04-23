import { NextResponse } from "next/server";

import { requireAuth, requireRole } from "@/lib/authz";
import { assertParentStudentAccess } from "@/lib/parent-access";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["PARENT", "ADMIN"]);
  if (forb) return forb;

  const url = new URL(req.url);
  const studentId = url.searchParams.get("studentId")?.trim() ?? "";
  const since = url.searchParams.get("since");

  if (studentId && a.role === "PARENT") {
    const access = await assertParentStudentAccess(a.uid, studentId);
    if (!access.ok) {
      return NextResponse.json({ error: access.reason }, { status: 403 });
    }
  }

  return NextResponse.json({ ok: true, unread: 0, since: since ?? null, breakdown: {} });
}