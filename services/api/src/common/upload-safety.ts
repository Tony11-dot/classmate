import type { Response } from 'express';

/**
 * Uploaded files are user-supplied content served from the API's own origin.
 * A file a browser would EXECUTE on navigation (SVG/HTML/XML can carry
 * scripts) is a stored-XSS vector, so those are forced to download with all
 * script rights stripped. Everything users actually share — images, PDFs,
 * audio/video, office docs — is untouched and keeps rendering inline.
 *
 * Embedding is also unaffected: browsers ignore Content-Disposition for
 * subresources (<img src=…>), and a response CSP only governs document loads.
 */
const ACTIVE_CONTENT_EXT = /\.(svgz?|html?|xhtml|xml|js|mjs)$/i;

/** Mimes refused outright at upload time (attachment endpoint). */
export const ACTIVE_CONTENT_MIME =
  /^(text\/html|application\/xhtml\+xml|image\/svg|text\/xml|application\/xml|text\/javascript|application\/(javascript|ecmascript))/i;

export function hasActiveContentExtension(fileName: string): boolean {
  return ACTIVE_CONTENT_EXT.test(fileName);
}

/** `setHeaders` hook for the express/serve-static handlers on /uploads. */
export function setUploadSafetyHeaders(res: Response, filePath: string): void {
  if (hasActiveContentExtension(filePath)) {
    res.setHeader('Content-Security-Policy', "default-src 'none'; sandbox");
    res.setHeader('Content-Disposition', 'attachment');
  }
}
