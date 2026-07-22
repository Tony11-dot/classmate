import { Controller, Get } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { Public } from '../auth/decorators/public.decorator';

/// Highest mobile build shipped to the stores. The app compares its own build
/// number against this on launch and offers an update when it's behind.
/// Bumped as part of the release runbook (docs/SHIPPING.md) alongside
/// pubspec.yaml; the MOBILE_LATEST_BUILD env var overrides it so the prompt
/// can be steered (or silenced with 0 → falls back here) without a deploy.
const FALLBACK_LATEST_MOBILE_BUILD = 239;

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
        // Pre-App-Store phase: deep-link opens the TestFlight app, where the
        // new build appears with its own Update button.
        iosUrl: process.env.MOBILE_IOS_UPDATE_URL ?? 'itms-beta://',
      },
    };
  }
}
