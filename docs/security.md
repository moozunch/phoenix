# Security & Account Protection Guidelines

This document outlines current and planned security measures for the Phoenix app across authentication, data access, and abuse prevention.

## 1. Authentication Lifecycle
 Current State: Email/password + Google Sign-In using Firebase Auth; email verification is required before accessing main features (`/verify_email`); centralized error mapping via `AuthErrorMapper`.
 Auth State Source of Truth: `FirebaseAuth.instance.authStateChanges()` drives `AppState.isLoggedIn` (manual persistence deprecated).
 Planned Enhancements:
  - Re-authentication before critical operations (password change, email change, account deletion).

### 1.1 Email Verification Gate
New users are routed to `/verify_email` until `currentUser.emailVerified == true`. The router forces this and the page allows manual reload/resend with cooldown (30s).

### 1.2 Password Policy
`PasswordPolicy.validate` enforces: length ≥ 8, uppercase, lowercase, digit, symbol. Future stages can add:
- Forbidden common passwords list (downloaded or hashed set).
- zxcvbn-style entropy scoring (if package approved).
- Adaptive policy upgrading (e.g., require 12 chars for privileged roles).

## 2. Rate Limiting & Attempt Backoff (Task 8)
Purpose: Throttle rapid repeated sign-in attempts to mitigate credential stuffing / brute force.
- Client-Side Backoff (Implemented): In-memory counter with exponential delays `[0,2,4,8,16,32,60]` seconds; disables Sign-In & Google buttons while locked and displays remaining seconds. Resets on successful authentication.
- Failure Trigger Points: Generic auth failure, mapped FirebaseAuthException, internal error.
- Server-Side Throttling: Firebase Auth internal limits (returns `too-many-requests`). Consider adding Cloud Function logging for anomaly detection.
- Storage Strategy: Counters are volatile (not persisted) to avoid permanent lockouts.
- Future: Add inactivity timeout reset and integrate IP/device heuristic scoring.

## 3. App Check (Task 10) – Implemented
Purpose: Ensure only genuine app instances access Firebase (protect Firestore, Storage, Functions from scripted abuse).
- Providers Used: Android (Play Integrity for release, Debug provider in debug), iOS (App Attest for release, Debug provider in debug). Web provider deferred (will add reCAPTCHA when web build is targeted).
- Initialization: In `main.dart` after `Firebase.initializeApp()` via `FirebaseAppCheck.instance.activate(...)`.
- Dependency: `firebase_app_check` added to `pubspec.yaml` (run `flutter pub get`).
- Notes: If App Attest unsupported on certain devices, SDK automatically handles fallback (e.g., DeviceCheck); no explicit `appAttestWithFallback` constant required.
- Next: Enable App Check in Firebase Console for Firestore, Storage, Functions; later configure web `reCaptchaV3` provider when shipping web.

## 4. Firestore & Storage Rules
Guiding Principle: Principle of Least Privilege.
- Users Collection Suggestion:
  ```
  /users/{uid}
    profile: { displayName, createdAt, onboardedAt, flags }
    routines: [ ... ]
    journalEntries: [ ... ]
  ```
- Proposed Rules Snippet (Draft):
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /users/{userId} {
        allow read, update, delete: if request.auth != null && request.auth.uid == userId;
        allow create: if request.auth != null && request.auth.uid == userId;
      }
      match /public/{docId} {
        allow read: if true; // restrict writes elsewhere
        allow write: if false;
      }
    }
  }
  ```
- Storage Rules Draft:
  ```
  service firebase.storage {
    match /b/{bucket}/o {
      match /user_uploads/{userId}/{allPaths=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  ```
- Future: Add size/type validation (MIME whitelist) using Functions or Storage Rules metadata checks.

## 5. Re-authentication
 Use `reauthenticateWithCredential` before:
 - Changing password/email.
 - Deleting account.
 Expose a helper `AuthService.reauthenticate(password)` or credential aggregator for Google accounts.

## 6. Re-authentication
Use `reauthenticateWithCredential` before:
- Changing password/email.
- Deleting account.
Expose a helper `AuthService.reauthenticate(password)` or credential aggregator for Google accounts.

## 7. Forgotten Password Flow
Implemented with generic messaging (`If an account exists...`) to prevent email enumeration. Cooldown 30s included.
Future: Add UX indicator of email sent (without confirming existence) and optional hCaptcha (web) or challenge for excessive resets.

## 8. Error Handling Standardization
- Central mapping via `AuthErrorMapper` prevents leaking internal codes & keeps messages consistent.
- Extend for Firestore and Storage errors (wrap with domain-specific messages, log raw code to analytics only).

## 9. Logging & Monitoring
- Debug logging via `DebugLog` (ensure disabled in production build).
- Planned: Integrate Crashlytics & Performance Monitoring to trace latency spikes and auth failure frequencies.
- Anomaly Detection: Consider scheduled Cloud Function to scan auth logs for high failure clusters (heuristic threshold).

## 10. Session Management
- Rely exclusively on Firebase Auth tokens; do **not** manually cache ID tokens.
- Avoid persisting `isLoggedIn`; driven by listener for single source of truth.
- Consider token revocation workflow (admin action) for compromised accounts.

## 11. Defense Against Enumeration & Abuse
- Generic messages on reset and sign-in failure (done).
- Backoff and App Check (planned) reduce automated probing.
- Rate-limit writes to key collections (optionally with Firestore counters + Cloud Functions).

## 12. Deployment Checklist (Security Focus)
1. Enable App Check for all relevant services.
2. Activate MFA (if required) and test fallback flows.
3. Finalize Firestore/Storage rules (run simulator tests).
4. Remove or disable DebugLog printing in release builds.
5. Add Crashlytics & Performance Monitoring.
6. Conduct penetration test focusing on auth flows & enumeration.
7. Ensure CI does not expose secrets in logs.

## 13. Future Considerations
- Device fingerprinting (soft heuristic, not strict security).
- Suspicious IP blocking via custom proxy / load balancer rules.
- Enhanced email verification TTL & token invalidation policies.
- Granular routine permissions if collaborative features appear.

---
This document will evolve; treat it as the canonical reference for implementing security-related tasks (Tasks 8–10 and beyond).
