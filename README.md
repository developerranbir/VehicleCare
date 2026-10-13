# VehicleCare — Your Vehicle. Your Care.

A private vehicle manager for responsive Web/PWA and Capacitor Android/iOS, built from one React/TypeScript source directory. Every business record lives in a single validated localStorage snapshot. No login, backend, business-data API, analytics, cloud database, or automatic data upload. Native binaries require the toolchains and release checks below; source generation alone is not device verification.

## Run locally

On this Windows machine, Node.js and pnpm are bundled with Codex but may not be on the PATH of a regular terminal. The included launcher finds that runtime and sets PATH only for its own process:

```bat
cd /d "D:\Vechicle Tracker App"
vehiclecare.cmd install --frozen-lockfile
vehiclecare.cmd dev
```

In PowerShell use `./vehiclecare.cmd` instead of `vehiclecare.cmd`. Running the launcher without arguments starts the development app. It also accepts `build`, `preview`, `test`, `lint`, and other pnpm commands. On machines without the bundled runtime it uses Node.js and pnpm already available on PATH. It does not change global environment settings.

Use Node.js 22.12+ (Node.js 24 recommended) and pnpm 11.25.0.

```sh
pnpm install --frozen-lockfile
pnpm dev
```

Open the URL printed by Vite. The welcome screen lets you choose currency, kilometres/miles, English/Hindi, add your first vehicle, or import a backup. **Explore with demo data** is explicit and merges example records; real vehicles are never overwritten by demo mode.

```sh
pnpm typecheck
pnpm lint
pnpm test
pnpm build
pnpm preview --port 4173
```

The production app is in `dist/`. Preview serves these static files; it is not an application backend. Development mode does not register the production service worker. Test offline behaviour against the production preview or HTTPS deployment.

## Implemented features

- **Onboarding and overview:** privacy explanation, preferences, optional restore, vehicle filter, current odometers, monthly expenditure, full-tank efficiency, upcoming care/expiry alerts, recent activity, cost charts, quick-add dialogs/mobile sheets.
- **Garage:** cars, motorcycles, scooters, other vehicles; create, edit, details, archive/restore; ownership details, notes, controlled odometer corrections. Archiving is soft deletion and keeps linked records.
- **Fuel:** create/edit/delete, date, reading, litres, cost, full/partial tank, location, trip links. Efficiency includes partial fills between consistent full tanks.
- **EV charging:** kWh purchased, charge cost, optional odometer, date, location, trip links. No claim that purchased energy equals driving consumption.
- **Services and maintenance:** tasks, parts/labour/other costs, service centre, history; date, distance, or combined schedules; baseline, last completion, per-rule warnings. Completing maintenance saves service and updates both intervals in one transaction.
- **Expenses:** independent expenses and a derived unified ledger. Fuel, charge, and service costs enter exactly once. Linked trips and renewal history do not add duplicate amounts.
- **Renewals:** insurance, PUC, warranty/custom expiry, warning thresholds, renewal history, ICS all-day calendar export. A recorded renewal cost creates one independent expense.
- **Trips:** purpose/title, dates, start/end readings, calculated distance, notes, linked costs. Removing a trip unlinks costs instead of deleting them.
- **Manual checklist:** configurable items, OK/Attention/Unchecked, dates, notes, quick completion; no automated mechanical diagnosis.
- **Emergency:** local contacts, optional phone links, breakdown notes and a bundled basic checklist.
- **Reports:** date/vehicle filters, monthly cost area chart, category donut, vehicle comparison, fuel efficiency chart and recent intervals, service history, recorded cost per km/mile, CSV ledger export. Insufficient data is explicitly unavailable.
- **Settings:** English/Hindi interface and locally bundled Latin/Devanagari fonts; INR/USD/EUR/GBP; km/mi; light/dark/system themes; default vehicle, warnings, storage information, demo data, confirmed full-data deletion.
- **Backup/recovery:** complete JSON export, validated import, merge/replace preview and confirmation, ID/reference collision remapping, raw corrupted-data download, preservation of originals on import failure.
- **PWA:** manifest, 192/512 PNG icons, asset-only service-worker precache, app-shell navigation fallback, install guidance, offline CRUD, and safe update prompts. Updates do not clear records; update/reload is disabled while changes are unsaved.

All requested routes are implemented under `/dashboard`, `/garage`, `/fuel`, `/charging`, `/services`, `/maintenance`, `/expenses`, `/renewals`, `/trips`, `/reports`, `/checklists`, `/emergency`, `/settings`, `/settings/backup`, and `/about`, including new/edit/detail garage routes and not-found handling. `/` is a dashboard alias after onboarding.

The mobile extension also provides `/more` and `/reminders` without changing existing module paths.

## Architecture and rules

Phones and tablets use Home, Garage, Add, Reminders and More bottom navigation. Add opens a focus-trapped action sheet with vehicle, fuel, charging, service, expense, trip and odometer actions. Desktop keeps the sidebar. Shared layouts handle safe-area insets, keyboard resizing, stacked records, readable form inputs and accessible chart summaries.

