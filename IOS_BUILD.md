# VehicleCare iOS build and release

The generated project is `ios/App/App.xcodeproj`, with Capacitor 8's Swift Package Manager integration. iOS assets/plugins were synced on Windows. **No iOS compilation, simulator/device test, archive or IPA export was performed**: those require macOS and Xcode.

## macOS setup and run

Install Node 22.12+, pnpm 11.25.0 and **Xcode 26+** with its command-line tools and iOS SDK/simulators. This project targets iOS 15+. Consult [Capacitor's environment setup](https://capacitorjs.com/docs/getting-started/environment-setup) and current Apple submission requirements before release. CocoaPods is not required for this generated SPM project.

Copy the source to the Mac, not Windows `node_modules` or build directories. From its root:

```sh
pnpm install --frozen-lockfile
pnpm typecheck
pnpm lint
pnpm test
pnpm ios:sync
pnpm ios:open
pnpm ios:run
```

Sync rebuilds native assets and regenerates SPM plugin paths for the installed pnpm tree. Resolve packages in Xcode when prompted. In Xcode choose scheme **App**, a simulator or connected iPhone, and Run. For a physical device, select your Apple Development Team under **App → Signing & Capabilities**, enable automatic signing as appropriate and trust/enable development on the device. No team ID, Apple credentials or certificate is hardcoded.

Unsigned simulator build, on macOS only:

```sh
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath ios/DerivedData CODE_SIGNING_ALLOWED=NO build
```

If SPM paths fail, reinstall with the frozen lockfile and run `pnpm ios:sync`; let Xcode resolve dependencies. Do not add CocoaPods alongside SPM or hand-edit `CapApp-SPM/Package.swift`.

## Identity, version and privacy

Finalize placeholder **com.vehiclecare.app** before first store publication. Update `appId` in `capacitor.config.ts` and the App target's `PRODUCT_BUNDLE_IDENTIFIER` for Debug/Release in Xcode; if publishing Android too, keep the corresponding Android ID aligned with shared config. Re-sync after changes. The native source checker compares generated config with the bundle ID. Keep published identity/native origin stable so updates retain the same storage container.

Set Xcode's **Version** (`MARKETING_VERSION`) and increment **Build** (`CURRENT_PROJECT_VERSION`) for every upload. Set the shared `package.json` version for backup metadata. The app display name is VehicleCare. Its 1024-pixel app icon, light/dark splash image catalog, bundled font licenses and `PrivacyInfo.xcprivacy` are present. The privacy manifest declares no collected data/tracking and the FileTimestamp (`C617.1`) / UserDefaults (`CA92.1`) required-reason API usage for app-owned files/settings; review the archive's aggregated privacy report against the actual linked SDKs.

There is no camera/location/contacts/photo/microphone access, ATS arbitrary-load exception, iCloud entitlement, push entitlement or background mileage service. Explicit notification permission uses the local-notifications plugin. Sharing uses the native share sheet; import uses a file input/system document picker. The app-owned Library is excluded from automatic OS backup in AppDelegate; verify on devices and do not rely on it for recovery. JSON exports saved outside the app are the supported portable backup.

## Archive and App Store

An Apple Developer membership, owned bundle ID, signing team/certificate/provisioning profile and App Store Connect app registration are manual prerequisites. Never commit `.p12`, profiles, account credentials or App Store private keys.

```sh
pnpm ios:sync
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Release -destination 'generic/platform=iOS' -archivePath artifacts/VehicleCare.xcarchive archive
```

The archive command uses signing configured in Xcode and cannot succeed without it. Alternatively select **Any iOS Device (arm64)** → **Product → Archive**. In Organizer validate the actual archive, inspect privacy/signing, then **Distribute App → App Store Connect** (or an authorized ad-hoc/development distribution method). Export an IPA only with the corresponding provisioning/signing settings. No universal export options or credentials are included.

Upload to TestFlight, install the signed build, and test in airplane mode: first launch, all CRUD, restart persistence, JSON export to Files, restore/merge/replace, denied/enabled notifications, changed/completed cancellation, lockscreen privacy, timezone change, keyboard, notch/home indicator, orientation and light/dark appearance. Test on a compact iPhone and a modern notched iPhone, plus iPad if distributing there. Browser-width tests and plugin mocks do not establish iOS runtime correctness.

Complete App Store screenshots, description, privacy policy, App Privacy answers, age rating and applicable store requirements manually. Explain local-only records, unencrypted user exports and optional local notifications; avoid claiming automatic mileage tracking or guaranteed alarms. Release only after [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) is satisfied.
