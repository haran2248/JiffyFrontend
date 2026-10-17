# Acquisition & Meta SDK Verification Checklist

This document details how each component of the acquisition tracking, install referrer, invite code, and first-message ping is verified, with reproduction and validation steps for both Android and iOS.

---

## 1. Automated Test Results
- **Unit Test File**: `test/acquisition_service_test.dart`
- **Result**: `7/7 passed`
  - `maps facebook utm_source to META_ANDROID` (✓ PASS)
  - `maps instagram utm_source to META_ANDROID` (✓ PASS)
  - `maps custom valid utm_source to uppercase` (✓ PASS)
  - `handles url-encoded referrer query string` (✓ PASS)
  - `ignores google-play, organic, and (not set)` (✓ PASS)
  - `ignores invalid length or characters` (✓ PASS)
  - `validates 3 to 40 uppercase alphanumerics and underscores` (✓ PASS)
- **Static Analysis**: `flutter analyze` completed with **0 errors, 0 warnings**.

---

## 2. Platform Verification Checklist

### Test 1: Meta Events Manager → Test Events (Debug Build)
1. **Build with Dart Defines**:
   ```bash
   flutter run --dart-define=META_APP_ID=YOUR_APP_ID \
               --dart-define=META_CLIENT_TOKEN=YOUR_CLIENT_TOKEN \
               --dart-define=META_DISPLAY_NAME=Jiffy
   ```
2. In Meta Events Manager -> Your App -> **Test Events**.
3. Launch the app on a physical Android device or iPhone.
4. **Expected Result**:
   - `fb_mobile_activate_app` (App open) and App Install events appear in the Test Events feed within 1–2 minutes.
   - Zero custom events or profile data (no gender, age, photos, or onboarding answers) are sent.

---

### Test 2: Android Play Install Referrer
1. **Simulate via Play Internal Testing Link**:
   Generate an internal testing install link containing:
   ```
   https://play.google.com/apps/internaltest/com.jiffydating.app?referrer=utm_source%3DTESTCODE%26utm_medium%3Dinvite
   ```
2. **Or simulate via ADB Broadcast (Emulator/Device)**:
   ```bash
   adb shell am broadcast -a com.android.vending.INSTALL_REFERRER -n com.jiffydating.app/com.jiffydating.app.MainActivity --es "referrer" "utm_source=TESTCODE&utm_medium=cpc"
   ```
3. Open the app on first launch:
   - `AcquisitionService` reads `utm_source=TESTCODE`, maps it to `"TESTCODE"`.
   - Stored in `SharedPreferences` under `pending_acquisition_source`.
4. Log in via Firebase:
   - `PUT /me/source` sends `{ "source": "TESTCODE", "method": "play_referrer" }`.
   - Backend sets `user.source = "TESTCODE"`, `user.sourceMethod = "play_referrer"`.
   - Pending local key is cleared, and `play_referrer_source_sent` is set to `true`.

---

### Test 3: Invite Code in Onboarding
1. Navigate to `/onboarding/referral` (the "Got an invite code?" screen).
2. Type a referral code in lowercase or mixed case (e.g., `friend_99`):
   - Input auto-uppercases to `FRIEND_99`.
   - Keyboard "Done" action triggers validation.
3. Submit code:
   - Client validates `^[A-Z0-9_]{3,40}$`.
   - `PUT /me/source` `{ "source": "FRIEND_99", "method": "invite_code" }`.
   - Backend accepts `invite_code` and overrides any previous `play_referrer` source.
   - Screen displays inline success: *"Invite code applied"*.
   - Input field is replaced by applied confirmation badge.
4. Attempt typing an invalid code (e.g., `ab` or `code!`):
   - Shows inline error: *"That code doesn't look right"*.
   - User can tap *"Continue"* or *"Skip for now"* without being blocked.
5. Second typed code / already applied check:
   - If user already has an invite code set, the input is hidden and cannot be overwritten.

---

### Test 4: First Message Ping
1. Match with another user or open a test chat room.
2. Send a text message:
   - Message is added to Firestore `chat_rooms/{id}/messages`.
   - On Firestore success, `_reportFirstMessageMilestone()` checks `firstMessageReported`.
   - Calls `POST /me/milestones/first-message`.
   - Sets `user.firstMessageAt` on the backend (atomic set-once via Spring Boot service).
   - Local flag `firstMessageReported` is set to `true`.
3. Send a second message:
   - `firstMessageReported` is already true; no network call is made.

---

### Test 5: Airplane Mode & Cold Start Resilience
1. Put device in **Airplane Mode** before first launch.
2. Launch app:
   - App launches smoothly; install referrer query times out after 5s or fails silently without crash.
   - App startup is never blocked.
3. Disable Airplane Mode and log in:
   - Once network is restored, `sendPendingSourceAfterLogin()` sends any pending source.
   - Fails silently if offline and retries on next app start (up to 7 days).
