# Betty App

Flutter mobile app for monitoring and controlling the Betty camper van. It connects to [Betty Server](../betty-server/README.md) and provides a unified interface for all on-board systems.

## Features

- **Home dashboard** — battery status and quick actions
- **Camera** — live video stream from on-board cameras
- **Map** — vehicle location on an interactive map
- **Lights** — interior and exterior light control with 3D model viewer
- **Alarm** — arm/disarm and sensor status
- **Notifications** — push alerts via Firebase Cloud Messaging
- **Terminal** — remote SSH access to the Raspberry Pi

## Requirements

- Flutter SDK 3.9+
- Dart SDK 3.9+
- Xcode (iOS) or Android Studio (Android)
- A running Betty Server instance

## Setup

```bash
cd apps/betty_app

# Install dependencies
flutter pub get

# Create environment file
cp .env.example .env
# Required: API base URL and JWT configuration
```

Configure Firebase for push notifications using the platform-specific files already in the project (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`).

## Commands

Run these from the **monorepo root**:

| Command | Description |
|---|---|
| `npm run betty-app` | Run on a connected device/emulator |
| `npm run betty-app:dev` | Run in debug mode |
| `npm run betty-app:build` | Build Android APK |

Or from `apps/betty_app` directly:

| Command | Description |
|---|---|
| `flutter run` | Run the app |
| `flutter test` | Run tests |
| `flutter analyze` | Static analysis |
| `flutter build apk --release` | Build Android release |
| `flutter build ios --release` | Build iOS release |

## Project structure

```
lib/
├── alarm/          # Alarm control
├── camera/         # Live camera streams
├── home/           # Dashboard
├── lights/         # Light controls
├── map/            # GPS map
├── notifications/  # Push notifications
├── terminal/       # SSH terminal
└── shared/         # Theme, navigation, widgets
```
