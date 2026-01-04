Stories Feature - Technical Specification
1. Feature Overview
Instagram Stories-style feature for a Gen-Z dating app where users can share temporary photo content with text overlays that expire after 24 hours.

2. Component Architecture
2.1 StoryUpload Component
Purpose: Interface for creating and uploading stories with text overlays

Props:

onClose: () => void - Callback when user closes upload screen
onPost: (imageUrl: string, overlays: TextOverlay[]) => void - Callback when story is posted
State:

imageUrl: string - Base64 or URL of uploaded image
textOverlays: TextOverlay[] - Array of text overlay objects
editingOverlay: string | null - ID of currently editing overlay
editText: string - Current text being edited
editColor: string - Current color selection
editAlignment: 'left' | 'center' | 'right' - Current alignment
editFontSize: 'small' | 'medium' | 'large' - Current font size
draggedOverlay: string | null - ID of overlay being dragged
Key Features:

File input for image upload
Canvas overlay system with drag-and-drop positioning
Text editor panel with color picker, size selector, alignment controls
Real-time preview of text overlays on image
Delete individual overlays
Visual indicators for selected/editing overlay
2.2 StoryViewer Component
Purpose: Full-screen story viewer with auto-play and navigation

Props:

storySet: StorySet - Collection of stories from one user
onClose: () => void - Callback to close viewer
initialStoryIndex?: number - Starting story index (default: 0)
State:

currentIndex: number - Currently displayed story index
progress: number - Progress percentage (0-100) for current story
isPaused: boolean - Whether auto-play is paused
Key Features:

Auto-advance timer (5 seconds per story)
Progress bars (one per story in the set)
Tap zones: left 1/3 = previous, right 1/3 = next, center 1/3 = pause/play
Header with user info and timestamp
Story counter at bottom
Auto-close when last story completes
2.3 StoryDemo Component
Purpose: Main stories hub/landing page

Props:

onNavigate?: (page: string) => void - Navigation callback
State:

showUpload: boolean - Controls upload modal visibility
viewingStory: StorySet | null - Currently viewing story set
myStories: Story[] - User's own stories
otherStories: StorySet[] - Other users' story collections
Key Features:

Horizontal scrollable story circles
"Add Story" button with gradient background
User's stories with camera icon indicator
Visual distinction for new/viewed stories (gradient ring vs gray ring)
Info section explaining story features
Integration of upload and viewer modals
3. Data Models
3.1 TextOverlay
interface TextOverlay {
  id: string;                           // Unique identifier
  text: string;                          // Overlay text content
  x: number;                             // X position (0-100 percentage)
  y: number;                             // Y position (0-100 percentage)
  color: string;                         // Hex color code
  alignment: 'left' | 'center' | 'right'; // Text alignment
  fontSize: 'small' | 'medium' | 'large'; // Font size category
}
3.2 Story
interface Story {
  id: string;                // Unique story identifier
  imageUrl: string;          // Image URL or base64 data
  overlays: TextOverlay[];   // Array of text overlays
  timestamp: number;         // Unix timestamp (milliseconds)
}
3.3 StorySet
interface StorySet {
  userId: string;       // User who posted stories
  userName: string;     // Display name
  userAvatar: string;   // Profile picture URL
  stories: Story[];     // Array of stories from this user
  hasNew: boolean;      // Whether user has unseen stories
}
4. Constants & Configuration
4.1 Text Colors
8 preset colors for text overlays:

White: #FFFFFF
Black: #000000
Pink: #EC4899
Purple: #A855F7
Blue: #3B82F6
Green: #10B981
Yellow: #FBBF24
Red: #EF4444
4.2 Font Sizes
Small: 16px
Medium: 24px
Large: 32px
4.3 Story Duration
STORY_DURATION = 5000ms (5 seconds per story)
4.4 Progress Update Interval
50ms (update progress bar 20 times per second for smooth animation)
5. UI/UX Specifications
5.1 StoryUpload Screen
Layout:

