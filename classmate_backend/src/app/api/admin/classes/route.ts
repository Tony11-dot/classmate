import { NextResponse } from "next/server";
import { z } from "zod";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;
  const forb = requireRole(a, ["ADMIN"]);
  if (forb) return forb;

  const classes = await (prisma as any).classRoom.findMany({
    where: { schoolId: a.sid },
    orderBy: [{ grade: "asc" }, { name: "asc" }],
    select: { id: true, schoolId: true, name: true, grade: true, createdAt: true } as any,
    take: 500,
  });

  return NextResponse.json({ classes });
}

const Body = z.object({
  name: z.string().min(1),
  grade: z.number().int().min(1).max(12),
});

export async function POST(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;
  const forb = requireRole(a, ["ADMIN"]);
  if (forb) return forb;

  const body = Body.parse(await req.json());

  const row = await (prisma as any).classRoom.create({
    data: { schoolId: a.sid, name: body.name, grade: body.grade } as any,
    select: { id: true, schoolId: true, name: true, grade: true, createdAt: true } as any,
  });

  return NextResponse.json({ class: row });
}
