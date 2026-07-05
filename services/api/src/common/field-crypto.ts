import * as crypto from 'crypto';

/**
 * Transparent application-layer field encryption for sensitive PII.
 *
 * Format: `enc:v1:` + base64( iv(12) || authTag(16) || ciphertext ) using
 * AES-256-GCM (non-deterministic — a random IV per write).
 *
 * The key comes from `process.env.PII_ENC_KEY`. It accepts a 32-byte key as
 * hex(64) or base64; any other (sufficiently long) secret is stretched to 32
 * bytes via SHA-256. When the env var is unset the module is a *safe no-op*:
 * encrypt returns plaintext (logging a single warning) and decrypt passes
 * through — the app never crashes for a missing key. These functions never
 * throw on normal input.
 */

export const ENC_PREFIX = 'enc:v1:';

/** Field names that get encrypted on write (across User + SchoolCertificate). */
export const ENCRYPTED_FIELD_NAMES = new Set(['nationalId', 'phone', 'legalName']);

const ALGORITHM = 'aes-256-gcm';
const IV_LEN = 12;
const TAG_LEN = 16;

let keyResolved = false;
let cachedKey: Buffer | null = null;
let missingKeyWarned = false;

function resolveKey(): Buffer | null {
  if (keyResolved) return cachedKey;
  keyResolved = true;

  const raw = process.env.PII_ENC_KEY;
  if (!raw || raw.trim().length === 0) {
    cachedKey = null;
    return null;
  }

  const trimmed = raw.trim();

  // 32-byte key supplied as hex(64)
  if (/^[0-9a-fA-F]{64}$/.test(trimmed)) {
    cachedKey = Buffer.from(trimmed, 'hex');
    return cachedKey;
  }

  // 32-byte key supplied as base64
  try {
    const b = Buffer.from(trimmed, 'base64');
    if (b.length === 32) {
      cachedKey = b;
      return cachedKey;
    }
  } catch {
    /* fall through to derivation */
  }

  // Any other secret: derive a deterministic 32-byte key.
  cachedKey = crypto.createHash('sha256').update(trimmed).digest();
  return cachedKey;
}

/** True when the value is one of our ciphertext strings. */
export function isEncrypted(v: unknown): boolean {
  return typeof v === 'string' && v.startsWith(ENC_PREFIX);
}

/**
 * Encrypt a plaintext string. Returns the ciphertext envelope, or the input
 * unchanged when there is no key / it is already encrypted / it is not a
 * non-empty string. Never throws.
 */
export function encryptField(plain: string): string {
  if (typeof plain !== 'string' || plain.length === 0) return plain;
  if (isEncrypted(plain)) return plain;

  const key = resolveKey();
  if (!key) {
    if (!missingKeyWarned) {
      missingKeyWarned = true;
      // eslint-disable-next-line no-console
      console.warn(
        '[field-crypto] PII_ENC_KEY is not set — PII fields are stored in PLAINTEXT (encryption is a no-op). Set PII_ENC_KEY to enable encryption at rest.',
      );
    }
    return plain;
  }

  try {
    const iv = crypto.randomBytes(IV_LEN);
    const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
    const ciphertext = Buffer.concat([cipher.update(plain, 'utf8'), cipher.final()]);
    const tag = cipher.getAuthTag();
    return ENC_PREFIX + Buffer.concat([iv, tag, ciphertext]).toString('base64');
  } catch {
    // Never break a write over an encryption hiccup — fall back to plaintext.
    return plain;
  }
}

/**
 * Decrypt a value. If it is one of our ciphertext strings, return the
 * plaintext; otherwise return it unchanged (tolerates legacy plaintext and is
 * double-safe). Never throws — on any failure the original value is returned.
 */
export function decryptField(value: string): string {
  if (typeof value !== 'string' || !isEncrypted(value)) return value;

  const key = resolveKey();
  if (!key) return value; // cannot decrypt without a key — pass through unchanged

  try {
    const buf = Buffer.from(value.slice(ENC_PREFIX.length), 'base64');
    if (buf.length < IV_LEN + TAG_LEN) return value;
    const iv = buf.subarray(0, IV_LEN);
    const tag = buf.subarray(IV_LEN, IV_LEN + TAG_LEN);
    const ciphertext = buf.subarray(IV_LEN + TAG_LEN);
    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(tag);
    const plain = Buffer.concat([decipher.update(ciphertext), decipher.final()]);
    return plain.toString('utf8');
  } catch {
    return value;
  }
}

/** True when PII_ENC_KEY is configured (encryption is active). */
export function isEncryptionEnabled(): boolean {
  return resolveKey() !== null;
}
