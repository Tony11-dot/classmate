import { NextResponse } from "next/server";
import { z } from "zod";
import bcrypt from "bcryptjs";
import { prisma } from "@/lib/prisma";
import { signToken } from "@/lib/auth";

const Body = z.object({
  schoolId: z.string().min(1),
  email: z.string().email(),
  password: z.string().min(1),
});

export async function POST(req: Request) {
  const body = Body.parse(await req.json());
  const schoolId = body.schoolId;
  const email = body.email.toLowerCase();

  const user = await prisma.user.findUnique({
    where: { schoolId_email: { schoolId, email } } as any,
    select: { id: true, schoolId: true, role: true, fullName: true, email: true, passwordHash: true } as any,
  });

  if (!user) return NextResponse.json({ error: "INVALID_CREDENTIALS" }, { status: 401 });

  const ok = await bcrypt.compare(body.password, user.passwordHash);
  if (!ok) return NextResponse.json({ error: "INVALID_CREDENTIALS" }, { status: 401 });

  const token = signToken({ uid: user.id, sid: user.schoolId, role: user.role });

  return NextResponse.json({
    token,
    user: { id: user.id, schoolId: user.schoolId, role: user.role, fullName: user.fullName, email: user.email },
  });
}