`src/platform/` centralizes capability detection, lifecycle/back events, system bars, file/share exports and optional notifications. Android back closes the top dialog, then keyboard, then application history; an initial nested route returns home and the root minimizes the app. Resume refreshes the saved snapshot and reminders without remounting form drafts. Drafts survive a pause in the running process, not an OS process termination.

The native app uses a HashRouter on a stable bundled origin (`https://localhost` on Android, `capacitor://localhost` on iOS). Web keeps its existing BrowserRouter routes. `build:native` disables PWA service-worker generation; `cap:sync` builds first and replaces both embedded asset sets. Production configuration has no live-reload URL. Changing the native hostname/scheme or published app ID can strand existing storage.

`src/features/` holds feature screens. `src/components/ui/` holds locally owned shadcn-style Button/Dialog components built with Radix, CVA and Tailwind; `components.json` and the `@/` alias support extending them. `src/lib/model.ts` defines Zod schemas; `storage.ts` is the centralized adapter; `store.ts` manages committed transactions, in-memory recovery, and cross-tab updates. Pure calculations live in `calculations.ts`, and download escaping in `export.ts`.

Stack: React, strict TypeScript, Vite, Tailwind CSS, Radix/shadcn component patterns, React Router, Zustand, Zod, React Hook Form, Recharts, Lucide, date-fns, vite-plugin-pwa/Workbox, Vitest, Testing Library, and Playwright. Dependencies are pinned and the lockfile is committed as source.

- Key: **`vehiclecare:app:v1`**. Snapshot includes schema version, revision, writer ID, ISO timestamps, settings/contacts, vehicles, fuel logs, charging logs, services, maintenance rules, independent expenses, renewals/history, trips, and checklist entries.
- IDs use `crypto.randomUUID()` or a local fallback. Money uses integer minor units. Canonical distances are kilometres; dates are calendar-valid `YYYY-MM-DD` values. UI formatting uses `Intl` with the selected locale and units.
- Form drafts stay in component memory. Submission validates entries, chronological readings, current readings, IDs and same-vehicle references before saving. No snapshot is written for ordinary input keystrokes.
- Fuel economy = distance from previous full tank / litres added **after** it through the next full tank. Partial fills count; the previous full-tank amount does not. Missing/inconsistent intervals return no statistic.
- Maintenance date/distance due values are calculated independently from baseline or last completion. Either reached condition makes a combined rule due. Completion advances both applicable baselines.
- Only original fuel, charging, service, and independent-expense records contribute to the spending ledger. Services use parts + labour + miscellaneous. Trips and renewal histories link or summarize these costs.
- Import validates before mutation: 5 MB and 20,000 business-record limits, valid dates/money/references, duplicate-ID detection and odometer consistency. Merge keeps current settings, remaps colliding IDs (including trip/schedule links), and appends emergency contacts. Importing a backup repeatedly creates additional copies.
- A version-0 snapshot with the same canonical record units can be explicitly migrated to version 1. Unsupported future versions are rejected and the original storage remains recoverable.
- Writes compare the exact previously read snapshot; revisions and storage events detect external updates. Clean tabs adopt newer snapshots. Dirty or competing tabs block further writes and offer explicit load/keep choices. localStorage has no atomic compare-and-swap; simultaneous races are detected as competing revisions where possible, rather than being treated as multi-device synchronization. Keeping one branch is explicit; export/merge backups when you need both.
- Normal quota/unavailable-write failures keep unsaved changes in memory, show a visible banner, offer retry/export, and warn before leaving. A failed backup replacement leaves the previous snapshot intact. Unreadable originals are not overwritten by a normal save or demo merge.
- CSV strings are quoted and dangerous formula prefixes escaped. ICS text is escaped and UTF-8 lines folded. Filenames are sanitized and bounded. User content is rendered as text; no `dangerouslySetInnerHTML`.

## Static deployment

```sh
pnpm install --frozen-lockfile
pnpm build
```

Deploy **only `dist/`**, at the origin root, to any HTTPS static host. No runtime server functions or environment secrets are needed. The build bundles fonts, icons, code and styles; core screens do not depend on external services.

- **Netlify / Cloudflare Pages:** build command `pnpm build`, output directory `dist`. The supplied `_redirects` file rewrites routes to `index.html`.
- **Vercel static:** build command `pnpm build`, output `dist`; the supplied `vercel.json` defines SPA rewrites.
- **Nginx:** use `try_files $uri $uri/ /index.html;` in the static site location.
- Other hosts need a fallback to `index.html` for client routes. Serve JavaScript with its correct MIME type. Serve `sw.js`, `index.html` and the manifest with revalidation, and hashed assets with long-lived immutable caching.

Plain GitHub Pages project subdirectories need additional base-path/router work; this build targets an origin root. Do not double-click `dist/index.html`: service workers and module loading require HTTP localhost or HTTPS.

