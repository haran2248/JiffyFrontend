# Screen Graph

Visual representation of the app's navigation structure.

## Authentication & Onboarding Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      /login                                 │
│                   LoginScreen                               │
│  • Google Sign-In                                           │
│  • Apple Sign-In (iOS only)                                 │
└─────────────────────┬───────────────────────────────────────┘
                      │ (Authenticated)
                      │
                      ▼
              ┌───────────────────┐
              │ Check isPhoneVerified │
              └───────┬───────────────┘
                      │
         ┌────────────┴────────────┐
         │ No                      │ Yes
         ▼                         ▼
┌─────────────────────────────────────────────────────────────┐
│      /onboarding/phone-verification                         │
│            PhoneNumberScreen                                 │
│  • Enter phone number                                        │
│  • Sends OTP via backend API                                │
└─────────────────────┬───────────────────────────────────────┘
                      │ (Send Code)
                      ▼
┌─────────────────────────────────────────────────────────────┐
│       /onboarding/otp-verification                          │
│           OtpVerificationScreen                              │
│  • Enter 4-digit OTP code                                   │
│  • Resend countdown timer                                    │
└─────────────────────┬───────────────────────────────────────┘
                      │ (Verified)
                      ▼
┌─────────────────────────────────────────────────────────────┐
│            /onboarding/basics                               │
│              BasicsScreen                                    │
│  • Step 1: Name & Photo                                      │
│  • Step 2: Vitals (DOB, Gender)                             │
└─────────────────────┬───────────────────────────────────────┘
                      │ (Continue)
                      ▼
┌─────────────────────────────────────────────────────────────┐
│         /onboarding/co-pilot-intro                          │
│            CoPilotIntroScreen                                │
│  • Introduces AI Co-Pilot features                          │
└─────────────────────┬───────────────────────────────────────┘
                      │ (Got it, Let's Continue)
                      ▼
┌─────────────────────────────────────────────────────────────┐
│        /onboarding/profile-setup                            │
│           ProfileSetupScreen                                 │
│  • Interactive chat-based profile setup                     │
└─────────────────────┬───────────────────────────────────────┘
                      │ (Continue)
                      ▼
┌─────────────────────────────────────────────────────────────┐
│        /onboarding/profile-curated                          │
│           ProfileCuratedScreen                               │
│  • Review AI-curated profile                                │
│  • Finalize before continuing                               │
└─────────────────────┬───────────────────────────────────────┘
                      │ (Finalize)
                      ▼
┌─────────────────────────────────────────────────────────────┐
│         /onboarding/permissions                             │
│            PermissionsScreen                                 │
│  • Location permission                                       │
│  • Push notifications permission                            │
└─────────────────────┬───────────────────────────────────────┘
                      │ (Continue / Maybe Later)
                      ▼
              ┌───────────────┐
              │    /home      │
              │  HomeScreen   │
              └───────────────┘
```

## Current Routes

| Route | Name | Screen | Description |
|-------|------|--------|-------------|
| `/login` | `login` | `LoginScreen` | Google/Apple Sign-In |
| `/onboarding/phone-verification` | `phone-verification` | `PhoneNumberScreen` | Phone number entry |
| `/onboarding/otp-verification` | `otp-verification` | `OtpVerificationScreen` | OTP code entry |
| `/onboarding/basics` | `basics` | `BasicsScreen` | User name, photo, and vitals |
| `/onboarding/co-pilot-intro` | `co-pilot-intro` | `CoPilotIntroScreen` | Introduces AI Co-Pilot |
| `/onboarding/profile-setup` | `profile-setup` | `ProfileSetupScreen` | Chat-based profile setup |
| `/onboarding/profile-curated` | `profile-curated` | `ProfileCuratedScreen` | Review AI-curated profile |
| `/onboarding/permissions` | `permissions` | `PermissionsScreen` | Location and notifications |
| `/design-system` | `design-system` | `DesignSystemPage` | Design system showcase |

## Navigation Patterns

### Push (Forward Navigation)
- Use `context.pushRoute()` when adding a screen to the stack
- User can go back using the back button
- Example: Phone Verification → OTP Verification

### Replace (Swap Current Screen)
- Use `context.replaceRoute()` when replacing current screen
- Removes current screen from stack (no back navigation)
- Example: Co-Pilot Intro → Profile Setup

### Go (Clear Stack)
- Use `context.goToRoute()` after completing flows
- Clears entire navigation stack
- Example: After login → Phone Verification (or Basics if already verified)

### Pop (Go Back)
- Use `context.popRoute()` to go back
- Check `context.canPop()` first if needed

## Phone Verification Skip Logic

After authentication, the app checks `isPhoneVerified` via API:
- If `true` → Skip to `/onboarding/basics`
- If `false` → Show `/onboarding/phone-verification`

This check uses in-memory caching to avoid redundant API calls.

## Future Routes (To Be Implemented)

```
/home                 → HomeScreen (main app entry)
/matches              → MatchesScreen
/messages             → MessagesScreen
/profile              → ProfileScreen
/settings             → SettingsScreen
```

## Adding New Routes

See `README.md` for detailed instructions on adding new routes to the navigation framework.

