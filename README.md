# Syntropy Health Mobile App

A Flutter mobile application for health journaling with voice notes, offline-first data sync, AI-powered health analysis, and personalized recommendations.

## Features

- **Voice Notes**: Record voice journal entries with automatic transcription via OpenAI Whisper
- **Offline-First**: Local SQLite storage with background sync to Supabase cloud
- **Health Analysis**: AI-powered symptom analysis and health recommendations
- **Smart Notifications**: Contextual health tips, suggestions, and alerts
- **Product Catalog**: Curated health products with Amazon affiliate integration
- **Privacy-Focused**: Data stays on device until explicitly synced

## Architecture

This app follows a **feature-first modular architecture** with clean separation of concerns:

```text
lib/
├── core/                    # Core infrastructure
│   ├── config/              # App configuration
│   ├── di/                  # Dependency injection
│   ├── router/              # Navigation (GoRouter)
│   ├── theme/               # App theme, colors, typography
│   ├── utils/               # Utilities (logger, result types)
│   └── widgets/             # Shared widgets
├── data/                    # Data layer
│   ├── datasources/         # Local DB & remote APIs
│   ├── models/              # Data models (Freezed)
│   └── repositories/        # Repository implementations
└── features/                # Feature modules
    ├── home/                # Dashboard
    ├── voice_notes/         # Voice recording & transcription
    ├── health_analysis/     # AI health insights
    ├── notifications/       # Health alerts
    ├── catalog/             # Product shop
    ├── sync/                # Data synchronization
    └── settings/            # App preferences
```

## Tech Stack

- **State Management**: Riverpod
- **Routing**: GoRouter
- **Local Database**: SQLite (sqflite)
- **Cloud Sync**: Supabase
- **Audio Recording**: record package
- **Transcription**: OpenAI Whisper API
- **Notifications**: flutter_local_notifications
- **Background Tasks**: workmanager

## Getting Started

### Prerequisites

- Flutter 3.2.0 or higher
- Dart 3.0 or higher
- iOS 12.0+ / Android API 21+

### Installation

1. Clone the repository

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Generate code (models, providers):

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Configure environment variables (see Configuration section)

5. Run the app:

   ```bash
   flutter run
   ```

## Configuration

Create a `.env` file or set environment variables:

```bash
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# OpenAI
OPENAI_API_KEY=your_openai_api_key

# Diet Insight API
DIET_INSIGHT_API_URL=http://localhost:8000

# Amazon Affiliate (optional)
AMAZON_ASSOCIATE_TAG=your_amazon_tag
```

Run with environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=OPENAI_API_KEY=...
```

## Database Schema

### Local SQLite Tables

- `voice_notes` - Audio recordings and transcriptions
- `health_journal_entries` - Journal entries (meals, symptoms, etc.)
- `health_recommendations` - AI-generated recommendations
- `products` - Cached product catalog
- `notifications` - App notifications
- `sync_queue` - Pending sync operations

## Key Workflows

### Voice Note to Health Insight

1. User records voice note
2. Audio saved locally
3. Sent to OpenAI Whisper for transcription
4. Transcription stored as journal entry
5. Entry analyzed by Diet Insight Engine
6. Recommendations generated and stored
7. User notified of new insights
8. Data synced to cloud when connected

### Offline-First Sync

1. All data written to local SQLite first
2. Operations queued in `sync_queue`
3. Background worker processes queue when online
4. Conflict resolution (last-write-wins)
5. Cloud state pulled on app launch

## Building for Production

```bash
# Android
flutter build apk --release --dart-define=ENVIRONMENT=production

# iOS
flutter build ios --release --dart-define=ENVIRONMENT=production
```

## Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

## Contributing

1. Follow the existing architecture patterns
2. Add tests for new features
3. Update documentation as needed
4. Use conventional commit messages

## License

Proprietary - Syntropy Health Inc.
