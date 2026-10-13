# VehicleCare mobile setup

One `src/` application serves Web/PWA, Android and iOS. Records/settings remain in `vehiclecare:app:v1` localStorage; native plugins only handle device integration. No backend, remote fonts, analytics, push service or business database is required. Internet is needed to download development dependencies and SDKs, not for installed essential app features.

## Install and build

Use Node 22.12+ and pinned pnpm 11.25.0. On this Windows machine, the launcher resolves the bundled Codex runtime without changing your global PATH:

```bat
cd /d "D:\Vechicle Tracker App"
vehiclecare.cmd install --frozen-lockfile
vehiclecare.cmd dev
vehiclecare.cmd typecheck
vehiclecare.cmd lint
vehiclecare.cmd test
vehiclecare.cmd build
vehiclecare.cmd test:e2e
vehiclecare.cmd cap:sync
```

PowerShell: prefix the launcher with `./`. On another machine with Node/pnpm installed, substitute `pnpm` for `vehiclecare.cmd`. The repository contains `android/` and `ios/`; do not run `cap add` again. `cap:sync` builds native assets before syncing both projects. Platform-specific scripts rebuild and sync only their platform. Run `build` again before deploying the web `dist/`, because native mode omits the service worker.

| Script                                  | Purpose                                                            |
| --------------------------------------- | ------------------------------------------------------------------ |
| `dev`, `build`, `preview`               | Web development, static production build, local static preview     |
| `typecheck`, `lint`, `test`, `test:e2e` | TypeScript, lint, unit/component, production Chrome flows          |
| `build:native`                          | Production assets with PWA service worker disabled                 |
| `cap:sync`, `android:sync`, `ios:sync`  | Build first, copy assets and link native dependencies              |
| `native:verify`                         | Check generated source/configuration; does not compile native code |
| `android:open`, `ios:open`              | Open the native IDE                                                |
| `android:run`, `ios:run`                | Sync, then deploy to a selected emulator/device                    |
| `android:apk`                           | Build a debug APK with the Android toolchain                       |
| `android:release-apk`, `android:aab`    | Build signed release APK/AAB with private signing settings         |

