import { NextResponse } from "next/server";
import { z } from "zod";
import bcrypt from "bcryptjs";
import { prisma } from "@/lib/prisma";
import { signToken } from "@/lib/auth";

const Body = z.object({
  schoolName: z.string().min(2),
  fullName: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(8),
});

export async function POST(req: Request) {
  const body = Body.parse(await req.json());

  const school = await prisma.school.create({ data: { name: body.schoolName } });

  const passwordHash = await bcrypt.hash(body.password, 10);

  const user = await prisma.user.create({
    data: {
      schoolId: school.id,
      fullName: body.fullName,
      email: body.email.toLowerCase(),
      passwordHash,
      role: "ADMIN",
    },
    select: { id: true, schoolId: true, role: true, fullName: true, email: true },
  });

  const token = signToken({ uid: user.id, sid: user.schoolId, role: user.role });

  return NextResponse.json({ token, user });
}
