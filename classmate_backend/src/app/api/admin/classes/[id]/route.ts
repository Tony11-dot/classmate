import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";

export async function GET(req: Request, ctx: { params: Promise<{ id: string }> }) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;
  const forb = requireRole(a, ["ADMIN"]);
  if (forb) return forb;

  const { id } = await ctx.params;

  const row = await (prisma as any).classRoom.findFirst({
    where: { id, schoolId: a.sid },
    select: { id: true, schoolId: true, name: true, grade: true, createdAt: true } as any,
  });

  if (!row) return NextResponse.json({ error: "NOT_FOUND" }, { status: 404 });
  return NextResponse.json({ class: row });
}