On a first full production visit, wait for **Ready to go offline**. The shell and lazy report/chart assets are precached. Subsequent routes/reloads and local CRUD work offline. Browser installation availability varies; on iOS use Safari’s Share → Add to Home Screen. New app versions prompt for an update and preserve the local snapshot.

## Storage and product limitations

Local storage is **not a guaranteed backup**. Clearing browser/app data, uninstalling, private browsing, eviction/quota, switching origin/browser/device, or losing the device can remove records. Browser, installed PWA and native app containers can differ. Records are not encrypted. Export JSON, save it outside VehicleCare, then import it in the destination app with preview and Merge/Replace confirmation. Native exports write a short-lived cache file and open the system share sheet; closing that sheet is not proof that an external copy was saved. No automatic cloud sync or recovery account exists.

Web/PWA reminders stay in-app with calendar export. Android/iOS optionally schedule offline date notifications after an explicit Settings action and system permission. Up to 60 warning/due events are scheduled at approximately 9 AM local time; overdue notification times are not replayed. Alarms are inexact, with no exact-alarm permission. Mileage reminders require readings entered by the user. Battery controls, Focus, force-stop, reboot, timezone changes and OS settings require device checks; delivery is not guaranteed. See MOBILE_SETUP.md for details.

Schema version 1 and `vehiclecare:app:v1` are unchanged. The additional `nativeRemindersEnabled` setting defaults to false in existing snapshots. New backups add `exportedAt` and `applicationVersion`; old compatible backups still import. No records are discarded by this extension.

## Android and iOS

Capacitor 8 core/platform/CLI and matching-major official App, Status Bar, Splash Screen, Keyboard, Filesystem, Share and Local Notifications plugins are pinned. Both native source projects are included, with original VehicleCare icons, adaptive Android icons, light/dark splash assets, privacy manifest and optional release signing configuration.

```bat
vehiclecare.cmd cap:sync
vehiclecare.cmd android:open
vehiclecare.cmd android:run
vehiclecare.cmd android:apk
vehiclecare.cmd android:aab
```

On macOS with Xcode:

```sh
pnpm install --frozen-lockfile
pnpm ios:sync
pnpm ios:open
pnpm ios:run
```

Android requires JDK 21, Android SDK 36 and Android Studio. iOS requires macOS and Xcode 26+. Finalize placeholder **com.vehiclecare.app**, signing identities and store accounts before distribution. Release AAB/APK commands refuse incomplete signing configuration. No private signing keys or account credentials are included.

- [MOBILE_SETUP.md](MOBILE_SETUP.md): shared setup, storage transfer, offline operation and reminders.
- [ANDROID_BUILD.md](ANDROID_BUILD.md): SDK, debug APK, signed APK/AAB and Play release.
- [IOS_BUILD.md](IOS_BUILD.md): SPM, iPhone testing, Xcode archive and App Store release.
- [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md): required device and publication gates.

This Windows run verified source sync/configuration, web builds and automated browser/mocked-plugin tests. Android compilation was not performed because JDK/SDK are absent; iOS compilation and physical-device tests require macOS/Xcode. No APK, AAB or IPA was produced.

Currency is a display/recording preference, not an exchange-rate service. Changing it reinterprets existing numeric amounts after confirmation. Merge keeps the current currency; the preview warns about differing-currency backups. Use Replace to retain the imported currency or reconcile amounts before merging. Technical validation diagnostics may remain in English; user-entered text is preserved verbatim in both interface languages.

Reports summarize **recorded** costs. Recorded cost per distance is an all-time estimate using spans between recorded odometers, not a complete ownership cost or measured energy consumption. Fuel intervals require consistent readings; sparse charts remain unavailable or show only recorded measurements. Report tables show the most recent 12 fuel intervals and 20 services; the corresponding record screens provide the complete searchable history with Show more records.

Emergency information and manual checklists are basic assistance tools, not mechanical or safety guarantees. Contact information is user-supplied; no unverified emergency numbers are bundled.

## Verification

```sh
pnpm test
pnpm exec playwright install chrome
pnpm build
pnpm test:e2e
```

Playwright uses installed Google Chrome and starts a static production preview on port 4173. If Chrome is already installed, skip the install command. Unit/component tests cover calculations, schema/reference/date/money validation, storage errors, malformed recovery, revisions, backup collision remapping, transaction preservation, accessible form labels, Hindi text, and commit-only persistence. Browser tests cover onboarding/vehicle CRUD, independent vehicles/reload, record editing/deletion, archive/restore, export/import, corrupt storage, theme/localization, mobile navigation/sheets, offline writes/reload, cross-tab changes, maintenance completion, full deletion, empty reports and all routes.

For visual QA, start `pnpm preview --port 4173` then run `node scripts/visual-check.mjs`. Screenshots are saved to `artifacts/`; browser runtime errors are printed. `scripts/generate-icons.py` optionally regenerates the included PNG icons with Python/Pillow. Neither script is needed for production.

See `QUALITY.md` for the final verification report and actual check results.
