# music-on-the-go

**Aria** — a minimal, offline-first local music player with a MiniMax-inspired light UI (white canvas, black pill CTAs, vibrant product cards, glass chrome).

| | |
|---|---|
| **Display name** | Aria |
| **Flutter package** | `studio` |
| **Android / iOS ID** | `com.anurag.studio` |
| **iOS widgets** | `com.anurag.studio.AriaWidgets` |
| **App Group** | `group.com.anurag.studio` |

## Features

- **Home** — greeting hero, MiniMax-style colorful product cards, recents / discover / liked / playlists
- **Discover** — Jamendo search + Save (download to device); glass search bar + coral Search button
- **Library** — local tracks, likes, import
- **Playlists** — create and manage
- **Now Playing** — full-screen immersive art + glass controls
- **Equalizer** — presets; realtime on Android
- **Live Activities** — iOS lock screen / Dynamic Island; Android ongoing notification
- **Home widgets** — Now Playing tile on iOS & Android
- **Seed library** — bundled tracks under `assets/seed/`

## Architecture

Clean Architecture + BLoC under `lib/features/{home,player,library,playlist,discover,equalizer}/`:

```
feature/
├── data/        # datasources, models, repository impl
├── domain/      # entities, repositories, usecases
└── presentation # bloc, pages, widgets
```

DI via GetIt (`lib/core/di/injection.dart`). Playback via `just_audio` + `audio_session`.

## How music is saved

1. Discover → **Save** downloads the MP3 (and optional art) into app documents: `{Documents}/music/{id}.mp3`
2. Metadata is upserted into SQLite (`studio.db` → `tracks`)
3. Track becomes playable offline (`is_local: true`)

Playing without Save can stream / upsert recents; it does **not** download the file.

## Design system (MiniMax)

- **Type:** DM Sans  
- **Canvas:** `#FFFFFF` · **Ink / CTA:** `#0A0A0A` · **Coral:** `#FF5530`  
- **Product colors (cards only):** coral, magenta, blue, purple  
- **Buttons:** pill-shaped (`rounded-full`); black primary, outline secondary  
- **Glass:** frosted panels on Discover, mini-player, Now Playing, dock  

Brand accents are reserved for product-identity moments — not for generic body text.

## Run

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter run
```

Requires Flutter **3.35+** / Dart **3.9+**.

### iOS Live Activities (one-time)

1. Open `ios/Runner.xcworkspace` in Xcode  
2. For **Runner** and **AriaWidgets**: Signing → enable **App Groups** → `group.com.anurag.studio`  
3. Run on a real device (iOS 16.1+) for Live Activities  

### Android widgets / live notification

- Home widget: long-press home → widgets → **Aria Now Playing**  
- Live notification appears while a track is playing (notifications permission may be required)

## Project layout

```
lib/
  core/           # theme, DI, router, shared widgets
  features/       # home, player, library, playlist, discover, equalizer
assets/
  branding/       # app icon + splash
  seed/           # bundled demo tracks
ios/AriaWidgets/  # WidgetKit + ActivityKit
android/.../      # StudioPlayerWidget + AriaLiveActivityManager
```

## API keys

Jamendo / TheAudioDB keys live in `lib/core/config/api_keys.dart` (in-repo for local demos). Rotate them if you publish the repo publicly.

## License

Private / personal project unless otherwise stated.
