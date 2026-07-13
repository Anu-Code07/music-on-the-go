#!/usr/bin/env bash
# Aria (music-on-the-go) release build script
# Usage:
#   ./scripts/release.sh              # APK + AAB
#   ./scripts/release.sh apk
#   ./scripts/release.sh aab
#   ./scripts/release.sh android      # APK + AAB
#   ./scripts/release.sh ios          # IPA (needs signing)
#   ./scripts/release.sh ios-nocodesign
#   ./scripts/release.sh all          # Android + iOS IPA
#   ./scripts/release.sh --skip-pre apk

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SKIP_PRE=0
TARGET="android"

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

for arg in "$@"; do
  case "$arg" in
    --skip-pre) SKIP_PRE=1 ;;
    -h|--help) usage ;;
    apk|aab|android|ios|ios-nocodesign|all) TARGET="$arg" ;;
    *)
      echo "Unknown arg: $arg" >&2
      usage
      ;;
  esac
done

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter not found on PATH" >&2
  exit 1
fi

echo "==> Aria release build"
echo "    root:   $ROOT"
echo "    target: $TARGET"
flutter --version | head -n 1

if [[ "$SKIP_PRE" -eq 0 ]]; then
  echo "==> Pre steps"
  flutter pub get
  dart run flutter_launcher_icons || true
  dart run flutter_native_splash:create || true
fi

build_apk() {
  echo "==> Building APK (release)"
  flutter build apk --release
  local out="build/app/outputs/flutter-apk/app-release.apk"
  ls -lh "$out"
  echo "APK: $ROOT/$out"
}

build_aab() {
  echo "==> Building App Bundle (release)"
  flutter build appbundle --release
  local out="build/app/outputs/bundle/release/app-release.aab"
  ls -lh "$out"
  echo "AAB: $ROOT/$out"
}

build_ios() {
  echo "==> Building IPA (release)"
  flutter build ipa --release
  echo "IPA dir: $ROOT/build/ios/ipa"
  ls -lh build/ios/ipa/* 2>/dev/null || true
}

build_ios_nocodesign() {
  echo "==> Building iOS release (no codesign)"
  flutter build ios --release --no-codesign
  echo "APP: $ROOT/build/ios/iphoneos/Runner.app"
}

case "$TARGET" in
  apk) build_apk ;;
  aab) build_aab ;;
  android)
    build_apk
    build_aab
    ;;
  ios) build_ios ;;
  ios-nocodesign) build_ios_nocodesign ;;
  all)
    build_apk
    build_aab
    build_ios
    ;;
esac

echo "==> Done"
