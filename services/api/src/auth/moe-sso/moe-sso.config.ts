/**
 * Ministry of Education (MoE) SSO — configuration.
 *
 * This is a *scaffold*: a standard OpenID Connect Authorization-Code flow that
 * stays completely inert until it's both switched on (MOE_SSO_ENABLED=1) and
 * given real credentials + endpoints from the Ministry. Nothing here runs, and
 * no route does anything, while it's unconfigured — so it's safe to ship now
 * and finish the moment the Ministry hands over the details.
 *
 * TO GO LIVE (what the Ministry must provide):
 *   MOE_SSO_CLIENT_ID       — the OAuth client id they issue for ClassMate
 *   MOE_SSO_CLIENT_SECRET   — the matching client secret
 *   MOE_SSO_AUTH_URL        — their authorization endpoint (where we send users)
 *   MOE_SSO_TOKEN_URL       — their token endpoint (code -> tokens)
 *   MOE_SSO_USERINFO_URL    — their userinfo endpoint (tokens -> profile)
 *   MOE_SSO_REDIRECT_URI    — our callback, must be registered with them, e.g.
 *                             https://<api-host>/auth/moe/callback
 *   MOE_SSO_SCOPES          — space-separated (default "openid profile email")
 *   MOE_SSO_ENABLED=1       — the master switch
 * Optional:
 *   MOE_SSO_IDENTIFIER_CLAIM — which userinfo claim uniquely identifies the
 *                              person (default "email"; the Ministry may instead
 *                              use a national-id / "sub" claim — confirm this)
 *   MOE_SSO_POST_LOGIN_REDIRECT — app URL to bounce back to with the session
 *                                 token (e.g. https://classmateapp.org/app or a
 *                                 mobile deep link). When unset the callback
 *                                 returns JSON { token }.
 */
export interface MoeSsoConfig {
  clientId: string;
  clientSecret: string;
  authUrl: string;
  tokenUrl: string;
  userInfoUrl: string;
  redirectUri: string;
  scopes: string;
  identifierClaim: string;
  postLoginRedirect: string | null;
}

function envStr(key: string): string {
  return (process.env[key] ?? '').trim();
}

export function readMoeSsoConfig(): MoeSsoConfig {
  return {
    clientId: envStr('MOE_SSO_CLIENT_ID'),
    clientSecret: envStr('MOE_SSO_CLIENT_SECRET'),
    authUrl: envStr('MOE_SSO_AUTH_URL'),
    tokenUrl: envStr('MOE_SSO_TOKEN_URL'),
    userInfoUrl: envStr('MOE_SSO_USERINFO_URL'),
    redirectUri: envStr('MOE_SSO_REDIRECT_URI'),
    scopes: envStr('MOE_SSO_SCOPES') || 'openid profile email',
    identifierClaim: envStr('MOE_SSO_IDENTIFIER_CLAIM') || 'email',
    postLoginRedirect: envStr('MOE_SSO_POST_LOGIN_REDIRECT') || null,
  };
}

/**
 * Enabled only when the master switch is on AND every required field is set.
 * Fail-closed: a half-configured integration stays off rather than issuing a
 * broken redirect.
 */
export function isMoeSsoEnabled(cfg: MoeSsoConfig = readMoeSsoConfig()): boolean {
  if (process.env.MOE_SSO_ENABLED !== '1') return false;
  return Boolean(
    cfg.clientId &&
      cfg.clientSecret &&
      cfg.authUrl &&
      cfg.tokenUrl &&
      cfg.userInfoUrl &&
      cfg.redirectUri,
  );
}
