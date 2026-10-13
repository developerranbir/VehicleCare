# VehicleCare Android build and release

The generated Capacitor 8 project is `android/`. This Windows run did not have JDK/SDK/Android Studio or an emulator; source sync/configuration passed, but Gradle compilation, merged manifest and actual device behavior are **not verified**. No APK/AAB has been created.

## Toolchain

Install Node 22.12+, pnpm 11.25.0, Android Studio 2025.2.1+ (or a compatible newer release), **JDK 21**, Android SDK Platform 36, platform-tools and build-tools selected by Android Studio. The project has compile/target SDK 36, minimum SDK 24, Gradle wrapper 8.14.3 and Android Gradle Plugin 8.13.0. The [Capacitor environment guide](https://capacitorjs.com/docs/getting-started/environment-setup) explains tool setup. Confirm the latest [Google Play target requirements](https://developer.android.com/google/play/requirements/target-sdk) before submission.

Set `JAVA_HOME` to the actual JDK directory, and `ANDROID_HOME` to the SDK directory, or let Android Studio create private `android/local.properties` with `sdk.dir`. Add platform-tools to PATH for `adb`. No SDK-specific machine path is committed. Set Android Studio's Gradle JDK to the same JDK. First builds download Maven/Gradle dependencies; installed app operation is offline.

```bat
cd /d "D:\Vechicle Tracker App"
vehiclecare.cmd install --frozen-lockfile
vehiclecare.cmd android:sync
vehiclecare.cmd android:open
vehiclecare.cmd android:run
vehiclecare.cmd android:apk
```

Use `./vehiclecare.cmd` in PowerShell or `pnpm` on other configured hosts. `android:run` selects a connected emulator/device. The APK script rebuilds/syncs first, checks Java/SDK availability, then executes `assembleDebug`.

Debug output: `android/app/build/outputs/apk/debug/app-debug.apk`.

```bat
adb install -r "android\app\build\outputs\apk\debug\app-debug.apk"
```

Run with airplane mode on, create/edit records, force-close/reopen and test export/import through a real share/file picker. Repeat on a small screen and Android 15/16 edge-to-edge device. Verify modal → keyboard → history → root back behavior and gesture navigation.

## Identity and signing

**com.vehiclecare.app is a placeholder.** Before the first published build, choose a reverse-domain identifier you own. Set `appId` in `capacitor.config.ts`, `applicationId` in `android/app/build.gradle`, and `package_name`/`custom_url_scheme` in `android/app/src/main/res/values/strings.xml`. The internal Java namespace can stay `com.vehiclecare.app`; if changing namespace too, update `MainActivity.java` package/path and native references together. Re-sync, build, and check the final merged application ID. The source verification script compares the application ID with Capacitor. Published IDs/signing keys should not change across updates.

Keep the signing keystore outside this repository and back it up securely. Generate/manage it using Android Studio's **Build → Generate Signed App Bundle or APK**, or your organization's signing process. Do not commit keys, passwords, `local.properties`, Play credentials or service-account files.

Release Gradle configuration accepts all four environment variables:

```text
VEHICLECARE_KEYSTORE       absolute path to the keystore
VEHICLECARE_STORE_PASSWORD private store password
VEHICLECARE_KEY_ALIAS      selected signing alias
VEHICLECARE_KEY_PASSWORD   private key password
```

Alternatively put `vehiclecareKeystore`, `vehiclecareStorePassword`, `vehiclecareKeyAlias`, `vehiclecareKeyPassword` in your private user `~/.gradle/gradle.properties`; use forward slashes for Windows keystore paths. Inject passwords through a secret manager/session rather than committing shell scripts. Release tasks fail clearly until every signing value is supplied. No development/debug signing identity is substituted for release.

Increment `versionCode` for every Play upload and set `versionName` in `android/app/build.gradle`. Update `package.json` version for backup metadata. Then:

```bat
vehiclecare.cmd typecheck
vehiclecare.cmd lint
vehiclecare.cmd test
vehiclecare.cmd android:release-apk
vehiclecare.cmd android:aab
```

Signed APK: `android/app/build/outputs/apk/release/app-release.apk`.
Signed AAB: `android/app/build/outputs/bundle/release/app-release.aab`.

In Android Studio, open the synced project, choose **Generate Signed App Bundle or APK → Android App Bundle**, select the private keystore and release variant. The same signing fields must be available to Gradle. Test signed builds and updates over an existing installation before distribution.

## Security, permissions and Play release

Production has no external server URL, cleartext traffic or WebView debugging. The app manifest removes `INTERNET`, legacy broad storage and both exact-alarm permissions from plugin merges. Notification-related `POST_NOTIFICATIONS`, reboot receiver/wake handling originate in the official plugin. Permission is requested only when the user enables reminders. No location, contacts, photos, microphone, background location or analytics permission is added. Inspect Android Studio's **Merged Manifest** and APK Analyzer after compilation: source checks cannot validate the merge.

Files are shared through a non-exported FileProvider limited to `cache/vehiclecare-exports/`, with temporary URI grants; file imports use the system picker. Automatic Android cloud backups are disabled and data extraction rules exclude app domains. No Firebase/Google Services plugin is configured. Native local notifications are explicitly inexact. Confirm delivery/cancellation/denial, reboot and force-stop behavior on a real OS.

Create/verify the Play developer account and app listing manually. Enroll in Play App Signing, preserve the upload key, upload the actual signed AAB to internal testing, and complete testing, screenshots, content rating, Data Safety and privacy policy before promotion. Describe local-only data, user-chosen exported files and optional notifications accurately. Store review may require additional disclosures or eligibility steps; this project cannot complete account/signing/submission without your identities. Use [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) as the release gate.

If the build fails: check Java/SDK paths, accept required SDK licenses through Android Studio, sync frozen dependencies, inspect Gradle's first error and verify the keystore path/alias. Re-run `android:sync` after shared source changes. Do not work around missing toolchains by claiming an artifact exists.
