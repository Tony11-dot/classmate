import { NextResponse } from "next/server";

import { requireAuth, requireRole } from "@/lib/authz";
import { assertParentStudentAccess } from "@/lib/parent-access";

function startOfWeek(date: Date) {
  const d = new Date(date);
  const day = d.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() + diff);
  return d;
}

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;

  const forb = requireRole(a, ["PARENT", "ADMIN"]);
  if (forb) return forb;

  const url = new URL(req.url);
  const studentId = url.searchParams.get("studentId")?.trim() ?? "";
  if (!studentId) {
    return NextResponse.json({ error: "STUDENT_ID_REQUIRED" }, { status: 400 });
  }

  if (a.role === "PARENT") {
    const access = await assertParentStudentAccess(a.uid, studentId);
    if (!access.ok) {
      return NextResponse.json({ error: access.reason }, { status: 403 });
    }
  }

  const weekStart = startOfWeek(new Date());
  const weekEnd = new Date(weekStart);
  weekEnd.setDate(weekStart.getDate() + 6);

  return NextResponse.json({
    capabilities: {
      schedule: false,
      attendance: false,
    },
    weekSchedule: {
      weekStart: weekStart.toISOString(),
      weekEnd: weekEnd.toISOString(),
      days: [],
    },
    attendanceWeek: {
      sessions: [],
    },
  });
}