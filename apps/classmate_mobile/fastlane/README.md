fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios fix_signing

```sh
[bundle exec] fastlane ios fix_signing
```

Headless signing repair: create+install an Apple Distribution cert + App Store provisioning profile via the ASC API key. Run this when the Mac's keychain has lost the distribution cert (export fails with 'No signing certificate "iOS Distribution" found').

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Upload to TestFlight (beta)

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Upload existing IPA to TestFlight (skip build)

### ios release

```sh
[bundle exec] fastlane ios release
```

Build, upload, and submit to App Store review (1-command public release)

----


## Android

### android beta

```sh
[bundle exec] fastlane android beta
```

Distribute via Firebase App Distribution (beta)

### android internal

```sh
[bundle exec] fastlane android internal
```

Build AAB and upload to Play Console INTERNAL testing track

### android closed

```sh
[bundle exec] fastlane android closed
```

Build AAB and upload to Play Console CLOSED testing track (alpha)

### android production

```sh
[bundle exec] fastlane android production
```

Build AAB and roll out to Play Console PRODUCTION

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
