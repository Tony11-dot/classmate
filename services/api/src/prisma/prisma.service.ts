import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';
import {
  ENCRYPTED_FIELD_NAMES,
  decryptField,
  encryptField,
  isEncrypted,
  isEncryptionEnabled,
} from '../common/field-crypto';

// Prisma 6 removed `$use` middleware, so transparent field crypto is wired via
// a Client Extension ($extends). See the class docblock below for how the
// extended client is exposed without changing any consumer.

/** Write actions whose `data` we encrypt (for User + SchoolCertificate only). */
const WRITE_OPS = new Set(['create', 'update', 'upsert', 'createMany', 'updateMany']);
const CRYPTO_MODELS = new Set(['User', 'SchoolCertificate']);
const MAX_DECRYPT_DEPTH = 12;

/** Encrypt in-place the sensitive fields of a single `data`-like object. */
function encryptDataNode(node: unknown): void {
  if (!node || typeof node !== 'object') return;
  if (Array.isArray(node)) {
    node.forEach(encryptDataNode);
    return;
  }
  const obj = node as Record<string, unknown>;
  for (const field of ENCRYPTED_FIELD_NAMES) {
    const v = obj[field];
    if (typeof v === 'string' && v.length > 0 && !isEncrypted(v)) {
      obj[field] = encryptField(v);
    } else if (
      v &&
      typeof v === 'object' &&
      typeof (v as { set?: unknown }).set === 'string'
    ) {
      // Prisma update form: { field: { set: 'value' } }
      const setVal = (v as { set: string }).set;
      if (setVal.length > 0 && !isEncrypted(setVal)) {
        (v as { set: string }).set = encryptField(setVal);
      }
    }
  }
}

/** Encrypt the relevant portions of args for a given write operation. */
function encryptArgs(operation: string, args: unknown): void {
  if (!args || typeof args !== 'object') return;
  const a = args as Record<string, unknown>;
  switch (operation) {
    case 'create':
    case 'update':
    case 'updateMany':
      encryptDataNode(a.data);
      break;
    case 'createMany':
      encryptDataNode(a.data); // array — encryptDataNode handles it
      break;
    case 'upsert':
      encryptDataNode(a.create);
      encryptDataNode(a.update);
      break;
    default:
      break;
  }
}

/**
 * Deep-walk a result graph, decrypting any string that is one of our
 * ciphertext envelopes. Prefix-gating (`isEncrypted`) makes this safe for
 * every model/field — only our ciphertext is ever transformed. Mutates in
 * place and early-returns for primitives; depth-capped as a cheap cycle guard.
 */
function decryptDeep(value: unknown, depth = 0): unknown {
  if (typeof value === 'string') {
    return isEncrypted(value) ? decryptField(value) : value;
  }
  if (!value || typeof value !== 'object') return value;
  if (depth >= MAX_DECRYPT_DEPTH) return value;
  if (value instanceof Date || Buffer.isBuffer(value)) return value;

  if (Array.isArray(value)) {
    for (let i = 0; i < value.length; i++) {
      value[i] = decryptDeep(value[i], depth + 1);
    }
    return value;
  }

  const obj = value as Record<string, unknown>;
  for (const key of Object.keys(obj)) {
    obj[key] = decryptDeep(obj[key], depth + 1);
  }
  return value;
}

/** The Prisma Client extension implementing transparent PII field crypto. */
const fieldCryptoExtension = Prisma.defineExtension({
  name: 'pii-field-crypto',
  query: {
    $allModels: {
      async $allOperations({ model, operation, args, query }) {
        if (CRYPTO_MODELS.has(model) && WRITE_OPS.has(operation)) {
          encryptArgs(operation, args);
        }
        const result = await query(args);
        return decryptDeep(result);
      },
    },
  },
});

/**
 * PrismaService — a PrismaClient with transparent PII encryption at rest.
 *
 * The client extension is applied via `$extends`, which returns a *new*
 * extended client. To keep the public surface identical (consumers still
 * inject `PrismaService` and call `prisma.user.findMany()` etc.) the
 * constructor returns a Proxy: model delegates and `$`-methods are routed to
 * the extended client, while our own lifecycle/backfill methods stay on this
 * instance.
 */
