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
const FALLBACK_LATEST_MOBILE_BUILD = 279;

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
        latestBuild,
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