See [Android](ANDROID_BUILD.md) and [iOS](IOS_BUILD.md) for native SDK installation and release steps. Capacitor 8 requires recent tools; consult the [official environment setup](https://capacitorjs.com/docs/getting-started/environment-setup) before upgrading them.

## Data and transfers

Browser profiles, origins, installed PWAs and native apps can have different storage containers. Opening a native app does not automatically copy browser records. Keep the configured hostname/schemes and published app ID stable across updates.

1. In the source app, open More → Backup & restore (desktop: Settings → Backup & restore).
2. Export JSON. On web, check Downloads. On native, choose a destination such as Save to Files or another file-saving target in the share sheet. Verify that the file exists outside VehicleCare. A private cache file or a cancelled share is not an external backup.
3. Transfer the file manually to the destination device/container. No server or account is required; you choose the transfer method.
4. Open Backup & restore there, choose the JSON file and inspect its vehicle/record count. Merge retains current settings and remaps colliding IDs/references. Repeated merging creates additional copies. Replace uses the backup's snapshot and needs explicit confirmation; export current data first.
5. Check records and reload/relaunch. Delete private transfer copies only when satisfied with the saved result.

All platforms use the same JSON format: schema version 1, complete records/settings, `exportedAt` and `applicationVersion`. Older supported backups need not have the new metadata or reminder preference. Imports enforce 5 MB / 20,000 business-record limits, valid dates/money/IDs/vehicle relationships and reading consistency. Invalid input or failed import persistence keeps the previous snapshot. Browser tests verify the common format; actual desktop↔Android, PWA↔native and Android↔iOS file-picker/share transfers still need device verification.

Exports use native Cache (`vehiclecare-exports/`), UTF-8 and safe dated filenames. Older export files are cleaned after 24 hours on the next export. Cache is temporary and may be evicted. Business records never move to Filesystem/SQL/IndexedDB. Records and JSON backups are not encrypted. Uninstalling, clearing app/site data, private mode, OS eviction, quotas or device loss may erase records. Normal save failures retain changes in memory with visible retry/backup controls; import failures roll back. Automatic OS cloud backup is disabled/excluded in the native source; verify backup behavior on target OS versions.

## Offline operation

The Web/PWA requires a first complete production visit over HTTPS (or localhost) and the “Ready to go offline” notice. Its shell, lazy charts, fonts and icons are precached; local CRUD works offline. Update prompts preserve the snapshot and block reload while unsaved changes exist. Static hosting must serve SPA routes via `index.html`; see README.

Android/iOS embed a native production build and can open essential features in airplane mode immediately after installation. Native mode never registers the PWA worker. Web keeps BrowserRouter URLs; native uses HashRouter paths against bundled localhost assets. Do not set a production `server.url` or change origin settings for live reload. User-chosen share destinations or telephone actions may have their own connectivity requirements.

## Optional reminders

Web/PWA: in-app maintenance/expiry reminders and all-day ICS export. Native: Settings → Device notifications → Enable device reminders explains the purpose and asks for notification permission. Startup/resume never requests permission. Denial keeps the app usable; grant through OS settings and enable again. Disable cancels app-owned pending/delivered reminders.

Date-based services/custom maintenance, insurance, PUC, warranty and custom document expiry schedule warning and due notifications at approximately **9 AM local time**. Deterministic IDs prevent duplicates. Changed/deleted/completed rules cancel obsolete notifications and recalculate next dates. Archived vehicles are excluded. Up to **60** nearest future events are queued; later events enter when the app next reconciles after earlier events expire. Past times are skipped. A launch, relevant save, resume or detected calendar-day/timezone change reconciles the queue. Timezone changes while the app stays closed can leave old scheduled times until the next resume.

Android uses inexact notifications (`isExactNotification: false`), no special exact-alarm permission and no idle bypass. Delivery can be delayed/suppressed by battery restrictions, force-stop, disabled channels/permissions, iOS Focus, system summaries or OS scheduling. Reboot behavior must be verified on your device. Vehicle names/tasks may appear in notifications depending on lock-screen settings. Local notifications are not guaranteed alarms. [Official plugin documentation](https://capacitorjs.com/docs/apis/local-notifications) describes OS limits and delivery behavior.

Distance-only reminders remain app-open calculations using entered readings. Combined rules schedule the date part; VehicleCare cannot detect mileage reached in the background. There is no background mileage tracker, GPS monitoring, recurring polling server or push service.

## Layout and lifecycle

Mobile bottom navigation exposes Home / Garage / Add / Reminders / More; the desktop sidebar appears at wider widths. Safe-area CSS uses browser `env()` plus Capacitor SystemBars insets. Keyboard resize/hide events keep fields and bottom sheets usable; keyboard-open state hides the mobile navigation. Light/dark/system UI is applied to native system bars and iOS keyboard appearance.

Android back first dismisses a registered modal, then hides the keyboard, then navigates application history. An initial nested route returns to Home; Home minimizes the app. Native event listeners clean up on unmount, including late attachment. Resume refreshes saved state/reminder calculations and preserves live form drafts; a process killed by the OS loses unsubmitted drafts. Storage conflicts or missing saved data preserve memory and show recovery actions.

## Troubleshooting

- **`pnpm` not recognized:** run the Windows launcher above; on other machines install Node/pnpm first. Reopen a terminal after changing its PATH.
- **Old UI on device:** run `android:sync` or `ios:sync`, then rebuild/reinstall through the native IDE. A web build alone does not update installed binaries.
- **Missing iOS packages after moving machines:** install the frozen lockfile, run `ios:sync`, reopen Xcode and resolve Swift packages. The CLI regenerates pnpm package paths; do not hand-edit the generated SPM file.
- **Native backup share fails:** try again and inspect the visible error; verify the share target can save files. Android FileProvider exposes only the export cache directory. No broad storage permission is needed.
- **Reminder absent:** check opt-in, permission/channel, future date, 60-event limit, battery/Focus settings, and resume. Mileage requires a new reading. Use the in-app list as the authoritative care planner.
- **Blank/overlapped native page:** check embedded `public/index.html`, plugin sync, origin settings and release logs. Test status/navigation bars, notches, rotation and keyboard on the actual OS; browser emulation alone cannot verify them.

The Windows verification covers browser behavior, plugin mocks, native asset sync and source checks. APK/AAB/IPA compilation, real share sheets, permissions, safe areas, OS notifications and actual device transfers remain explicit gates in [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md).
