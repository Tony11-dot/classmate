import { Controller, Get } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { Public } from '../auth/decorators/public.decorator';

/// Highest mobile build LIVE on the PUBLIC stores (App Store / Play production),
/// not merely uploaded. The app compares its own build number against this on
/// launch and offers an update when it's behind, so it must only advance once a
/// build is actually downloadable — otherwise users are nudged toward a version
/// they can't get yet.
///
/// The MOBILE_LATEST_BUILD env var overrides this (or silences the prompt with
/// 0), so the go-live flip needs NO deploy: the moment a build clears App Store
/// review AND Play production rollout, set MOBILE_LATEST_BUILD=<build> on
/// Railway and every stale client starts prompting. This constant is only the
/// floor when the env var is unset — keep it at the last build known public.
const FALLBACK_LATEST_MOBILE_BUILD = 286;

/// Per-store floors — the two stores don't release in lockstep (App Store
/// 1.1.8+287 went live 2026-10-04 while Play production is still on 286), so a
/// single number either nags Android users toward a build Play doesn't have
/// or leaves iOS users un-nudged. Env: MOBILE_LATEST_BUILD_IOS / _ANDROID.
const FALLBACK_LATEST_IOS_BUILD = 287;
const FALLBACK_LATEST_ANDROID_BUILD = 286;

function buildFromEnv(name: string, fallback: number): number {
  const v = Number(process.env[name] ?? '');
  return Number.isFinite(v) && v > 0 ? v : fallback;
}

@Public()
@SkipThrottle()
@Controller()
export class VersionController {
  @Get('version')
  getVersion() {
    const envBuild = Number(process.env.MOBILE_LATEST_BUILD ?? '');
    const latestBuild =
      Number.isFinite(envBuild) && envBuild > 0
        ? envBuild
        : FALLBACK_LATEST_MOBILE_BUILD;
    return {
      ok: true,
      service: 'classmate-api',
      ts: new Date().toISOString(),
      mobile: {
        // Legacy single value — older app builds only read this one, so keep
        // it at the build BOTH stores have.
        latestBuild,
        iosLatestBuild: buildFromEnv('MOBILE_LATEST_BUILD_IOS', FALLBACK_LATEST_IOS_BUILD),
        androidLatestBuild: buildFromEnv('MOBILE_LATEST_BUILD_ANDROID', FALLBACK_LATEST_ANDROID_BUILD),
        // Store destinations for the in-app update prompt. Env-overridable so
        // e.g. the iOS link can flip from TestFlight to the App Store page on
        // public launch without an app update.
        androidUrl:
          process.env.MOBILE_ANDROID_UPDATE_URL ??
          'https://play.google.com/store/apps/details?id=com.tonyaboud.classmate',
        // ClassMate is publicly on the App Store (id6771313687), so the update
        // prompt jumps straight to the store listing — iOS opens this https
        // apps.apple.com link in the App Store app, where the latest approved
        // build shows its own Update button. Env-overridable to flip back to a
        // TestFlight deep-link (itms-beta://) during a beta-only phase.
        iosUrl:
          process.env.MOBILE_IOS_UPDATE_URL ??
          'https://apps.apple.com/app/id6771313687',
      },
    };
  }
}