Full-screen modal (fixed, covers entire viewport)
Black background
Header with close button (X icon) and title "Create Story"
Main content area (image canvas or upload prompt)
Bottom toolbar with action buttons
Upload State (No Image):

Centered container with gradient background (purple to dark purple)
Large circular gradient button (pink to purple with shadow)
Camera/Image icon in center
Heading: "Share your moment"
Subtext: "Upload a photo to create your story"
"Choose Photo" button (gradient, large size)
Canvas State (Image Uploaded):

Full-screen image background (object-fit: cover)
Text overlays positioned absolutely by percentage
Selected overlay has pink dashed border with semi-transparent background
Text has drop shadow (2px 2px 8px rgba(0,0,0,0.8))
Bottom Toolbar:

Gradient overlay from transparent to black
"Add Text" button (white/10 background, full-width flex)
Image selector button (square button)
"Post Story" button (gradient, full-width)
Text Editor Panel:

Slides up from bottom with rounded top corners
Black gradient background with border
Text input field (white on dark with pink focus border)
Size selector (3 buttons: Small, Medium, Large)
Alignment selector (3 icon buttons: Left, Center, Right)
Color picker (8x1 grid of color circles)
Delete button (red themed) and Done button (gradient)
Interactive Behaviors:

Overlays are draggable (mouse/touch)
Click overlay to open editor
Drag shows "grabbing" cursor
Editor auto-focuses text input
Color selection shows ring indicator
5.2 StoryViewer Screen
Layout:

Full-screen (fixed position, covers viewport)
Black background
Progress bars at top
Header with user info
Story content (image + overlays)
Story counter at bottom
Progress Bars:

Top of screen with padding
Horizontal flex container with gaps
Each bar: thin white/30 background
Active portion: white with smooth transition
Completed bars: 100% width
Current bar: animated 0-100%
Upcoming bars: 0% width
Header:

Gradient overlay (black/80 to transparent)
User avatar (circular, 40px, pink border)
Username and timestamp
Pause/Play button
Close button (X icon)
Content Area:

Full-screen image (object-fit: cover)
Text overlays positioned by percentage
Non-interactive overlays (pointer-events: none)
Tap zones for navigation (when paused, shows visual indicators)
Pause Indicators:

Left third: ChevronLeft icon with dark overlay
Right third: ChevronRight icon with dark overlay
Story Counter:

Bottom center, elevated above content
Black/50 background with blur
Rounded pill shape
Text: "X / Y" format
Interactive Behaviors:

Click left third: previous story
Click right third: next story
Click center: toggle pause/play
Auto-advance after 5 seconds
Auto-close after last story
Progress resets on story change
5.3 StoryDemo Screen
Layout:

Full-height screen with gradient background (purple to dark)
Header with title and description
Horizontal scrollable story row
Info section below
Story Row:

Horizontal flex container with gaps
Hide scrollbar (custom CSS)
Padding on sides and bottom
Story Circles:

80px diameter
Circular with padding for gradient ring
Inner circle: 2px border, image fill
Text label below (truncated, max 80px width)
Add Story Button:

Gradient background (pink to purple with glow)
Plus icon centered
Label: "Add Story"
User's Stories:

Same styling as others
Camera icon badge (bottom-right, pink background)
Label: "You"
Other Users:

New stories: gradient ring (pink → purple → orange)
Viewed stories: white/20 ring
Label shows username
Grayed text for viewed
Info Section:

Rounded card with white/5 background
Border with white/10
Title: "How Stories Work"
3 info items with emoji icons and descriptions
6. Functionality Details
6.1 Text Overlay Positioning
Position stored as percentage (0-100) of canvas dimensions
CSS: position: absolute; left: X%; top: Y%; transform: translate(-50%, -50%)
Ensures responsive positioning across different screen sizes
Max-width: 80% to prevent overflow
6.2 Drag and Drop
Track drag start with overlay ID
On mouse/touch move: calculate position relative to canvas
Convert pixel coordinates to percentages
Clamp values between 0-100
Update overlay position in state
Clear dragged overlay on mouse/touch up
6.3 Story Timer Logic
1. On story mount/change:
   - Record start time
   - Set interval (50ms)
   
