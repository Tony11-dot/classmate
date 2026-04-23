import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { verifyToken } from "@/lib/auth";
import bcrypt from "bcryptjs";

export async function POST(req: Request) {
  const auth = req.headers.get("authorization") || "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
  const p = verifyToken(token);
  if (!p) return NextResponse.json({ error: "UNAUTHORIZED" }, { status: 401 });

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "INVALID_BODY" }, { status: 400 });
  }

  const currentPassword = (body["currentPassword"] as string | undefined) ?? "";
  const newPassword = (body["newPassword"] as string | undefined) ?? "";

  if (!currentPassword || !newPassword) {
    return NextResponse.json({ error: "MISSING_FIELDS" }, { status: 400 });
  }
  if (newPassword.length < 8) {
    return NextResponse.json(
      { error: "PASSWORD_TOO_SHORT" },
      { status: 400 }
    );
  }

  const user = await prisma.user.findUnique({
    where: { id: p.uid },
    select: { id: true, passwordHash: true },
  });

  if (!user) return NextResponse.json({ error: "NOT_FOUND" }, { status: 404 });

  const match = await bcrypt.compare(currentPassword, user.passwordHash as string);
  if (!match) {
    return NextResponse.json({ error: "WRONG_PASSWORD" }, { status: 400 });
  }

  const hash = await bcrypt.hash(newPassword, 10);
  await prisma.user.update({
    where: { id: user.id },
    data: { passwordHash: hash },
  });

  return NextResponse.json({ ok: true });
}
