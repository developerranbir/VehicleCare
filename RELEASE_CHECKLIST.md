# VehicleCare release checklist

Native source/configuration is prepared. A successful web build or Capacitor sync is not a native release sign-off. Unchecked items below remain manual or toolchain/device requirements.

## Completed in this Windows run

- [x] Existing shared modules and storage key/schema retained; new optional preference defaults off.
- [x] Matching Capacitor 8 plugins pinned; Android/iOS source projects generated and synced.
- [x] Native production assets bundled with no PWA worker or live-reload URL.
- [x] Responsive navigation/action sheet, safe-area/keyboard layout and platform adapters implemented.
- [x] JSON metadata, native cache/share export, file import preview/merge/replace and rollback implemented.
- [x] Opt-in offline notifications, deterministic IDs, cancellation, 60-event cap and inexact scheduling implemented.
- [x] Original brand icons, adaptive icon, splash variants, Android release signing and iOS privacy resources configured.
- [x] Available TypeScript/lint/unit/browser/build checks executed; see QUALITY.md for actual results and limits.

## Identity and supply chain

- [ ] Finalize owned `appId`, Android application ID and iOS bundle ID; sync and inspect native results.
- [ ] Keep hostname/schemes and published identities stable. Export current records before changing origins.
- [ ] Set release app version, Android versionCode and iOS build number consistently.
- [ ] Reinstall the frozen lockfile on each build host; review dependency/security advisories and licenses.
- [ ] Confirm current Android target/Apple SDK submission rules with official documentation.
- [ ] Keep keystores/passwords/certificates/profiles/accounts outside source and source archives.

## Web/PWA deployment

- [ ] Run `pnpm typecheck`, `pnpm lint`, `pnpm test`, `pnpm build`, `pnpm test:e2e` on release source.
- [ ] Deploy only the **web** `dist/` build to an HTTPS origin root with SPA fallbacks and correct MIME/cache headers.
- [ ] Check manifest, install icons, update prompt and offline reload after precache on the public host.
- [ ] Install with Android browser and iOS Safari Add to Home Screen; verify separate-container backup migration.
- [ ] Test an update over a populated previous version without clearing records or losing drafts to forced reload.

## Android binary/device gates — not performed here

- [ ] Install JDK 21 / SDK 36 / Android Studio; execute `android:apk` and inspect actual output.
- [ ] Inspect Merged Manifest/APK Analyzer: no broad storage, Internet, exact-alarm, location or tracking permissions; only required notification/device integration remains.
- [ ] Test embedded first launch in airplane mode, all CRUD, reload/relaunch and populated version upgrade.
- [ ] Verify modal-first back, keyboard dismissal, history/home/root behavior and system back gestures.
- [ ] Check 320–430 px devices/tablet, gesture/button navigation, Android 15/16 edge-to-edge, cutouts, rotation, keyboard and light/dark bars/splash.
- [ ] Save JSON outside app using a real share target, cancel/fail shares, import files, and verify desktop/PWA↔Android transfers. Confirm exported file exists independently.
- [ ] Verify opt-in/denial/revocation, notification channel, delivery, change/delete/complete/disable cancellation, 60-event cap, reboot, force-stop, battery restrictions and timezone changes.
- [ ] Verify Android backup exclusions on target OS versions and storage-failure recovery.
- [ ] Configure private release signing; build/test signed APK and AAB, then perform Play internal testing and populated upgrades.
- [ ] Complete Play registration, signing, store listing, privacy/Data Safety, screenshots/rating and submission.

## iOS binary/device gates — not performed here

- [ ] On macOS/Xcode 26+, resolve SPM, compile simulator and run on signed physical iPhone/iPad.
- [ ] Test first offline launch, all CRUD, restart persistence and previous-version update retention.
- [ ] Verify notch/Dynamic Island/home indicator, compact phone/tablet, keyboard, rotation and light/dark bars/splash.
- [ ] Export to Files outside the app, cancel/fail shares, import/preview/confirm/rollback and verify Android↔iOS and desktop/PWA↔iOS transfers.
- [ ] Verify notification permission, denial/revocation, delivery/cancellation/limit, Focus and timezone behavior.
- [ ] Inspect privacy manifest/resource compilation, aggregated required-reason report, entitlements and OS backup exclusion.
- [ ] Configure owned bundle ID, Apple team/certificates/profiles; create and validate an actual signed archive.
- [ ] TestFlight test the signed build and populated update; complete App Store registration/privacy/screenshots/rating/submission.

## Data acceptance

- [ ] Check multiple active/archived vehicles and all linked histories after upgrade/transfer.
- [ ] Exercise malformed/oversized/future-schema backups, ID collisions, merge twice and replacement cancellation.
- [ ] Exercise quota/unavailable storage: ordinary edits remain in memory, failed imports keep originals, conflicts require explicit resolution.
- [ ] Confirm file picker/share sheets and all essential modules work offline on each release platform.
- [ ] Clearly communicate that clearing/uninstalling/eviction can erase local records and JSON backups need private external storage.

Record device models, OS versions, build IDs, signing identities (without secrets) and results before approving publication. This run produced no signed APK/AAB/IPA and submitted nothing to a store or public host.