2. On each interval tick:
   - Calculate elapsed = now - start
   - Calculate progress = (elapsed / duration) * 100
   - Update progress state
   
3. When progress >= 100:
   - Clear interval
   - Advance to next story or close
   
4. On pause:
   - Clear interval
   - Maintain current progress
   
5. On resume:
   - Restart timer from current progress
6.4 Timestamp Formatting
< 1 hour: "Xm ago"
1-23 hours: "Xh ago"
24+ hours: "Xd ago"
6.5 Story Navigation
Previous: Only if currentIndex > 0
Next: Advance if more stories, else close viewer
On story change: reset progress to 0
7. Visual Design System
7.1 Color Palette
Background gradient: #2d1b2e to #1a0e1b
Dark purple: #2d1b2e
Card background: white/5 with white/10 border
Gradient primary: Pink #EC4899 to Purple #A855F7
Text primary: white
Text secondary: white/60
Text tertiary: white/40
7.2 Typography
Headers: Bold, white, default sizing from globals.css
Body: Regular, white/80, default sizing
Small text: 12-14px, white/60
7.3 Spacing
Container padding: 24px (1.5rem/6 Tailwind units)
Component gaps: 12-16px
Card padding: 16-24px
Border radius: 12-24px (rounded-xl to rounded-3xl)
7.4 Effects
Text shadow on overlays: 2px 2px 8px rgba(0,0,0,0.8)
Gradient shadows: shadow-lg shadow-pink-500/30
Backdrop blur: backdrop-blur-sm or backdrop-blur-lg
Transitions: transition-all or transition-colors for hover states
7.5 Icons
Size: 20-24px (w-5/w-6 h-5/h-6)
Color: Inherits from parent or specific theme color
Source: lucide-react library
8. Responsive Behavior
Optimized for iPhone 16 Pro (mobile-first)
No horizontal scrolling on main content
Story circles: horizontal scroll with hidden scrollbar
Text overlays: percentage-based positioning scales with screen
Full-screen modals: cover entire viewport
Touch-friendly tap targets (minimum 44px)
9. Integration Points
9.1 Navigation
From HomePage: Story circles at top navigate to stories page
Stories page: Can navigate back via bottom nav or close buttons
State management: AppState includes 'stories' option
9.2 Mock Data Structure
const mockStorySet: StorySet = {
  userId: '2',
  userName: 'Alex',
  userAvatar: 'url',
  hasNew: true,
  stories: [
    {
      id: 's1',
      imageUrl: 'url',
      overlays: [
        {
          id: 'o1',
          text: 'Coffee time ☕',
          x: 50,
          y: 80,
          color: '#FBBF24',
          alignment: 'center',
          fontSize: 'medium',
        }
      ],
      timestamp: Date.now() - 7200000, // 2 hours ago
    }
  ],
};
10. Technical Requirements
10.1 Dependencies
Icon library (lucide-react or equivalent)
File input handling
Base64 encoding for images
Date/time utilities
Modern button component
10.2 Browser APIs
FileReader for image upload
setTimeout/setInterval for timers
Touch events (touchstart, touchmove, touchend)
Mouse events (mousedown, mousemove, mouseup)
10.3 Performance Considerations
Clear intervals on component unmount
Debounce drag position updates if needed
Optimize image sizes
Use CSS transforms for positioning (GPU accelerated)
11. File Structure
/components/stories/
  ├── StoryUpload.tsx       // Upload interface
  ├── StoryViewer.tsx       // Full-screen viewer
  └── StoryDemo.tsx         // Main hub page

/App.tsx                     // Add 'stories' route
/components/home/HomePage.tsx // Add onClick to story circles
This specification should provide everything needed to rebuild the Stories feature in any framework or language! 🎯