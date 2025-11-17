# Firebase Integration (Internal Docs)

This document captures the current state of Firebase integration for the Phoenix app. It is internal (not part of the public README) and focuses on configuration, security hygiene, and future steps.

## Project Summary
- Firebase Project ID: `phoenix-68fc5`
- Platforms integrated: Android, iOS (macOS/iPadOS not yet reconfigured; still using old bundle id in generated options for macOS)
- Auth Providers: Email/Password, Google (Google enabled on iOS; Android requires added SHA fingerprints)
- Services in use: Authentication, Firestore (planned), Storage (planned), Google Sign-In.

## Application Identifiers
| Platform | Package / Bundle ID | Status |
|----------|---------------------|--------|
| Android  | `app.weesabi.phoenix` | Active, SHA-1 & SHA-256 (debug) added |
| iOS      | `app.weesabi.phoenix` | Active, URL scheme configured |
| macOS    | `com.example.phoenix` | Generated in `firebase_options.dart` (unused currently) |

## Key Files Committed
| File | Purpose | Keep Committed? |
|------|---------|-----------------|
| `lib/firebase_options.dart` | Generated platform options | Yes |
| `android/app/google-services.json` | Android Firebase config | Yes |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase config | Yes |
| `android/app/src/main/kotlin/app/weesabi/phoenix/MainActivity.kt` | Correct Android entrypoint | Yes |

## Files Ignored / Not to Commit
Added rules in `.gitignore`:
- `android/local.properties` (local SDK paths)
- Signing files: `*.keystore`, `*.jks`, `android/app/key.properties`, `*.pem`
- Build caches: `.gradle/`
- Logs: `firebase-debug.log`, `hs_err_pid*`
- Optional generated pods: `ios/Pods/`, `macos/Pods/`

## Google Sign-In Configuration
iOS:
- Added `CFBundleURLTypes` with scheme from `REVERSED_CLIENT_ID` in `Info.plist`.
Android:
- Requires correct SHA-1 and SHA-256 fingerprints (debug added). For release builds add keystore fingerprints:
  ```bash
  keytool -list -v -alias YOUR_ALIAS -keystore /path/to/release.keystore
  ```
  Then add to Firebase Console and re-download `google-services.json`.

## Min SDK Alignment
- Firebase Auth 23.x required `minSdkVersion >= 23`. Updated in `android/app/build.gradle`.

## Activity Package Fix
- Previous `MainActivity` was under `com.example.phoenix` package; created correct one at `app.weesabi.phoenix` matching `namespace` and `applicationId`.

## Kotlin Daemon Crash Workaround
- Disabled incremental compilation in `android/gradle.properties` with:
  - `kotlin.incremental=false`
  - `kotlin.incremental.java=false`
(Consider reverting after upgrading Kotlin/Gradle if stable.)

## Regenerating Firebase Options
Use FlutterFire CLI after any identifier or service change:
```powershell
flutterfire configure --project=phoenix-68fc5 --ios-bundle-id=app.weesabi.phoenix --android-app-id=app.weesabi.phoenix --platforms=ios,android
```
(For macOS/web/windows add to `--platforms` list when needed.)

## Adding Release Signing
1. Generate a release keystore (outside repo). Example:
   ```powershell
   keytool -genkey -v -keystore phoenix-release.keystore -alias phoenix -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Create `android/app/key.properties` (DO NOT COMMIT):
   ```properties
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=phoenix
   storeFile=../path/to/phoenix-release.keystore
   ```
3. Add release SHA-1/SHA-256 to Firebase Console.
4. Update build types with signing config.

## Security Rules (Draft Recommendations)
Firestore (restrict user-owned documents):
```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /users/{uid}/routines/{rid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /users/{uid}/journalEntries/{jid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```
Storage (per-user folder):
```rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /user_uploads/{uid}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## Future Improvements
- Replace manual `AppState.isLoggedIn` flag with `FirebaseAuth.instance.authStateChanges()` listener.
- Implement Firestore user profile doc (e.g., `/users/{uid}`) to derive onboarding status.
- Introduce environment-based configs if multiple Firebase projects (staging vs prod).
- Move Kotlin incremental workaround out once toolchain updated.
- Consider using dynamic links or FCM (requires adding services and updating config files).

## Troubleshooting Quick Reference
| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| ClassNotFound `MainActivity` | Package mismatch | Ensure `MainActivity.kt` path & package match `applicationId` |
| Manifest merge minSdk error | Firebase Auth version requires higher minSdk | Set `minSdkVersion 23` |
| Google Sign-In fails on iOS | Missing URL scheme | Add `CFBundleURLTypes` with `REVERSED_CLIENT_ID` |
| Google Sign-In fails on Android | Missing SHA fingerprints | Add SHA-1/SHA-256 to Firebase Console and download updated `google-services.json` |
| Kotlin daemon crash | Incremental compilation bug | Disable incremental or upgrade Kotlin/Gradle |

## Updating This Doc
When altering Firebase services (adding Analytics, Messaging, etc.), append new sections noting required files, permissions, and privacy considerations.

---
Internal use only. Do not copy sensitive key passwords or keystore files into the repository.
