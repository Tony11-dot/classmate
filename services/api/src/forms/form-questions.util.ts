/**
 * Normalize a form's question array to the canonical shape every reader
 * expects. The mobile create/edit screen historically sent questions keyed by
 * `text` (not `title`), with no stable `id`, and `scaleMin/scaleMax` instead of
 * `minScale/maxScale`. Readers key on `id`/`title`/`minScale`, so without this:
 *   - question titles rendered blank,
 *   - the backend built `Required: ${q.title}` → the literal string "undefined",
 *   - answers were keyed by an undefined id, so required questions failed
 *     validation even when answered.
 *
 * Applied on WRITE (create/update — so new forms are stored correctly) and on
 * READ (byId/submit/list — so forms already stored the old way recover). The id
 * fallback is deterministic (`q{index}`) so the id a student's client reads back
 * matches the id `submit` looks up in the answers map for the same stored array.
 */
export function normalizeFormQuestions(raw: any): any[] {
  if (!Array.isArray(raw)) return [];
  return raw.map((q: any, i: number) => {
    const src = q && typeof q === 'object' ? q : {};
    const title = String(src.title ?? src.text ?? src.label ?? '').trim();
    const id = String(src.id ?? '').trim() || `q${i + 1}`;
    const options = Array.isArray(src.options)
      ? src.options.map((o: any) => String(o)).filter((o: string) => o.trim().length > 0)
      : [];
    const minScale = Number(src.minScale ?? src.scaleMin ?? 1) || 1;
    const maxScale = Number(src.maxScale ?? src.scaleMax ?? 5) || 5;
    return {
      ...src,
      id,
      title,
      text: title,
      type: String(src.type ?? 'shortAnswer').trim() || 'shortAnswer',
      required: src.required === true,
      options,
      minScale,
      maxScale,
    };
  });
}
