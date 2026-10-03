import { ClassNotesAccountService } from './classnotes-account.service';
import { classNotesResetPage } from './classnotes-reset-page';

/// The reset page is the one piece of this auth system that is HTML, and the one
/// place a token taken straight off a query string is written into a document.
describe('ClassNotes reset page', () => {
  it('carries the token into the page so the form can post it back', () => {
    const html = classNotesResetPage('abc123');
    expect(html).toContain('var TOKEN = "abc123";');
    expect(html).toContain("fetch('reset-password'");
  });

  it('posts to the endpoint that consumes CLASSNOTES tokens, not ClassMate ones', () => {
    // A relative 'reset-password' resolves against /classnotes/auth/reset, so
    // the page cannot drift onto /auth/reset-password, which reads a different
    // table and would refuse every token this page is ever given.
    const html = classNotesResetPage('abc123');
    expect(html).not.toContain('/auth/reset-password');
  });

  it('escapes a token that tries to close the script tag', () => {
    const html = classNotesResetPage('"); alert(1); //</script><script>evil()</script>');
    expect(html).not.toContain('</script><script>evil()');
    expect(html).not.toContain('alert(1); //<');
    // Exactly one script element: the page's own.
    expect(html.match(/<script/g)).toHaveLength(1);
    expect(html.match(/<\/script>/g)).toHaveLength(1);
  });

  it('escapes the line separators that break a JS string literal invisibly', () => {
    // U+2028 and U+2029 survive JSON.stringify untouched and then end the line
    // inside the script, so they are written out as escapes explicitly.
    const token =
      'a' + String.fromCharCode(0x2028) + 'b' + String.fromCharCode(0x2029) + 'c\nd';
    const html = classNotesResetPage(token);
    expect(html).toContain('var TOKEN = "a\\u2028b\\u2029c\\nd";');
    expect(html).not.toContain(String.fromCharCode(0x2028));
    expect(html).not.toContain(String.fromCharCode(0x2029));
  });

  it('renders a usable page even with no token at all', () => {
    const html = classNotesResetPage('');
    expect(html.startsWith('<!doctype html>')).toBe(true);
    expect(html).toContain('var TOKEN = "";');
  });

  it('is self-contained — nothing to fetch from another host to render it', () => {
    const html = classNotesResetPage('abc123');
    expect(html).not.toContain('<link');
    expect(html).not.toContain('src=');
  });
});

describe('ClassNotesAccountService.resetPageBase', () => {
  const saved = { ...process.env };

  afterEach(() => {
    process.env = { ...saved };
  });

  it('points at this API\'s own reset page by default', () => {
    delete process.env.CLASSNOTES_RESET_URL_BASE;
    delete process.env.PUBLIC_API_URL;
    delete process.env.PUBLIC_APP_URL;
    expect(ClassNotesAccountService.resetPageBase()).toBe(
      'https://pacific-enchantment-production-7a80.up.railway.app/classnotes/auth/reset',
    );
  });

  it('follows the deploy\'s public URL, trailing slash or not', () => {
    delete process.env.CLASSNOTES_RESET_URL_BASE;
    process.env.PUBLIC_API_URL = 'https://api.example.com/';
    expect(ClassNotesAccountService.resetPageBase()).toBe(
      'https://api.example.com/classnotes/auth/reset',
    );
  });

  it('lets an explicit override replace the whole path', () => {
    process.env.CLASSNOTES_RESET_URL_BASE = 'https://classnotes.example.com/reset/';
    expect(ClassNotesAccountService.resetPageBase()).toBe(
      'https://classnotes.example.com/reset',
    );
  });
});
