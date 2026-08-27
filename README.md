# insta_attend

A flutter project for

## Flavors

Run QA:

```bash
flutter run --flavor qa -t lib/main_qa.dart
```

In IntelliJ IDEA, select the `Insta Attend QA` run configuration.

Run production:

```bash
flutter run --flavor prod -t lib/main_prod.dart
```

In IntelliJ IDEA, select the `Insta Attend Prod` run configuration.

Build QA APK:

```bash
flutter build apk --flavor qa -t lib/main_qa.dart
```

Build production APK:

```bash
flutter build apk --flavor prod -t lib/main_prod.dart
```

QA uses `https://test-api.ams.instagrp.in/api/`.
Production uses `https://api.ams.instagrp.in/api/`.

## Android deployment

Android tester releases and Shorebird patching are configured in `codemagic.yaml`.
Follow `docs/android-deployment.md` for the first-time Google Play, Codemagic, and Shorebird setup.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