@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    super();

    const extended = this.$extends(fieldCryptoExtension) as unknown as PrismaClient;

    // Methods that must resolve to *this* instance (not the extended client).
    const own = new Set<string>([
      'onModuleInit',
      'onModuleDestroy',
      'runPiiBackfill',
      'logger',
    ]);

    return new Proxy(this, {
      get(target, prop, receiver) {
        if (typeof prop === 'string' && own.has(prop)) {
          const v = (target as unknown as Record<string, unknown>)[prop];
          return typeof v === 'function' ? v.bind(receiver) : v;
        }
        const ev = (extended as unknown as Record<string | symbol, unknown>)[prop];
        return typeof ev === 'function' ? (ev as (...a: unknown[]) => unknown).bind(extended) : ev;
      },
    });
  }

  async onModuleInit() {
    await this.$connect();
    // Backfill runs AFTER the extension is installed, and only when a key is
    // configured. Never let it crash boot.
    await this.runPiiBackfill();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }

  /**
   * Idempotent one-shot backfill: find rows whose stored PII is not yet
   * encrypted and re-write them through the (encrypting) write path. After the
   * first successful run there are no plaintext rows left, so later boots are a
   * cheap counting no-op. Gated on PII_ENC_KEY being set.
   */
  private async runPiiBackfill(): Promise<void> {
    if (!isEncryptionEnabled()) return;

    try {
      await this.backfillUsers();
      await this.backfillSchoolCertificates();
    } catch (err) {
      this.logger.error(
        `PII backfill failed (non-fatal): ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  }

  private async backfillUsers(): Promise<void> {
    const rows = await this.$queryRaw<
      Array<{ id: string; nationalId: string | null; phone: string | null; legalName: string | null }>
    >(Prisma.sql`
      SELECT "id", "nationalId", "phone", "legalName"
      FROM "User"
      WHERE ("nationalId" IS NOT NULL AND "nationalId" NOT LIKE 'enc:v1:%')
         OR ("phone" IS NOT NULL AND "phone" NOT LIKE 'enc:v1:%')
         OR ("legalName" IS NOT NULL AND "legalName" NOT LIKE 'enc:v1:%')
    `);

    if (rows.length === 0) {
      this.logger.log('PII backfill: User — 0 plaintext rows (already encrypted).');
      return;
    }

    let ok = 0;
    let failed = 0;
    for (let i = 0; i < rows.length; i += 200) {
      const chunk = rows.slice(i, i + 200);
      for (const row of chunk) {
        const data: Record<string, string> = {};
        if (row.nationalId && !isEncrypted(row.nationalId)) data.nationalId = row.nationalId;
        if (row.phone && !isEncrypted(row.phone)) data.phone = row.phone;
        if (row.legalName && !isEncrypted(row.legalName)) data.legalName = row.legalName;
        if (Object.keys(data).length === 0) continue;
        try {
          // The write extension encrypts these fields on the way in.
          await this.user.update({ where: { id: row.id }, data });
          ok++;
        } catch (err) {
          failed++;
          this.logger.warn(
            `PII backfill: User ${row.id} failed: ${err instanceof Error ? err.message : String(err)}`,
          );
        }
      }
    }
    this.logger.log(`PII backfill: User — encrypted ${ok} row(s), ${failed} failed.`);
  }

  private async backfillSchoolCertificates(): Promise<void> {
    const rows = await this.$queryRaw<Array<{ id: string; nationalId: string | null }>>(Prisma.sql`
      SELECT "id", "nationalId"
      FROM "SchoolCertificate"
      WHERE "nationalId" IS NOT NULL AND "nationalId" NOT LIKE 'enc:v1:%'
    `);

    if (rows.length === 0) {
      this.logger.log('PII backfill: SchoolCertificate — 0 plaintext rows (already encrypted).');
      return;
    }

    let ok = 0;
    let failed = 0;
    for (let i = 0; i < rows.length; i += 200) {
      const chunk = rows.slice(i, i + 200);
      for (const row of chunk) {
        if (!row.nationalId || isEncrypted(row.nationalId)) continue;
        try {
          await this.schoolCertificate.update({
            where: { id: row.id },
            data: { nationalId: row.nationalId },
          });
          ok++;
        } catch (err) {
          failed++;
          this.logger.warn(
            `PII backfill: SchoolCertificate ${row.id} failed: ${err instanceof Error ? err.message : String(err)}`,
          );
        }
      }
    }
    this.logger.log(`PII backfill: SchoolCertificate — encrypted ${ok} row(s), ${failed} failed.`);
  }
}
