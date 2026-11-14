# Repository Guidelines

## Project Structure & Module Organization

This repository is a cross-platform Flutter app. App code lives in `lib/`: `screens/` contains feature pages, `widgets/` reusable UI, `providers/` app state, `services/` API/auth/health/storage integrations, `models/` data types, and `core/` shared theme and constants. App setup and navigation are in `lib/main.dart`, `lib/app.dart`, and `lib/router/`. The `test/` directory contains Flutter tests. Platform-specific runners and assets are under `android/`, `ios/`, `web/`, `linux/`, `macos/`, and `windows/`.

## Build, Test, and Development Commands

- `flutter pub get` resolves packages from `pubspec.yaml`.
- `flutter run` launches the app on a connected device or selected simulator.
- `flutter analyze` runs the Dart analyzer with the rules in `analysis_options.yaml`.
- `flutter test` runs tests under `test/`.
- `flutter build apk` builds an Android APK; use `flutter build ios` for an iOS build on macOS.

## Coding Style & Naming Conventions

Follow the Flutter/Dart conventions and `flutter_lints` configuration. Format Dart changes with `dart format lib test`. Use `snake_case.dart` filenames, `UpperCamelCase` for types, and `lowerCamelCase` for members and variables. Keep feature-specific screens in their matching `lib/screens/<feature>/` directory, and extract UI shared across screens into `lib/widgets/`. Prefer the existing Provider-based state pattern and service/model boundaries when adding functionality.

## Testing Guidelines

Use `flutter_test` and place tests in `test/`, with descriptive names ending in `_test.dart`. Widget tests should verify user-visible behavior and use the app's existing test conventions. Run `flutter test` after changes that affect app behavior; no project-wide coverage threshold is configured.

## Commit & Pull Request Guidelines

Recent commits use short, direct subjects, including imperative summaries and Conventional Commit prefixes such as `feat:`. Keep each commit focused and describe its user-facing or technical change. Pull requests should summarize the change, note relevant validation commands and results, link related issues when available, and include screenshots for UI changes.

## Configuration & Generated Files

Keep package declarations in `pubspec.yaml` and commit the corresponding `pubspec.lock` updates. Do not commit secrets or machine-specific configuration. Avoid hand-editing generated platform files unless the change specifically requires platform integration.
