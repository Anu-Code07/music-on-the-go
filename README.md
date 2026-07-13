# music-on-the-go

**Aria** — minimal local music player with a MiniMax-inspired light design system.

## Brand

- **Name:** Aria  
- **Mark:** Black geometric A + coral note accent on white (`assets/branding/app_icon.png`)  
- **Type:** DM Sans  
- **Chrome:** White canvas, near-black `#0A0A0A` pill CTAs, coral `#FF5530` accents  
- **Splash:** White field, mark, ARIA wordmark, coral rule  

## Run

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter run
```

## Features

- Local / offline-first library (Jamendo discover + download)
- Clean Architecture + BLoC
- Home, Discover, Library, Playlists, Now Playing, equalizer-lite
- iOS Live Activities + Dynamic Island, Android live notification
- Home screen widgets (iOS / Android)
