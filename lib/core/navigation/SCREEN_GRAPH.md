# Screen Graph

Visual representation of the app's navigation structure.

## Onboarding Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     Root (/)                                │
│              (redirects to /onboarding/basics)              │
└─────────────────────┬───────────────────────────────────────┘
                      │
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
│  • Can skip to permissions                                  │
└───────┬─────────────────────────────────────┬───────────────┘
        │ (Continue)                          │ (Skip)
        ▼                                     ▼
┌─────────────────────────────────────────────────────────────┐
│         /onboarding/permissions                             │
│            PermissionsScreen                                 │
│  • Location permission                                       │
│  • Push notifications permission                            │
└─────────────────────┬───────────────────────────────────────┘
                      │ (Continue / Maybe Later)
                      ▼
              ┌───────────────┐
              │  (Future)     │
              │   /home       │
              │  HomeScreen   │
              └───────────────┘
```

## Current Routes

| Route | Name | Screen | Description |
|-------|------|--------|-------------|
| `/` | - | (redirect) | Redirects to onboarding basics |
| `/onboarding/basics` | `basics` | `BasicsScreen` | User name, photo, and vitals |
| `/onboarding/co-pilot-intro` | `co-pilot-intro` | `CoPilotIntroScreen` | Introduces AI Co-Pilot |
| `/onboarding/profile-setup` | `profile-setup` | `ProfileSetupScreen` | Chat-based profile setup |
| `/onboarding/permissions` | `permissions` | `PermissionsScreen` | Location and notifications |
| `/design-system` | `design-system` | `DesignSystemPage` | Design system showcase |

## Navigation Patterns

### Push (Forward Navigation)
- Use `context.pushRoute()` when adding a screen to the stack
- User can go back using the back button
- Example: Basics → Co-Pilot Intro

### Replace (Swap Current Screen)
- Use `context.replaceRoute()` when replacing current screen
- Removes current screen from stack (no back navigation)
- Example: Co-Pilot Intro → Profile Setup

### Go (Clear Stack)
- Use `context.goToRoute()` after completing flows
- Clears entire navigation stack
- Example: After onboarding completes → Home

### Pop (Go Back)
- Use `context.popRoute()` to go back
- Check `context.canPop()` first if needed

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

