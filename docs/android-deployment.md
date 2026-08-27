# Android deployment

This project has two Android app IDs:

- QA/tester app: `com.nextechvision.insta_attend.test`
- Production app: `com.nextechvision.insta_attend`

For now, publish the QA/tester app to the Google Play `internal` testing track. This is the simplest Play Store compatible tester distribution path and supports auto updates through Google Play.

## One-time local Shorebird setup

Shorebird must create the real app id from your logged-in account. Do this once from the project root:

```bash
shorebird login
shorebird init --force
```

Because this project uses Android flavors, Shorebird should generate app ids for both `qa` and `prod` under `flavors:` in `shorebird.yaml`. Commit the generated `shorebird.yaml` and the `pubspec.yaml` asset entry that Shorebird adds. Do not create `shorebird.yaml` manually.

## One-time Google Play setup

1. In Google Play Console, create a new app for the QA package `com.nextechvision.insta_attend.test`.
2. Complete the required Play Console setup sections: app access, ads, content rating, target audience, data safety, privacy policy, and store listing.
3. Go to Testing > Internal testing, create or select the internal testing track, and add tester email addresses or a Google Group.
4. Upload the first signed AAB manually if Play Console requires it. Codemagic can generate the AAB; download it from the build artifacts and upload it to the internal testing track.
5. After the first release exists in Play Console, Codemagic can publish future internal testing releases automatically.

## One-time Codemagic setup

Add the repository to Codemagic and use `codemagic.yaml`, not the visual workflow editor.

Create these variable groups in Codemagic:

- `shorebird`
  - `SHOREBIRD_TOKEN`: create this in the Shorebird console/account settings.
- `google_play`
  - `GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS`: paste the complete Google Play service account JSON key.

Upload the Android release keystore in Codemagic:

- Distribution > Android code signing
- Reference name: `android_keystore`
- Upload your keystore file and enter the keystore password, key alias, and key password.

Keep your own backup of the keystore. Every future Play Store update must be signed with the same key.

## Google Play API access for Codemagic

1. In Google Cloud Console, enable the Google Play Android Developer API.
2. Create a service account and generate a JSON key.
3. In Google Play Console > Users and permissions, invite the service account email.
4. Grant app permissions for the QA app and allow release management.
5. Paste the JSON key contents into Codemagic as `GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS`.

## Workflows

Use these Codemagic workflows:

- `qa-android-release`: builds the QA flavor, creates a Shorebird release, and publishes the AAB to Play internal testing.
- `qa-android-patch`: creates a Shorebird patch for an already published QA release.
- `prod-android-release`: ready for later; currently publishes production flavor to Play internal testing.
- `prod-android-patch`: ready for later production patching.

For QA releases, Codemagic builds:

```bash
shorebird release android --flavor=qa --target=lib/main_qa.dart
```

For QA patches, Codemagic builds:

```bash
shorebird patch android --release-version=<version> --flavor=qa --target=lib/main_qa.dart
```

## Patch rules

Use Shorebird patches only for Dart-only fixes. Do not patch changes that include:

- Android native code changes under `android/`
- iOS native code changes under `ios/`
- asset additions/removals in `pubspec.yaml`
- dependency changes that require native rebuilds

For those changes, create a new Play Store release instead.

## Recommended first run

1. Run `shorebird init --force` locally and commit its changes.
2. Push the branch to the Git provider connected to Codemagic.
3. In Codemagic, start `qa-android-release` manually.
4. If Google Play rejects automatic publishing because this is the first upload, download the AAB artifact and upload it manually to the QA internal testing track.
5. Install the tester app from the internal testing invite link.
6. Make a small Dart-only text/UI change and run `qa-android-patch` with the release version shown in Shorebird.
