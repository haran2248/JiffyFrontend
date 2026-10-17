# Meta SDK Privacy & App Store / Play Console Compliance Documentation

## 1. Overview & Scope
This document details the data collection, platform privacy disclosures, and compliance requirements for the Meta (Facebook) App Events SDK integrated into the Jiffy Flutter app (iOS & Android).

### Configuration Constraints Implemented
- `AutoLogAppEventsEnabled`: **true**
- `AdvertiserIDCollectionEnabled`: **true**
- `AD_ID` Permission (Android 13+): **Present** (`com.google.android.gms.permission.AD_ID`)
- Custom Meta Events: **None** (zero custom events)
- User Profile Data Shared: **None** (no name, email, phone, gender, age, onboarding answers, photos, or chat messages are shared with Meta)
- Attribution: Handled via SKAdNetwork on iOS and Google Play Install Referrer on Android.

---

## 2. Apple App Store Privacy Labels (iOS)

### Data Types Collected by Meta SDK in this Configuration

| Data Category | Data Type | Collected? | Linked to User? | Used for Tracking? | Purpose |
|---|---|---|---|---|---|
| **Identifiers** | Device ID (IDFV, IDFA capability) | Yes | **No** | **Conditional** (see below) | Analytics, Advertising & Marketing |
| **Usage Data** | Product Interaction (App Launch, Install) | Yes | **No** | No | Analytics, Advertising & Marketing |
| **Diagnostics** | Crash Data, Performance Data | Yes | **No** | No | Analytics |

### What Counts as "Used for Tracking" on iOS?
- **Device ID (IDFA)**: Apple defines "tracking" as linking data collected from your app about a particular end-user or device with third-party data for targeted advertising or ad measurement purposes, or sharing data with a data broker.
- **Current State (No ATT Prompt)**: In this task, **no App Tracking Transparency (ATT) prompt is presented**. Therefore, on iOS 14.5+, the IDFA is not accessible (returned as zeroed UUID `00000000-0000-0000-0000-000000000000`). Campaign attribution relies on Apple's privacy-preserving **SKAdNetwork** (`v9wttpbfk9.skadnetwork`, `n38lu8286q.skadnetwork`), which Apple explicitly excludes from the definition of "tracking".
- **App Store Connect Disclosure**:
  - Under **App Privacy**: Select **Identifiers** -> **Device ID** and **Usage Data** -> **Product Interaction**.
  - For **Tracking**: If the app does not request ATT, select that data is **not** used to track users across apps/websites owned by other companies.
  - For **Data Linked to You**: Select **No** (data is collected as Device/Instance identifier not linked to user accounts).

---

## 3. Google Play Console Data Safety (Android)

### Section Answers

#### 1. Device or other identifiers
- **Is this data collected?** Yes
- **Is this data shared?** Yes (Transferred to third party: Meta Platforms, Inc.)
- **Is this data processed ephemerally?** No (Stored by Meta for campaign attribution)
- **Is collection required or optional?** Required for app functionality/attribution
- **Purposes**:
  - *Advertising or marketing*
  - *Analytics*

#### 2. App activity
- **Data type**: App interactions (App install, app open sessions)
- **Is this data collected?** Yes
- **Is this data shared?** Yes (Transferred to third party: Meta Platforms, Inc.)
- **Purposes**:
  - *Advertising or marketing*
  - *Analytics*

#### 3. App info and performance
- **Data type**: Crash logs, Diagnostics
- **Is this data collected?** Yes
- **Is this data shared?** Yes
- **Purposes**:
  - *Analytics*

#### General Data Safety Questions
- **Does your app collect or share any of the required user data types?** Yes (Device ID, App Activity, Diagnostics)
- **Is all user data collected by your app encrypted in transit?** Yes (HTTPS/TLS)
- **Do you provide a way for users to request that their data be deleted?** Users can reset their Advertising ID in Android OS settings; profile deletion in Jiffy does not contain Meta-linked data.

---

## 4. Suggested Privacy Policy Addition

Add the following clause to Jiffy's Privacy Policy under **Analytics and Advertising Measurement**:

> *"We utilize Meta's (Facebook) App Events SDK and mobile measurement technologies to measure the installation and delivery efficacy of our advertisements on Meta platforms (Facebook and Instagram). In accordance with platform privacy frameworks—including Apple's SKAdNetwork and the Google Play Install Referrer API—the SDK automatically records app installation and launch events. We do not transmit your dating profile details, photographs, conversation messages, onboarding answers, or personal contact identifiers to Meta."*

---

## 5. SKAdNetwork Configuration Reference

- **Meta SKAdNetwork IDs declared**:
  - `v9wttpbfk9.skadnetwork` (Facebook Attribution)
  - `n38lu8286q.skadnetwork` (Instagram Attribution)
- **Official Documentation Source**: [Meta Developer Guides: SKAdNetwork](https://developers.facebook.com/docs/app-events/guides/skadnetwork)
