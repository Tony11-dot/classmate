import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, requireRole } from "@/lib/authz";

export async function GET(req: Request) {
  const a = requireAuth(req);
  if (a instanceof NextResponse) return a;
  const forb = requireRole(a, ["ADMIN"]);
  if (forb) return forb;

  const users = await prisma.user.findMany({
    where: { schoolId: a.sid } as any,
    select: { id: true, fullName: true, email: true, role: true, createdAt: true } as any,
    orderBy: { createdAt: "desc" } as any,
    take: 200,
  });

  return NextResponse.json({ users });
}
