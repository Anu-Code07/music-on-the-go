# Aria

### music-on-the-go

Offline-first music player — MiniMax light chrome, vibrant product cards, immersive Now Playing, and Live Activities.

<p align="center">
  <img src="docs/screenshots/home.png" alt="Aria Home" width="280" />
  &nbsp;&nbsp;
  <img src="docs/screenshots/now-playing.png" alt="Aria Now Playing" width="280" />
</p>

<p align="center">
  <em>Home — product matrix &amp; discover · Now Playing — art-driven glass controls</em>
</p>

---

## Screenshots

| Home | Now Playing |
|:---:|:---:|
| ![Home](docs/screenshots/home.png) | ![Now Playing](docs/screenshots/now-playing.png) |
| Greeting, colorful Music / Library / EQ cards, recents & Discover rails | Blurred art backdrop, glass scrubber, shuffle · skip · play · repeat |

---

## Quick facts

| | |
|---|---|
| **App name** | Aria |
| **Repo** | [music-on-the-go](https://github.com/Anu-Code07/music-on-the-go) |
| **Flutter package** | `studio` |
| **Bundle / application ID** | `com.anurag.studio` |
| **iOS widget extension** | `com.anurag.studio.AriaWidgets` |
| **App Group** | `group.com.anurag.studio` |
| **Stack** | Flutter · BLoC · GetIt · just_audio · sqflite |

---

## Features

- **Home** — ARIA wordmark, time-based greeting, MiniMax product cards (Music · Library · EQ · Liked), recently played, Discover matrix, liked songs, playlists  
- **Discover** — Jamendo search with frosted glass field + coral **Search** button; Save downloads tracks offline  
- **Library** — local library, likes, file import  
- **Playlists** — create and organize queues  
- **Now Playing** — full-screen immersive player (art blur, glass control sheet, like / shuffle / repeat)  
- **Equalizer** — color band UI; realtime EQ on Android  
- **Live Activities** — iOS Lock Screen + Dynamic Island; Android ongoing now-playing notification  
- **Home widgets** — “Aria Now Playing” on iOS & Android  
- **Seed library** — demo tracks in `assets/seed/` for first launch  

---

## Design

MiniMax-inspired dual identity: stark white marketing chrome + saturated product cards.

| Token | Value |
|---|---|
| Type | DM Sans |
| Canvas | `#FFFFFF` |
| Primary CTA | `#0A0A0A` (black pill) |
| Coral accent | `#FF5530` |
| Product cards | coral · magenta · blue · purple (32px radius) |
| Glass | frosted panels on Discover, mini-player, Now Playing, dock |

Brand colors stay on product-identity moments — not on generic body text or standard buttons.

---

## Architecture

Clean Architecture + BLoC:

```
lib/features/<feature>/
├── data/           # datasources, repository impl
├── domain/         # entities, repositories, usecases
└── presentation/   # bloc, pages, widgets
```

Features: `home` · `player` · `library` · `playlist` · `discover` · `equalizer`  
DI: GetIt · Playback: `just_audio` + `audio_session` · Persistence: sqflite (`studio.db`)

---

## How saving works

1. Discover → **Save** downloads MP3 (+ optional artwork) to `{Documents}/music/{id}.mp3`  
2. Row upserted in SQLite `tracks` with `is_local: true`  
3. Track plays offline from disk  

Play without Save can stream and update recents — it does **not** download the file.

---

## Getting started

```bash
git clone https://github.com/Anu-Code07/music-on-the-go.git
cd music-on-the-go
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter run
```

Requires **Flutter 3.35+** / **Dart 3.9+**.

### iOS Live Activities (one-time)

1. Open `ios/Runner.xcworkspace`  
2. Enable **App Groups** → `group.com.anurag.studio` on **Runner** and **AriaWidgets**  
3. Run on a real device (iOS 16.1+)  

### Android

- Allow notifications for the live now-playing shade  
- Long-press home → widgets → **Aria Now Playing**  

---

## Project layout

```
lib/core/              theme, DI, router, shared widgets
lib/features/          home, player, library, playlist, discover, equalizer
assets/branding/       app icon & splash
assets/seed/           bundled demo audio + art
docs/screenshots/      README images
ios/AriaWidgets/       WidgetKit + ActivityKit
android/.../           StudioPlayerWidget + AriaLiveActivityManager
```

---

## API keys

Jamendo / TheAudioDB keys are in `lib/core/config/api_keys.dart` for local demos.  
**Rotate them** before shipping a public production build.

---

## License

Private / personal project unless otherwise stated.
