import * as crypto from 'crypto';

/**
 * Reversible password storage for admin export.
 *
 * Passwords are still bcrypt-hashed in `User.password` for authentication —
 * that hash is one-way and can never be read back. Separately, when an admin
 * sets/generates/resets a credential we keep a *reversible* encrypted copy in
 * `User.passwordEnc` so the admin can re-export the SAME current password
 * later without resetting the user's login.
 *
 * Encryption: AES-256-GCM. The key is derived (scrypt) from the
 * `PASSWORD_ENC_KEY` env var, falling back to `JWT_SECRET` so the feature
 * works without extra config (set a dedicated PASSWORD_ENC_KEY in prod and
 * NEVER rotate it without re-encrypting, or stored copies become unreadable).
 *
 * Stored format: `v1:<iv_hex>:<tag_hex>:<ciphertext_hex>`.
 */

const FORMAT = 'v1';
let cachedKey: Buffer | null = null;

function getKey(): Buffer | null {
  if (cachedKey) return cachedKey;
  const secret = process.env.PASSWORD_ENC_KEY || process.env.JWT_SECRET;
  if (!secret || !secret.trim()) return null;
  // Deterministic 32-byte key from the secret. Fixed salt is fine here: the
  // salt only needs to be stable so the same secret always yields the same key.
  cachedKey = crypto.scryptSync(secret, 'classmate-password-vault', 32);
  return cachedKey;
}

/**
 * Encrypt a plaintext password for at-rest storage. Returns null if no key is
 * configured (caller should then simply not persist a recoverable copy).
 */
export function encryptPassword(plain: string): string | null {
  const key = getKey();
  if (!key || !plain) return null;
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
  const ct = Buffer.concat([cipher.update(plain, 'utf8'), cipher.final()]);
  const tag = cipher.getAuthTag();
  return `${FORMAT}:${iv.toString('hex')}:${tag.toString('hex')}:${ct.toString('hex')}`;
}

/**
 * Decrypt a stored password copy. Returns null if the key is missing, the
 * blob is malformed, or authentication fails (e.g. key changed).
 */
export function decryptPassword(stored: string | null | undefined): string | null {
  if (!stored) return null;
  const key = getKey();
  if (!key) return null;
  try {
    const [fmt, ivHex, tagHex, ctHex] = stored.split(':');
    if (fmt !== FORMAT || !ivHex || !tagHex || !ctHex) return null;
    const decipher = crypto.createDecipheriv(
      'aes-256-gcm',
      key,
      Buffer.from(ivHex, 'hex'),
    );
    decipher.setAuthTag(Buffer.from(tagHex, 'hex'));
    const pt = Buffer.concat([
      decipher.update(Buffer.from(ctHex, 'hex')),
      decipher.final(),
    ]);
    return pt.toString('utf8');
  } catch {
    return null;
  }
}
