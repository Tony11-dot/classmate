API_URL ?= http://localhost:3001
API_URL_DEVICE ?= http://Tonys-MacBook-Air.local:3001

# ── Simulator (localhost) ─────────────────────────────────────────────────────
student:
	flutter run \
		--dart-define=CM_DEV_TOKEN=dev-token-student@classmate.local \
		--dart-define=CM_API_BASE_URL=$(API_URL)

teacher:
	flutter run \
		--dart-define=CM_DEV_TOKEN=dev-token-teacher@classmate.local \
		--dart-define=CM_API_BASE_URL=$(API_URL)

admin:
	flutter run \
		--dart-define=CM_DEV_TOKEN=dev-token-admin@classmate.local \
		--dart-define=CM_API_BASE_URL=$(API_URL)

parent:
	flutter run \
		--dart-define=CM_DEV_TOKEN=dev-token-parent@classmate.local \
		--dart-define=CM_API_BASE_URL=$(API_URL)

# ── Physical device (local network) ──────────────────────────────────────────
student-device:
	flutter run \
		--dart-define=CM_DEV_TOKEN=dev-token-student@classmate.local \
		--dart-define=CM_API_BASE_URL=$(API_URL_DEVICE)

teacher-device:
	flutter run \
		--dart-define=CM_DEV_TOKEN=dev-token-teacher@classmate.local \
		--dart-define=CM_API_BASE_URL=$(API_URL_DEVICE)

# ── Utilities ────────────────────────────────────────────────────────────────
analyze:
	flutter analyze --no-fatal-infos

clean:
	flutter clean && flutter pub get

build-ios:
	flutter build ios --dart-define=CM_API_BASE_URL=$(API_URL)

.PHONY: student teacher admin parent student-device teacher-device analyze clean build-ios
