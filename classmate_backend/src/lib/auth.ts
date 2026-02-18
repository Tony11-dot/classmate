import jwt from "jsonwebtoken";

const SECRET = process.env.JWT_SECRET;
if (!SECRET) throw new Error("JWT_SECRET is missing");

export type TokenPayload = { uid: string; sid: string; role: string };

export function signToken(p: TokenPayload) {
  return jwt.sign(p, SECRET, { expiresIn: "30d" });
}

export function verifyToken(token: string): TokenPayload | null {
  if (!token) return null;
  try {
    return jwt.verify(token, SECRET) as TokenPayload;
  } catch {
    return null;
  }
}
