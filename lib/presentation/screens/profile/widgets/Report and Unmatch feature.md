# Report and Unmatch Feature - Technical Specification

**Feature:** Report and Unmatch functionality for chat conversations  
**Version:** 1.0  
**Last Updated:** April 1, 2026  
**Status:** Implemented  

---

## Table of Contents

1. [Feature Overview](#feature-overview)
2. [User Flows](#user-flows)
3. [Design Specifications](#design-specifications)
4. [Technical Implementation](#technical-implementation)
5. [Component Structure](#component-structure)
6. [State Management](#state-management)
7. [Data Models](#data-models)
8. [Integration Points](#integration-points)
9. [Theming and Styling](#theming-and-styling)
10. [Accessibility](#accessibility)
11. [Error Handling](#error-handling)
12. [Future Enhancements](#future-enhancements)

---

## Feature Overview

### Purpose
Provide users with the ability to unmatch from conversations and report problematic profiles, collecting feedback to improve match quality and maintain platform safety.

### Key Features
- **Unmatch**: Allow users to end a match with feedback collection
- **Report & Unmatch**: Allow users to report problematic behavior and automatically unmatch
- **Reason Selection**: Require users to select a reason for better data collection
- **Bottom Sheet Modals**: Use native-feeling bottom sheets optimized for mobile

### User Benefits
- Control over their match experience
- Safe reporting mechanism for problematic behavior
- Privacy through conversation deletion
- Feedback loop to improve future matches

---

## User Flows

### Flow 1: Unmatch
```
1. User opens chat with a match
2. User taps ⋮ (three dots) in top-right corner
3. Dropdown menu appears with two options
4. User selects "Unmatch"
5. Bottom sheet slides up with unmatch reasons
6. User selects one reason from 6 options
7. "Yes, Unmatch" button becomes enabled
8. User taps "Yes, Unmatch"
9. Bottom sheet closes
10. User returns to conversations list
11. Match is removed from list
12. Conversation history is deleted
```

### Flow 2: Report & Unmatch
```
1. User opens chat with a match
2. User taps ⋮ (three dots) in top-right corner
3. Dropdown menu appears with two options
4. User selects "Unmatch & Report"
5. Bottom sheet slides up with report reasons
6. User selects one reason from 5 options
7. "Submit Report & Unmatch" button becomes enabled
8. User taps "Submit Report & Unmatch"
9. Bottom sheet closes
10. User returns to conversations list
11. Match is removed from list
12. Conversation history is deleted
13. Report is submitted to moderation system
```

### Flow 3: Cancel Action
```
1-5. Same as above flows
6. User taps "Cancel" button
7. Bottom sheet closes
8. User remains in chat
9. No changes are made
```

---

## Design Specifications

### Component Hierarchy
```
ChatWindow
├── Header
│   ├── Back Button
│   ├── Profile Image + Name
│   └── Dropdown Menu (MoreVertical)
│       ├── "Unmatch" option
│       └── "Unmatch & Report" option
├── Messages Area
├── Input Area
├── Unmatch Bottom Sheet
│   ├── Icon (UserX)
│   ├── Title
│   ├── Description
│   ├── Reason Selection (6 buttons)
│   └── Action Buttons
│       ├── "Yes, Unmatch"
│       └── "Cancel"
└── Report Bottom Sheet
    ├── Icon (Flag)
    ├── Title
    ├── Description
    ├── Reason Selection (5 buttons)
    └── Action Buttons
        ├── "Submit Report & Unmatch"
        └── "Cancel"
```

### Layout Specifications

#### Dropdown Menu
- **Position**: Top-right corner, aligned to right edge
- **Trigger**: MoreVertical icon (24x24px)
- **Width**: Auto (min 160px)
- **Padding**: 4px all sides
- **Item Height**: 40px
- **Item Padding**: 8px horizontal, 12px vertical

#### Bottom Sheet
- **Position**: Bottom of screen
- **Border Radius**: 24px top corners
- **Max Height**: 80vh
- **Padding**: 32px horizontal, 24px vertical
- **Overlay**: Semi-transparent black (50% opacity)

#### Icon Container
- **Size**: 64x64px
- **Border Radius**: 50% (circle)
- **Position**: Center, 16px below top
- **Icon Size**: 32x32px

#### Title
- **Font Size**: 20px (text-xl)
- **Font Weight**: 600 (semibold)
- **Text Align**: Center
- **Margin Top**: 16px

#### Description
- **Font Size**: 14px (text-sm)
- **Text Align**: Center
- **Margin Top**: 8px
- **Max Width**: 320px

#### Reason Buttons
- **Height**: 56px
- **Border Radius**: 16px
- **Padding**: 16px
- **Gap Between**: 12px
- **Icon Size**: 20x20px
- **Text Size**: 16px

#### Action Buttons
- **Height**: 48px
- **Border Radius**: 24px (full)
- **Padding**: 12px 24px
- **Gap Between**: 12px
- **Font Size**: 16px

### Interactive States

#### Dropdown Menu Items
- **Default**: `bg-transparent`, `text-white`
- **Hover**: `bg-white/10`
- **Active**: `bg-white/20`
- **Focus**: Outline ring visible

#### Reason Selection Buttons
- **Default**: 
  - Background: `bg-white/5`
  - Border: `border-white/10`
  - Icon Color: `text-white/60`
  - Text Color: `text-white`
- **Hover**: 
  - Background: `bg-white/10`
  - Border: `border-white/20`
- **Selected**: 
  - Background: `bg-red-500/20`
  - Border: `border-red-500/40`
  - Icon Color: `text-red-400`
  - Text Color: `text-white`

#### Primary Action Button (Unmatch/Report)
- **Default**: 
  - Background: `bg-red-500/20`
  - Border: `border-red-500/30`
  - Text: `text-white`
- **Hover**: `bg-red-500/30`
- **Disabled**: 
  - Opacity: 40%
  - Cursor: `not-allowed`
  - Pointer Events: None

#### Cancel Button
- **Default**: 
  - Background: `transparent`
  - Border: `border-white/20`
  - Text: `text-white`
- **Hover**: 
  - Background: `bg-white/5`
  - Border: `border-white/40`

### Animations

#### Bottom Sheet Entry
```css
Animation: slide-in-from-bottom
Duration: 500ms
Easing: ease-in-out
Transform: translateY(100%) → translateY(0)
Opacity: 0 → 1
```

#### Bottom Sheet Exit
```css
Animation: slide-out-to-bottom
Duration: 300ms
Easing: ease-in-out
Transform: translateY(0) → translateY(100%)
Opacity: 1 → 0
```

#### Dropdown Menu Entry
```css
Animation: fade-in + zoom-in
Duration: 200ms
Easing: ease-out
Transform: scale(0.95) → scale(1)
Opacity: 0 → 1
```

#### Dropdown Menu Exit
```css
Animation: fade-out + zoom-out
Duration: 150ms
Easing: ease-in
Transform: scale(1) → scale(0.95)
Opacity: 1 → 0
```

#### Button Selection
```css
Animation: smooth transition
Duration: 200ms
Easing: ease-in-out
Properties: background-color, border-color, color
```

---

## Technical Implementation

### File Location
```
/components/conversations/ChatWindow.tsx
```

### Dependencies
```typescript
// React
import { useState } from 'react';

// Icons
import { 
  ArrowLeft, 
  Send, 
  Sparkles, 
  MoreVertical, 
  ArrowUp, 
  Users, 
  MessageSquare, 
  MapPin, 
  Heart, 
  Music, 
  AlertTriangle, 
  UserX, 
  Flag 
} from 'lucide-react';

// Types
import { Conversation, Message } from '../../types';

// UI Components
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '../ui/dropdown-menu';

import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from '../ui/sheet';

import { ModernButton } from '../ui/modern-button';
```

### State Variables
```typescript
// Bottom sheet visibility
const [showUnmatchSheet, setShowUnmatchSheet] = useState(false);
const [showReportSheet, setShowReportSheet] = useState(false);

// Selected reasons
const [selectedUnmatchReason, setSelectedUnmatchReason] = useState<string | null>(null);
const [selectedReportReason, setSelectedReportReason] = useState<string | null>(null);
```

### Unmatch Reasons Configuration
```typescript
const unmatchReasons = [
  { 
    id: 'no-connection', 
    label: 'Not feeling a connection', 
    icon: Heart 
  },
  { 
    id: 'different-goals', 
    label: 'Different relationship goals', 
    icon: Users 
  },
  { 
    id: 'matched-mistake', 
    label: 'Matched by mistake', 
    icon: AlertTriangle 
  },
  { 
    id: 'met-someone', 
    label: 'Met someone else', 
    icon: Sparkles 
  },
  { 
    id: 'taking-break', 
    label: 'Taking a break from dating', 
    icon: MessageSquare 
  },
  { 
    id: 'other', 
    label: 'Other', 
    icon: MoreVertical 
  },
];
```

### Report Reasons Configuration
```typescript
const reportReasons = [
  { 
    id: 'inappropriate', 
    label: 'Inappropriate messages', 
    icon: AlertTriangle 
  },
  { 
    id: 'fake', 
    label: 'Fake profile or spam', 
    icon: UserX 
  },
  { 
    id: 'harassment', 
    label: 'Harassment or bullying', 
    icon: Flag 
  },
  { 
    id: 'safety', 
    label: 'Safety concerns', 
    icon: AlertTriangle 
  },
  { 
    id: 'other', 
    label: 'Other', 
    icon: Flag 
  },
];
```

### Event Handlers

#### Handle Unmatch
```typescript
const handleUnmatch = () => {
  if (!selectedUnmatchReason) return;
  
  // Log for analytics
  console.log('Unmatching user:', conversation.user.name, 'Reason:', selectedUnmatchReason);
  
  // TODO: API call to backend
  // await unmatchUser(conversation.user.id, selectedUnmatchReason);
  
  // Close sheet
  setShowUnmatchSheet(false);
  
  // Return to conversations list
  onBack();
};
```

#### Handle Report
```typescript
const handleReport = () => {
  if (!selectedReportReason) return;
  
  // Log for analytics
  console.log('Reporting user:', conversation.user.name, 'Reason:', selectedReportReason);
  
  // TODO: API calls to backend
  // await reportUser(conversation.user.id, selectedReportReason);
  // await unmatchUser(conversation.user.id, 'reported');
  
  // Close sheet
  setShowReportSheet(false);
  
  // Return to conversations list
  onBack();
};
```

### JSX Structure

#### Dropdown Menu
```tsx
<DropdownMenu>
  <DropdownMenuTrigger asChild>
    <button className="p-2 hover:bg-white/10 rounded-full transition-colors">
      <MoreVertical className="w-5 h-5 text-white" />
    </button>
  </DropdownMenuTrigger>
  <DropdownMenuContent 
    align="end" 
    className="bg-[#2d1b2e] border-white/10 text-white"
  >
    <DropdownMenuItem 
      onClick={() => setShowUnmatchSheet(true)}
      className="hover:bg-white/10 cursor-pointer"
    >
      <UserX className="w-4 h-4 mr-2" />
      Unmatch
    </DropdownMenuItem>
    <DropdownMenuItem 
      onClick={() => setShowReportSheet(true)}
      variant="destructive"
      className="cursor-pointer"
    >
      <Flag className="w-4 h-4 mr-2" />
      Unmatch & Report
    </DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
```

#### Unmatch Bottom Sheet
```tsx
<Sheet open={showUnmatchSheet} onOpenChange={setShowUnmatchSheet}>
  <SheetContent 
    side="bottom" 
    className="bg-[#2d1b2e] border-t border-white/10 rounded-t-3xl pb-8"
  >
    <SheetHeader className="text-center pb-6">
      {/* Icon Container */}
      <div className="w-16 h-16 rounded-full bg-white/5 border border-white/10 flex items-center justify-center mx-auto mb-4">
        <UserX className="w-8 h-8 text-white/60" />
      </div>
      {/* Title */}
      <SheetTitle className="text-white text-xl">
        Unmatch with {conversation.user.name}?
      </SheetTitle>
      {/* Description */}
      <SheetDescription className="text-white/60 text-sm pt-2">
        You won't be able to message each other anymore and this conversation will be deleted.
      </SheetDescription>
    </SheetHeader>

    {/* Reason Selection */}
    <div className="space-y-3 px-4">
      {unmatchReasons.map((reason) => {
        const Icon = reason.icon;
        return (
          <button
            key={reason.id}
            onClick={() => setSelectedUnmatchReason(reason.id)}
            className={`w-full p-4 rounded-2xl border transition-all flex items-center gap-3 ${
              selectedUnmatchReason === reason.id
                ? 'bg-red-500/20 border-red-500/40'
                : 'bg-white/5 border-white/10 hover:bg-white/10'
            }`}
          >
            <Icon className={`w-5 h-5 ${
              selectedUnmatchReason === reason.id ? 'text-red-400' : 'text-white/60'
            }`} />
            <span className="text-white">{reason.label}</span>
          </button>
        );
      })}

      {/* Action Buttons */}
      <div className="pt-4 space-y-3">
        <ModernButton
          variant="glass"
          className="w-full bg-red-500/20 border-red-500/30 hover:bg-red-500/30"
          onClick={handleUnmatch}
          disabled={!selectedUnmatchReason}
        >
          Yes, Unmatch
        </ModernButton>
        <ModernButton
          variant="outline"
          className="w-full"
          onClick={() => setShowUnmatchSheet(false)}
        >
          Cancel
        </ModernButton>
      </div>
    </div>
  </SheetContent>
</Sheet>
```

#### Report Bottom Sheet
```tsx
<Sheet open={showReportSheet} onOpenChange={setShowReportSheet}>
  <SheetContent 
    side="bottom" 
    className="bg-[#2d1b2e] border-t border-white/10 rounded-t-3xl pb-8"
  >
    <SheetHeader className="text-center pb-6">
      {/* Icon Container */}
      <div className="w-16 h-16 rounded-full bg-red-500/10 border border-red-500/20 flex items-center justify-center mx-auto mb-4">
        <Flag className="w-8 h-8 text-red-400" />
      </div>
      {/* Title */}
      <SheetTitle className="text-white text-xl">
        Report {conversation.user.name}
      </SheetTitle>
      {/* Description */}
      <SheetDescription className="text-white/60 text-sm pt-2">
        Let us know why you're reporting this profile. This will also unmatch you.
      </SheetDescription>
    </SheetHeader>

    {/* Reason Selection */}
    <div className="space-y-3 px-4">
      {reportReasons.map((reason) => {
        const Icon = reason.icon;
        return (
          <button
            key={reason.id}
            onClick={() => setSelectedReportReason(reason.id)}
            className={`w-full p-4 rounded-2xl border transition-all flex items-center gap-3 ${
              selectedReportReason === reason.id
                ? 'bg-red-500/20 border-red-500/40'
                : 'bg-white/5 border-white/10 hover:bg-white/10'
            }`}
          >
            <Icon className={`w-5 h-5 ${
              selectedReportReason === reason.id ? 'text-red-400' : 'text-white/60'
            }`} />
            <span className="text-white">{reason.label}</span>
          </button>
        );
      })}

      {/* Action Buttons */}
      <div className="pt-4 space-y-3">
        <ModernButton
          variant="glass"
          className="w-full bg-red-500/20 border-red-500/30 hover:bg-red-500/30"
          onClick={handleReport}
          disabled={!selectedReportReason}
        >
          Submit Report & Unmatch
        </ModernButton>
        <ModernButton
          variant="outline"
          className="w-full"
          onClick={() => {
            setShowReportSheet(false);
            setSelectedReportReason(null);
          }}
        >
          Cancel
        </ModernButton>
      </div>
    </div>
  </SheetContent>
</Sheet>
```

---

## Component Structure

### UI Components Used

#### 1. DropdownMenu (Radix UI)
**Package**: `@radix-ui/react-dropdown-menu@2.1.6`  
**Location**: `/components/ui/dropdown-menu.tsx`  
**Purpose**: Trigger menu for unmatch/report options

**Key Props**:
- `align`: "end" (aligns to right edge)
- `className`: Custom styling for dark theme

#### 2. Sheet (Radix UI Dialog)
**Package**: `@radix-ui/react-dialog@1.1.6`  
**Location**: `/components/ui/sheet.tsx`  
**Purpose**: Bottom sheet modals for reason selection

**Key Props**:
- `open`: Boolean state control
- `onOpenChange`: State setter function
- `side`: "bottom" for bottom sheet behavior

**Components Used**:
- `SheetContent`: Main modal container
- `SheetHeader`: Header section wrapper
- `SheetTitle`: Modal title (accessibility)
- `SheetDescription`: Modal description (accessibility)

#### 3. ModernButton
**Location**: `/components/ui/modern-button.tsx`  
**Purpose**: Styled action buttons with variants

**Variants Used**:
- `glass`: Semi-transparent with backdrop blur
- `outline`: Border with transparent background

**Props**:
- `variant`: Button style variant
- `className`: Additional custom classes
- `onClick`: Click handler
- `disabled`: Disabled state

#### 4. Lucide Icons
**Package**: `lucide-react`  
**Purpose**: Consistent icon system

**Icons Used**:
- `MoreVertical`: Menu trigger
- `UserX`: Unmatch icon
- `Flag`: Report icon
- `Heart`: Connection reason
- `Users`: Goals reason
- `AlertTriangle`: Mistake/safety reason
- `Sparkles`: Met someone reason
- `MessageSquare`: Break reason

---

## State Management

### Local State (Component Level)

#### Sheet Visibility
```typescript
// Controls which sheet is currently open
showUnmatchSheet: boolean
showReportSheet: boolean
```

**State Transitions**:
```
Initial: false
→ User clicks "Unmatch" → true
→ User clicks "Yes, Unmatch" or "Cancel" → false

Initial: false
→ User clicks "Unmatch & Report" → true
→ User clicks "Submit Report" or "Cancel" → false
```

#### Reason Selection
```typescript
// Stores selected reason ID or null
selectedUnmatchReason: string | null
selectedReportReason: string | null
```

**State Transitions**:
```
Initial: null
→ User clicks reason button → reason.id
→ User clicks different reason → new reason.id
→ User cancels or submits → reset to null
```

### Global State (Future)

When integrated with backend, consider:

```typescript
// Redux/Zustand store structure
interface MatchesState {
  matches: Conversation[];
  unmatching: boolean;
  reporting: boolean;
  error: string | null;
}

// Actions
unmatchUser(userId: string, reason: string): Promise<void>
reportUser(userId: string, reason: string): Promise<void>
```

---

## Data Models

### Unmatch Reason Type
```typescript
interface UnmatchReason {
  id: 'no-connection' | 'different-goals' | 'matched-mistake' | 'met-someone' | 'taking-break' | 'other';
  label: string;
  icon: LucideIcon;
}
```

### Report Reason Type
```typescript
interface ReportReason {
  id: 'inappropriate' | 'fake' | 'harassment' | 'safety' | 'other';
  label: string;
  icon: LucideIcon;
}
```

### API Request Models

#### Unmatch Request
```typescript
interface UnmatchRequest {
  userId: string;           // Current user's ID
  targetUserId: string;     // User being unmatched
  reason: string;           // Reason ID
  timestamp: Date;          // When action occurred
}
```

#### Report Request
```typescript
interface ReportRequest {
  reporterId: string;       // Current user's ID
  reportedUserId: string;   // User being reported
  reason: string;           // Reason ID
  conversationId: string;   // Chat conversation ID
  timestamp: Date;          // When action occurred
  severity: 'low' | 'medium' | 'high';  // Auto-determined by reason
}
```

### API Response Models

#### Unmatch Response
```typescript
interface UnmatchResponse {
  success: boolean;
  message: string;
  deletedConversationId: string;
}
```

#### Report Response
```typescript
interface ReportResponse {
  success: boolean;
  message: string;
  reportId: string;
  status: 'pending' | 'reviewing' | 'resolved';
}
```

---

## Integration Points

### Backend API Endpoints

#### 1. Unmatch User
```
POST /api/v1/matches/unmatch
```

**Headers**:
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json"
}
```

**Request Body**:
```json
{
  "targetUserId": "user_abc123",
  "reason": "no-connection",
  "timestamp": "2026-04-01T12:00:00Z"
}
```

**Success Response** (200):
```json
{
  "success": true,
  "message": "Successfully unmatched",
  "deletedConversationId": "conv_xyz789"
}
```

**Error Response** (400):
```json
{
  "success": false,
  "error": "Match not found",
  "code": "MATCH_NOT_FOUND"
}
```

#### 2. Report User
```
POST /api/v1/users/report
```

**Headers**:
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json"
}
```

**Request Body**:
```json
{
  "reportedUserId": "user_abc123",
  "reason": "inappropriate",
  "conversationId": "conv_xyz789",
  "timestamp": "2026-04-01T12:00:00Z"
}
```

**Success Response** (200):
```json
{
  "success": true,
  "message": "Report submitted successfully",
  "reportId": "report_def456",
  "status": "pending"
}
```

**Error Response** (400):
```json
{
  "success": false,
  "error": "User already reported",
  "code": "DUPLICATE_REPORT"
}
```

### Analytics Events

Track user behavior for product insights:

#### Event: Unmatch Initiated
```typescript
analytics.track('unmatch_initiated', {
  user_id: currentUserId,
  target_user_id: conversation.user.id,
  conversation_duration_days: calculateDuration(),
  message_count: messages.length,
  has_sent_messages: hasSentMessages(),
  timestamp: new Date().toISOString()
});
```

#### Event: Unmatch Reason Selected
```typescript
analytics.track('unmatch_reason_selected', {
  user_id: currentUserId,
  target_user_id: conversation.user.id,
  reason: selectedUnmatchReason,
  timestamp: new Date().toISOString()
});
```

#### Event: Unmatch Completed
```typescript
analytics.track('unmatch_completed', {
  user_id: currentUserId,
  target_user_id: conversation.user.id,
  reason: selectedUnmatchReason,
  timestamp: new Date().toISOString()
});
```

#### Event: Report Initiated
```typescript
analytics.track('report_initiated', {
  user_id: currentUserId,
  target_user_id: conversation.user.id,
  conversation_id: conversation.id,
  timestamp: new Date().toISOString()
});
```

#### Event: Report Submitted
```typescript
analytics.track('report_submitted', {
  user_id: currentUserId,
  target_user_id: conversation.user.id,
  reason: selectedReportReason,
  conversation_id: conversation.id,
  report_id: reportResponse.reportId,
  timestamp: new Date().toISOString()
});
```

### Database Changes

#### Matches Table
```sql
-- Add unmatch tracking
ALTER TABLE matches ADD COLUMN unmatched_at TIMESTAMP;
ALTER TABLE matches ADD COLUMN unmatched_by VARCHAR(50);
ALTER TABLE matches ADD COLUMN unmatch_reason VARCHAR(50);
```

#### Reports Table (New)
```sql
CREATE TABLE reports (
  id VARCHAR(50) PRIMARY KEY,
  reporter_id VARCHAR(50) NOT NULL,
  reported_user_id VARCHAR(50) NOT NULL,
  conversation_id VARCHAR(50),
  reason VARCHAR(50) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  severity VARCHAR(20) DEFAULT 'medium',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  reviewed_at TIMESTAMP,
  reviewed_by VARCHAR(50),
  resolution VARCHAR(255),
  
  FOREIGN KEY (reporter_id) REFERENCES users(id),
  FOREIGN KEY (reported_user_id) REFERENCES users(id),
  FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);

CREATE INDEX idx_reports_reporter ON reports(reporter_id);
CREATE INDEX idx_reports_reported_user ON reports(reported_user_id);
CREATE INDEX idx_reports_status ON reports(status);
```

#### Unmatch Reasons Table (New)
```sql
CREATE TABLE unmatch_reasons (
  id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  target_user_id VARCHAR(50) NOT NULL,
  reason VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (target_user_id) REFERENCES users(id)
);

CREATE INDEX idx_unmatch_reasons_user ON unmatch_reasons(user_id);
CREATE INDEX idx_unmatch_reasons_target ON unmatch_reasons(target_user_id);
CREATE INDEX idx_unmatch_reasons_reason ON unmatch_reasons(reason);
```

---

## Theming and Styling

### Color Palette

#### Primary Colors
```css
/* Dark background gradient */
--bg-primary: #2d1b2e;
--bg-secondary: #1a0e1b;
--bg-tertiary: #3d2a3e;

/* Accent colors */
--accent-pink: #ec4899;
--accent-purple: #a855f7;

/* State colors */
--color-success: #10b981;
--color-warning: #f59e0b;
--color-danger: #ef4444;
```

#### Semantic Colors
```css
/* Unmatch (neutral) */
--unmatch-icon-bg: rgba(255, 255, 255, 0.05);
--unmatch-icon-border: rgba(255, 255, 255, 0.1);
--unmatch-icon-color: rgba(255, 255, 255, 0.6);

/* Report (danger) */
--report-icon-bg: rgba(239, 68, 68, 0.1);
--report-icon-border: rgba(239, 68, 68, 0.2);
--report-icon-color: #f87171;

/* Selection (active state) */
--selection-bg: rgba(239, 68, 68, 0.2);
--selection-border: rgba(239, 68, 68, 0.4);
--selection-icon: #f87171;
```

#### Opacity Scale
```css
--opacity-5: 0.05;
--opacity-10: 0.1;
--opacity-20: 0.2;
--opacity-40: 0.4;
--opacity-60: 0.6;
--opacity-80: 0.8;
```

### Typography

#### Font Sizes
```css
--text-xs: 12px;    /* 0.75rem */
--text-sm: 14px;    /* 0.875rem */
--text-base: 16px;  /* 1rem */
--text-lg: 18px;    /* 1.125rem */
--text-xl: 20px;    /* 1.25rem */
--text-2xl: 24px;   /* 1.5rem */
```

#### Font Weights
```css
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
```

#### Line Heights
```css
--leading-tight: 1.25;
--leading-normal: 1.5;
--leading-relaxed: 1.625;
```

### Spacing

#### Component Spacing
```css
/* Padding */
--padding-xs: 8px;
--padding-sm: 12px;
--padding-md: 16px;
--padding-lg: 24px;
--padding-xl: 32px;

/* Gaps */
--gap-2: 8px;
--gap-3: 12px;
--gap-4: 16px;
--gap-6: 24px;

/* Margins */
--margin-2: 8px;
--margin-4: 16px;
--margin-6: 24px;
```

### Border Radius
```css
--radius-sm: 8px;
--radius-md: 12px;
--radius-lg: 16px;
--radius-xl: 24px;
--radius-full: 9999px;
```

### Shadows
```css
--shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
--shadow-glow-pink: 0 0 20px rgba(236, 72, 153, 0.5);
```

### Tailwind Classes Reference

#### Background Patterns
```css
/* Glassmorphism */
.glass-effect {
  @apply bg-white/5 backdrop-blur-sm border border-white/10;
}

/* Gradient backgrounds */
.gradient-primary {
  @apply bg-gradient-to-r from-pink-500 to-purple-500;
}

.gradient-dark {
  @apply bg-gradient-to-b from-[#2d1b2e] to-[#1a0e1b];
}
```

#### Interactive States
```css
/* Hover states */
.hover-lift {
  @apply transition-transform hover:scale-105;
}

.hover-glow {
  @apply transition-shadow hover:shadow-lg hover:shadow-pink-500/50;
}

/* Focus states */
.focus-ring {
  @apply focus:outline-none focus:ring-2 focus:ring-pink-500/50;
}
```

### Dark Theme Support

All colors are optimized for dark theme. No light theme support needed for current implementation.

```css
/* Dark theme base */
body {
  background: linear-gradient(to bottom, #2d1b2e, #1a0e1b);
  color: white;
}

/* Ensure high contrast for accessibility */
--text-primary: rgba(255, 255, 255, 1);
--text-secondary: rgba(255, 255, 255, 0.8);
--text-tertiary: rgba(255, 255, 255, 0.6);
```

---

## Accessibility

### Keyboard Navigation

#### Dropdown Menu
- **Tab**: Focus on menu trigger
- **Enter/Space**: Open menu
- **Arrow Up/Down**: Navigate menu items
- **Enter**: Select menu item
- **Escape**: Close menu

#### Bottom Sheet
- **Tab**: Navigate through reason buttons and action buttons
- **Enter/Space**: Select reason or action
- **Escape**: Close sheet (cancel action)

### Screen Reader Support

#### ARIA Labels
```tsx
// Dropdown trigger
<button aria-label="More options" aria-haspopup="menu">
  <MoreVertical />
</button>

// Reason buttons
<button
  role="radio"
  aria-checked={selectedUnmatchReason === reason.id}
  aria-label={`Select reason: ${reason.label}`}
>
  {/* Content */}
</button>

// Action buttons
<button aria-label="Confirm unmatch">
  Yes, Unmatch
</button>
```

#### Sheet Titles (Required by Radix)
```tsx
<SheetTitle className="text-white text-xl">
  Unmatch with {conversation.user.name}?
</SheetTitle>

<SheetDescription className="text-white/60 text-sm pt-2">
  You won't be able to message each other anymore...
</SheetDescription>
```

### Focus Management

#### Focus Trap
- When sheet opens, focus moves to first focusable element
- Tab cycles through focusable elements within sheet
- Cannot tab to background elements
- Focus returns to trigger when sheet closes

#### Focus Indicators
```css
/* Visible focus rings */
*:focus-visible {
  outline: 2px solid rgba(236, 72, 153, 0.5);
  outline-offset: 2px;
}
```

### Color Contrast

All text meets WCAG AA standards:

| Element | Foreground | Background | Ratio |
|---------|-----------|------------|-------|
| Title | #ffffff | #2d1b2e | 12.6:1 ✓ |
| Description | rgba(255,255,255,0.6) | #2d1b2e | 7.5:1 ✓ |
| Button Text | #ffffff | rgba(239,68,68,0.2) | 4.8:1 ✓ |
| Icon | rgba(255,255,255,0.6) | transparent | 7.5:1 ✓ |

### Reduced Motion

Respect user preferences:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Error Handling

### Client-Side Errors

#### Network Failure
```typescript
const handleUnmatch = async () => {
  if (!selectedUnmatchReason) return;
  
  try {
    setIsLoading(true);
    await unmatchUser(conversation.user.id, selectedUnmatchReason);
    
    setShowUnmatchSheet(false);
    onBack();
  } catch (error) {
    // Show error toast
    toast.error('Unable to unmatch. Please check your connection and try again.');
    console.error('Unmatch failed:', error);
  } finally {
    setIsLoading(false);
  }
};
```

#### API Timeout
```typescript
// Set timeout for API calls
const TIMEOUT_DURATION = 10000; // 10 seconds

const unmatchWithTimeout = Promise.race([
  unmatchUser(userId, reason),
  new Promise((_, reject) => 
    setTimeout(() => reject(new Error('Request timeout')), TIMEOUT_DURATION)
  )
]);
```

#### Invalid State
```typescript
// Prevent action if no reason selected
if (!selectedUnmatchReason) {
  toast.warning('Please select a reason to continue');
  return;
}

// Prevent duplicate submissions
if (isSubmitting) return;
```

### Server-Side Errors

#### 400 Bad Request
```typescript
if (error.status === 400) {
  toast.error('Invalid request. Please try again.');
}
```

#### 404 Not Found
```typescript
if (error.status === 404) {
  toast.error('This match no longer exists.');
  onBack(); // Return to conversations
}
```

#### 429 Rate Limit
```typescript
if (error.status === 429) {
  toast.error('Too many requests. Please wait a moment and try again.');
}
```

#### 500 Server Error
```typescript
if (error.status === 500) {
  toast.error('Something went wrong on our end. Please try again later.');
}
```

### Error Recovery

#### Retry Logic
```typescript
const MAX_RETRIES = 3;
let retryCount = 0;

const unmatchWithRetry = async () => {
  try {
    await unmatchUser(userId, reason);
  } catch (error) {
    if (retryCount < MAX_RETRIES) {
      retryCount++;
      setTimeout(() => unmatchWithRetry(), 1000 * retryCount);
    } else {
      throw error;
    }
  }
};
```

#### Offline Detection
```typescript
if (!navigator.onLine) {
  toast.error('You appear to be offline. Please check your connection.');
  return;
}
```

### User Feedback

Use toast notifications for all actions:

```typescript
import { toast } from 'sonner@2.0.3';

// Success
toast.success('Successfully unmatched');

// Error
toast.error('Unable to complete action. Please try again.');

// Warning
toast.warning('Please select a reason to continue');

// Info
toast.info('Report submitted for review');
```

---

## Future Enhancements

### Phase 2: Enhanced Feedback

#### Additional Details Input
```tsx
<textarea
  placeholder="Additional details (optional)"
  className="w-full p-3 rounded-lg bg-white/5 border border-white/10"
  maxLength={500}
/>
```

#### Screenshot Upload
```tsx
<input
  type="file"
  accept="image/*"
  multiple
  onChange={handleScreenshotUpload}
/>
```

### Phase 3: Confirmation Steps

#### Two-Step Confirmation for Reports
1. Select reason
2. Review and confirm with additional context
3. Submit

#### Undo Feature
```tsx
toast.success('Unmatched successfully', {
  action: {
    label: 'Undo',
    onClick: () => restoreMatch()
  },
  duration: 5000
});
```

### Phase 4: Analytics Dashboard

#### Admin View
- Report frequency by reason
- Unmatch patterns and trends
- High-risk user identification
- Response time metrics

#### User View
- Feedback on unmatches
- "Why did this happen?" explanations
- Improvement suggestions

### Phase 5: Machine Learning

#### Smart Reason Suggestions
- Pre-select likely reason based on conversation data
- Predict compatibility issues
- Suggest conversation improvements

#### Automated Moderation
- Flag high-risk reports for immediate review
- Auto-ban repeat offenders
- Pattern detection for fake profiles

### Phase 6: Prevention Features

#### Warning System
```tsx
<Alert variant="warning">
  <AlertTriangle className="w-4 h-4" />
  <AlertTitle>Conversation Quality</AlertTitle>
  <AlertDescription>
    We noticed this conversation has been one-sided. 
    Would you like some conversation starter suggestions?
  </AlertDescription>
</Alert>
```

#### Exit Survey
When user selects "Taking a break" reason:
```tsx
<Survey questions={[
  "What would make you return to the app?",
  "Was there a specific issue that made you decide to take a break?",
  "How likely are you to recommend this app? (1-10)"
]} />
```

---

## Testing Checklist

### Unit Tests

- [ ] Dropdown menu opens/closes correctly
- [ ] Bottom sheets open/closes correctly
- [ ] Reason selection updates state
- [ ] Action buttons disabled when no reason selected
- [ ] Cancel button resets state
- [ ] Handlers called with correct parameters

### Integration Tests

- [ ] Full unmatch flow completes successfully
- [ ] Full report flow completes successfully
- [ ] API calls made with correct payload
- [ ] Navigation occurs after successful action
- [ ] Error handling displays correct messages

### E2E Tests

- [ ] User can access menu from chat
- [ ] User can select and submit unmatch
- [ ] User can select and submit report
- [ ] User can cancel actions
- [ ] Changes persist across sessions

### Accessibility Tests

- [ ] Keyboard navigation works
- [ ] Screen reader announces correctly
- [ ] Focus management works properly
- [ ] Color contrast meets standards
- [ ] Reduced motion respected

### Visual Tests

- [ ] Animations smooth on all devices
- [ ] Layout responsive on iPhone 16 Pro
- [ ] Colors match design system
- [ ] Typography consistent
- [ ] Icons aligned properly

### Performance Tests

- [ ] Bottom sheet animates at 60fps
- [ ] No layout shift when opening sheet
- [ ] Memory doesn't leak on repeated actions
- [ ] API calls complete within timeout

---

## Deployment Checklist

### Pre-Deployment

- [ ] Feature flag created
- [ ] Analytics events configured
- [ ] API endpoints deployed and tested
- [ ] Database migrations run
- [ ] Error tracking configured

### Post-Deployment

- [ ] Monitor error rates
- [ ] Track usage analytics
- [ ] Collect user feedback
- [ ] A/B test variations
- [ ] Review reports for quality

---

## Support and Maintenance

### Known Issues
- None currently

### Monitoring
- Track unmatch/report rates
- Monitor API error rates
- Watch for abuse patterns
- Review user feedback

### Contact
- Engineering Lead: [Name]
- Product Manager: [Name]
- Design Lead: [Name]

---

## Version History

### v1.0 (Current) - April 1, 2026
- Initial implementation
- Unmatch with reasons
- Report & Unmatch with reasons
- Bottom sheet UI
- Dropdown menu trigger

### Planned
- v1.1: Additional context input
- v1.2: Undo functionality
- v1.3: Analytics dashboard
- v2.0: ML-powered suggestions

---

## Appendix

### Related Documentation
- [Design System Guide](/guidelines/Guidelines.md)
- [API Documentation](/api/docs)
- [Analytics Events](/analytics/events)
- [User Safety Guidelines](/legal/safety)

### Dependencies
- React 18+
- Radix UI Dropdown Menu 2.1.6
- Radix UI Dialog 1.1.6
- Lucide React (icons)
- Tailwind CSS v4
- Sonner (toast notifications)

### References
- [Radix UI Documentation](https://www.radix-ui.com)
- [Tailwind CSS v4](https://tailwindcss.com)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21)

---


### Backend 

# Unmatch & Report API Documentation

Base URL: `http://localhost:5005`

---

## 1. Get Reason Options

Fetch configurable reason options for unmatch or report flows.

**Endpoint:** `GET /api/v1/config/reasons`

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `type` | String | ✅ | `"unmatch"` or `"report"` |

**Example Request:**
```bash
curl -X GET "http://localhost:5005/api/v1/config/reasons?type=unmatch"
```

**Success Response (200):**
```json
[
  {
    "id": "66e9a1b2c3d4e5f6a7b8c9d0",
    "type": "unmatch",
    "key": "not_feeling_connection",
    "label": "Not feeling a connection",
    "icon": "heart",
    "ordinal": 1,
    "active": true
  },
  {
    "id": "66e9a1b2c3d4e5f6a7b8c9d1",
    "type": "unmatch",
    "key": "different_relationship_goals",
    "label": "Different relationship goals",
    "icon": "people",
    "ordinal": 2,
    "active": true
  },
  {
    "id": "66e9a1b2c3d4e5f6a7b8c9d2",
    "type": "unmatch",
    "key": "matched_by_mistake",
    "label": "Matched by mistake",
    "icon": "warning",
    "ordinal": 3,
    "active": true
  },
  {
    "id": "66e9a1b2c3d4e5f6a7b8c9d3",
    "type": "unmatch",
    "key": "met_someone_else",
    "label": "Met someone else",
    "icon": "sparkles",
    "ordinal": 4,
    "active": true
  },
  {
    "id": "66e9a1b2c3d4e5f6a7b8c9d4",
    "type": "unmatch",
    "key": "taking_a_break",
    "label": "Taking a break from dating",
    "icon": "chat",
    "ordinal": 5,
    "active": true
  },
  {
    "id": "66e9a1b2c3d4e5f6a7b8c9d5",
    "type": "unmatch",
    "key": "other_unmatch",
    "label": "Other",
    "icon": "more",
    "ordinal": 6,
    "active": true
  }
]
```

**Example (report type):**
```bash
curl -X GET "http://localhost:5005/api/v1/config/reasons?type=report"
```

**Response (200):**
```json
[
  {
    "id": "...",
    "type": "report",
    "key": "inappropriate_messages",
    "label": "Inappropriate messages",
    "icon": "warning",
    "ordinal": 1,
    "active": true
  },
  {
    "id": "...",
    "type": "report",
    "key": "fake_profile_or_spam",
    "label": "Fake profile or spam",
    "icon": "people",
    "ordinal": 2,
    "active": true
  },
  {
    "id": "...",
    "type": "report",
    "key": "harassment_or_bullying",
    "label": "Harassment or bullying",
    "icon": "flag",
    "ordinal": 3,
    "active": true
  },
  {
    "id": "...",
    "type": "report",
    "key": "safety_concerns",
    "label": "Safety concerns",
    "icon": "warning",
    "ordinal": 4,
    "active": true
  },
  {
    "id": "...",
    "type": "report",
    "key": "other_report",
    "label": "Other",
    "icon": "flag",
    "ordinal": 5,
    "active": true
  }
]
```

---

## 2. Unmatch

Unmatch two users. Removes the match from both sides, deletes the Firestore chat room, and adds both users to each other's rejected list.

**Endpoint:** `POST /api/v1/match/unmatch`

**Request Body:**

| Field | Type | Required | Description |
|---|---|---|---|
| `userId` | String | ✅ | UID of the user initiating the unmatch |
| `matchedUserId` | String | ✅ | UID of the matched user to unmatch |
| `reasonKey` | String | ✅ | Key from the unmatch reason options |

**Example Request:**
```bash
curl -X POST "http://localhost:5005/api/v1/match/unmatch" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "iXNRKFrSeRaD86bP1PeHwYegzbX2",
    "matchedUserId": "ioUtTHDS8HTteQEmnumyzcIY6j03",
    "reasonKey": "not_feeling_connection"
  }'
```

**Success Response (200):**
```json
{
  "status": "success",
  "message": "Successfully unmatched"
}
```

**Error Response — User Not Found (404):**
```json
{
  "status": "error",
  "message": "One or both users not found"
}
```

**Error Response — Server Error (500):**
```json
{
  "status": "error",
  "message": "Failed to unmatch"
}
```

**Side Effects:**
- Removes `matchedUserId` from `userId`'s `matches` list and vice-versa
- Removes `eventChats` entries on both sides
- Adds each user to the other's `rejectedUserIds`
- Deletes the Firestore chat room (`chat_rooms/{chatroomId}`)
- Creates an `UnmatchRecord` document in MongoDB

---

## 3. Report & Unmatch

Report a user and automatically unmatch. The reported user is also added to the reporter's blocked list.

**Endpoint:** `POST /api/v1/match/report`

**Request Body:**

| Field | Type | Required | Description |
|---|---|---|---|
| `reporterUserId` | String | ✅ | UID of the reporter |
| `reportedUserId` | String | ✅ | UID of the user being reported |
| `reasonKey` | String | ✅ | Key from the report reason options |
| `details` | String | ❌ | Optional free-text description |

**Example Request:**
```bash
curl -X POST "http://localhost:5005/api/v1/match/report" \
  -H "Content-Type: application/json" \
  -d '{
    "reporterUserId": "iXNRKFrSeRaD86bP1PeHwYegzbX2",
    "reportedUserId": "uc3A1GPFRwXdpOp5n9xN2Jo0kSH3",
    "reasonKey": "inappropriate_messages",
    "details": "Sent inappropriate content"
  }'
```

**Success Response (200):**
```json
{
  "status": "success",
  "message": "Report submitted and user unmatched"
}
```

**Error Response — User Not Found (404):**
```json
{
  "status": "error",
  "message": "One or both users not found"
}
```

**Error Response — Server Error (500):**
```json
{
  "status": "error",
  "message": "Failed to submit report"
}
```

**Side Effects:**
- Creates a `Report` document with status `"pending"` in the `Reports` collection
- Triggers the full unmatch flow (same as above)
- Adds `reportedUserId` to reporter's `blockedUserIds`

---

## MongoDB Collections Created

| Collection | Description |
|---|---|
| `ReasonOptions` | Configurable unmatch/report reason options (seeded on first startup) |
| `UnmatchRecords` | Audit trail of all unmatch actions |
| `Reports` | User reports with status tracking (`pending` → `reviewed` → `resolved`) |


**Document End**
