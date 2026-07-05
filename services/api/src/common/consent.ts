/**
 * Shared consent constants/helpers (Israel Privacy Amendment 13).
 *
 * ClassMate is deployed school-by-school: the SCHOOL is the data controller and
 * obtains guardian consent for minors (offline, per its own policy); ClassMate
 * is the processor. We still record an in-app acceptance of the Privacy Policy
 * + Terms per account — at self-signup, or at first login for school-provisioned
 * users — so there is a per-user, timestamped, versioned consent record.
 */

/// Current Privacy Policy / Terms version. Bump when the policy materially
/// changes so we can prompt existing users to re-consent.
export const CURRENT_CONSENT_VERSION = '2026-07-05';

/// Parse an optional ISO date-of-birth (YYYY-MM-DD or full ISO). Returns null
/// for empty/invalid input rather than throwing — DOB is optional.
export function parseBirthDate(input?: unknown): Date | null {
  const s = String(input ?? '').trim();
  if (!s) return null;
  const iso = s.length === 10 ? `${s}T00:00:00.000Z` : s;
  const d = new Date(iso);
  return Number.isNaN(d.getTime()) ? null : d;
}
