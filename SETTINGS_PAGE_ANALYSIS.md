# Deep Analysis: Settings Page Component Architecture

**Analysis Date:** March 13, 2026  
**File:** `src/app/settings/page.tsx`  
**Scope:** Complete analysis excluding TopNavigation and LeftPanel components

---

## Table of Contents

1. [Overview](#overview)
2. [Page Structure](#page-structure)
3. [Settings Modules](#settings-modules)
4. [Component Analysis](#component-analysis)
5. [Modals & Interactive Elements](#modals--interactive-elements)
6. [State Management](#state-management)
7. [Theme Support](#theme-support)

---

## Overview

The Settings Page is a comprehensive user settings management interface built with React/Next.js. It provides 11 distinct settings modules organized in a navigation system with both desktop and mobile views.

### Key Characteristics
- **Client-side rendering:** Uses `"use client"` directive
- **Responsive design:** Adapts between desktop (lg:) and mobile views
- **Dark mode support:** Full dark/light theme implementation
- **Modular architecture:** Each settings section is a separate component

---

## Page Structure

### Main Container Layout
```
Settings Page (h-screen flex)
├── LEFT SIDEBAR (LeftPanel) - EXCLUDED FROM ANALYSIS
├── MAIN CONTENT AREA
    ├── TOP NAVIGATION BAR (TopNavigation) - EXCLUDED FROM ANALYSIS
    ├── MOBILE DRAWER (SettingsMobileDrawer)
    └── SCROLLABLE CONTENT AREA
        ├── Page Header (Title & Description)
        └── Settings Grid
            ├── SettingsNavigation (Left sidebar on desktop)
            └── Module Content Area (Dynamic based on active module)
```

### Responsive Breakpoints
- **Mobile:** Default full-width layout
- **Tablet (md):** Adjusted padding and margins
- **Desktop (lg):** 260px expanded sidebar or 88px collapsed sidebar

---

## Settings Modules

The settings page includes **11 main modules** accessible through the navigation:

### Module List with Icons

| Module ID | Label | Icon | Purpose |
|-----------|-------|------|---------|
| Account | Account | User | Profile information & social account linking |
| Payment Method | Payment Method | CreditCard | Payment method management (Stripe, M-Pesa, PayPal) |
| Payment History | Payment History | History | Transaction history and invoices |
| My Projects | My Projects | FolderKanban | User project management |
| My Job Opportunities | My Job Opportunities | Briefcase | Job posting management |
| Notifications | Notifications | Bell | Notification preferences |
| Privacy | Privacy | Lock | Privacy & visibility settings |
| Appearance | Appearance | Palette | Theme & accent color customization |
| Security | Security | ShieldCheck | 2FA, password, account linking |
| Local Discovery | Local Discovery | MapPin | Location-based discovery settings |
| Help Center | Help Center | HelpCircle | FAQ and support options |

---

## Component Analysis

### 1. **AccountSettings Component**

**Purpose:** Manages user profile information and connected social accounts

#### Profile Information Section
- **Profile Picture Upload**
  - Avatar display (24x24px circular)
  - Click-to-upload functionality via hidden file input
  - Image validation: Must be image file type, max 10MB
  - Shows loading state while uploading
  - Displays initials if no picture available

- **Form Fields**
  - Username (text input)
  - First Name & Last Name (grid layout, 2 columns)
  - Email (disabled field)
  - Bio (textarea, 4 rows, max-content input)
  - Location (text input)
  - Website URL (optional, with placeholder)
  - GitHub URL (optional, with placeholder)
  - LinkedIn URL (optional, with placeholder)
  - Twitter URL (optional, with placeholder)
  - Instagram URL (optional, with placeholder)
  - WhatsApp number (optional, with placeholder)

- **Action Buttons**
  - Save Changes (primary button, shows loading state)
  - Cancel (secondary button)

#### Connected Accounts Section
- **Supported Platforms:** 4 social platforms

  **Google Account**
  - Status: Always connected (shows "Connected" button)
  - Email display: Shows user's registered email
  - Icon: Chrome browser icon
  
  **LinkedIn Account**
  - Status: Toggle between connected/disconnected states
  - Dual-state button:
    - Disconnected: Shows "Connect" (red/black button)
    - Connected: Shows "Disconnect" with hover color change to red
  - Loading indicator during connection process
  - Icon: LinkedIn icon
  
  **Twitter Account**
  - Status: Toggle between connected/disconnected states
  - Dual-state button with same styling as LinkedIn
  - Loading indicator during connection process
  - Icon: Twitter icon
  
  **Discord Account**
  - Status: Toggle between connected/disconnected states
  - Dual-state button with same styling as LinkedIn/Twitter
  - Loading indicator during connection process
  - Icon: Message Circle icon

- **Sync Data Button**
  - Located in section header
  - Shows loading state with spinning refresh icon
  - Triggers sync across all connected platforms
  - Currently shows "coming soon" alert

#### API Endpoints Used
```
GET  ${API_BASE}/api/auth/profile/${userId}
POST ${API_BASE}/api/auth/profile/upload-picture
PUT  ${API_BASE}/api/auth/profile/${userId}
```

---

### 2. **PaymentMethodSettings Component**

**Purpose:** Manages payment methods and payment integration

#### Payment Methods Display
- Fetches existing payment methods from backend
- Shows last 4 digits of card/payment method
- Displays expiration date (MM/YY format)
- Remove button for each payment method
- Empty state message when no methods exist
- Loading spinner during fetch

#### Payment Method Addition Buttons
Three payment options with interactive styling:

**Stripe Card**
- Logo: Stripe SVG icon
- Hover color: #635BFF (Stripe blue)
- Click action: Creates card payment method
- API payload includes amount, currency, paymentMethodId

**M-Pesa**
- Logo: M-PESA text logo
- Hover color: #43B02A (M-Pesa green)
- Click action: Creates M-Pesa payment method
- Supports KES currency
- Popular in East African markets

**PayPal**
- Logo: PayPal SVG icon
- Hover color: #003087 (PayPal blue)
- Click action: Creates PayPal payment method
- Supports USD currency

#### Button States
- Default: Border style with hover effects
- Loading: Shows spinner, disabled state
- Dark mode: Different background and text colors

#### API Endpoints Used
```
GET  ${apiUrl}/integrations/payments/methods
POST ${apiUrl}/integrations/payments/create
```

#### Mock Payload Example (Stripe)
```json
{
  "amount": 0,
  "currency": "usd",
  "paymentMethodId": "pm_card_visa",
  "description": "Stripe Card"
}
```

---

### 3. **PaymentHistorySettings Component**

**Purpose:** Displays transaction history and payment records

#### History Items Display
- **Fields per transaction:**
  - Title: Payment description (e.g., "Paid Magna School")
  - Date: Transaction date (formatted)
  - Invoice: Invoice ID reference
  - Amount: Payment amount
  - Status: Payment status badge

#### Status Badge Styling
- Background: Green tint (light or dark mode dependent)
- Text: Green colored
- Shape: Rounded pill
- Content: Status text (e.g., "Paid", "Pending")

#### Mock History Data
```
1. Paid Magna School | Oct 24, 2023 | KES 2,900 | #INV-2023-001
2. Magna Verification | Sep 24, 2023 | KES 4,100 | #INV-2023-002
3. Magna Coins | Aug 24, 2023 | KES 800 | #INV-2023-003
```

#### Loading State
- Displays "Loading history..." message during fetch
- Prevents content flashing

#### Empty State
- Shows "No payment history found." when empty

#### API Endpoints Used
```
GET ${apiUrl}/integrations/payments/history
```

---

### 4. **MyProjectsSettings Component**

**Purpose:** User's project management interface

#### Projects List
- **Items per project:**
  - Title (h3 large text)
  - Description (2-line clamp)
  - Tech Stack Tags (displays first 3 technologies)
  - Edit button (pencil icon)
  - Delete button (trash icon)
  - Last updated timestamp
  - Status badge (Active/Inactive)

#### Action Buttons
- **Header Button:** "New Project" (red button in top-right)
  - Styling: Red (#E50914) with white text
  - Hover effect: Darker red (#cc0812)

- **Per-Project Buttons:**
  - Edit: Opens project edit interface
  - Delete: Removes project

#### Navigation Elements
- **View All Projects Link:** Bottom button directing to `/my-projects`
  - Arrow icon indicating navigation
  - Full-width button
  - Border style (different colors in dark/light mode)

#### Project Status Indicators
- Green badge showing "Active" status
- Different styling between dark and light themes

---

### 5. **MyJobOpportunitiesSettings Component**

**Purpose:** Job posting and opportunity management

#### Jobs List
- **Fields per job:**
  - Job Title (h3 large text)
  - Job Type (e.g., "Full-time", "Contract")
  - Location (e.g., "Remote", "Nairobi, Kenya")
  - Salary Range (e.g., "$120k - $150k" or "$40/hr")
  - Edit button (pencil icon)
  - Delete button (trash icon)
  - Applicant count
  - Status badge (Active/Inactive)

#### Action Buttons
- **Header Button:** "Post New Job" (red button)
  - Same styling as "New Project"

- **Per-Job Buttons:**
  - Edit: Allows job modification
  - Delete: Removes job posting

#### Job Details Display
- Icons for job type, location, and salary
- Uses Lucide React icons (Briefcase, MapPin, DollarSign)
- Organized in flex layout with wrapping

#### Mock Data Structure
```
Job {
  id: number
  title: string
  type: "Full-time" | "Contract"
  location: string
  salary: string
  applicants: number
  status: "Active"
}
```

#### Navigation Elements
- **View All Jobs Link:** Bottom button directing to `/jobs`
- Same styling as projects view all link

---

### 6. **NotificationsSettings Component**

**Purpose:** Notification preference management

#### Toggle Rows
Five notification preferences:

1. **Email Notifications**
   - Description: "Receive emails about your account activity."
   - Default: Enabled

2. **Push Notifications**
   - Description: "Receive push notifications on your device."
   - Default: Enabled

3. **Weekly Digest**
   - Description: "Get a weekly summary of your stats."
   - Default: Disabled

4. **New Applicants**
   - Description: "Get notified when someone applies to your job."
   - Default: Enabled

5. **Marketing Emails**
   - Description: "Receive updates about new features and promotions."
   - Default: Disabled

#### UI Component
- Uses `ToggleRow` helper component
- Each row contains title, description, and toggle switch
- Divided by separator lines
- Responsive layout

---

### 7. **PrivacySettings Component**

**Purpose:** Profile visibility and search engine privacy settings

#### Profile Visibility Section
- **Radio Button Group:** Two options
  - Public (default selected)
  - Private
- Helper text: "Public profiles are visible to everyone."

#### Privacy Toggles
Two toggle rows:

1. **Show Email Address**
   - Description: "Allow others to see your email address."
   - Default: Disabled

2. **Allow Search Engines**
   - Description: "Let search engines index your profile."
   - Default: Enabled

#### UI Component
- Radio buttons with consistent styling
- Toggle rows with descriptions
- Separated sections with visual dividers

---

### 8. **AppearanceSettings Component**

**Purpose:** Theme and color customization

#### Theme Selection
- **Three theme options:**
  - Light (Sun icon)
  - Dark (Moon icon)
  - System (Monitor icon)

- **Theme Card Component:**
  - Icon display
  - Label text
  - Active state indication
  - Click handler for theme switching
  - Localized effect (only applies when appropriate)

#### Accent Color Selection
- **Five color swatches:**
  1. #E50914 (Red - Primary brand color)
  2. #F4A261 (Orange)
  3. #2ECC71 (Green)
  4. #3498DB (Blue)
  5. #9B59B6 (Purple)

- **Color Swatch Component:**
  - Circular display
  - Active state with indicator
  - Click to select
  - Updates CSS custom property `--primary-color`
  - Persists to localStorage as 'accentColor'

#### State Management
- Loads saved color from localStorage on mount
- Dispatches custom event 'accentColorChanged' for other components
- Applies color change to document root CSS variable

---

### 9. **SecuritySettings Component**

**Purpose:** Account security and two-factor authentication

#### Two-Factor Authentication (2FA) Banner
- **Alert Box Styling:**
  - Orange/amber background (light mode)
  - Orange background with transparency (dark mode)
  - Border with warning color
  - Shield icon (ShieldCheck from Lucide)

- **Content:**
  - Title: "Two-Factor Authentication"
  - Description: "Add an extra layer of security to your account."
  - Action Link: "Enable 2FA" (text link styled in red)
  - Status: Currently shows "coming soon" functionality

#### Account Linking Section
- **Component:** `AccountLinking` (separate component)
- **Purpose:** Link Google account to enable Google Sign-in
- **Features:**
  - Description of linking purpose
  - Message display (success/error states)
  - Link button with Google/Chrome icon
  - Loading indicator during linking
  - Animated message transitions

#### Password Change Section
- **Three password fields:**
  1. Current Password (input, type="password")
  2. New Password (input, type="password")
  3. Confirm New Password (input, type="password")

- **Action Button:**
  - Primary button: "Update Password"
  - Shows loading state when updating

#### UI Structure
- Section headers in uppercase gray text
- Clear visual separation between sections
- Input fields inherit from `InputField` helper component

#### Account Linking Component Details (AccountLinking.tsx)

**Purpose:** Google OAuth account linking

**Features:**
- Glassmorphism design (backdrop-blur)
- Framer Motion animations for messages
- Error/Success message display
- Loading state with spinner

**Message Types:**
- Success: Green background, CheckCircle icon
- Error: Red background, AlertCircle icon
- Animated transitions between message states

**States:**
- Idle: Normal button state
- Linking: Shows spinner and "Linking..." text
- Error: Displays error message
- Success: Redirects after successful linking

**Implementation:**
```typescript
- Uses next-auth/react signIn() for Google OAuth
- Callback URL: /settings?linked=true
- Requires matching email addresses
- Shows popup for authorization
```

---

### 10. **LocalDiscoverySettings Component**

**Purpose:** Location-based discovery preferences

#### Location Enable Toggle
- Uses `ToggleRow` component
- Description: "Allow us to use your location to find jobs and events near you."
- Default: Enabled

#### Discovery Radius Slider
- **Range Input:**
  - Current value display: "50 km" (styled in red)
  - Min value: 10 km
  - Max value: 500 km
  - Accent color: Red (#E50914)
  - Current display: 50 km default

- **Label:** "Discovery Radius"
- **Visual:**
  - Responsive width (full-width)
  - Height: 8px (h-2)
  - Rounded appearance
  - Dark mode: Gray-700 background
  - Light mode: Gray-200 background

#### Map Preview Component
- **Placeholder:**
  - Text: "Map Preview Component"
  - Height: 192px (h-48)
  - Dashed border styling
  - Centered text display
  - Background: Gray-50 (light) or #222 (dark)
  - Purpose: Location visualization (not yet implemented)

#### UI Structure
- Spacious vertical layout (space-y-8)
- Clear labels with value displays
- Slider with min/max indicators

---

### 11. **HelpCenterSettings Component**

**Purpose:** Support options and frequently asked questions

#### Support Options Grid
- **Layout:** 2-column grid on desktop, 1-column on mobile
- **Two support cards:**

  **Chat Support**
  - Icon: MessageSquare (Lucide React)
  - Color: Orange (#F4A261)
  - Title: "Chat Support"
  - Description: "Talk to our team live"
  - Hover effect: Border color changes to orange
  - Interactive: Clickable card

  **Email Support**
  - Icon: Mail (Lucide React)
  - Color: Red (#E50914)
  - Title: "Email Us"
  - Description: "Get a response in 24h"
  - Hover effect: Border color changes to orange
  - Interactive: Clickable card

#### FAQ Section
- **Header:** "Frequently Asked Questions" (uppercase, small text)
- **FAQ Items:**
  - Clickable rows with questions
  - ChevronRight icon on right side
  - Hover effect: Background color change
  - Items: Dynamic from faqsData
  
- **Default FAQs:**
  1. "How do I reset my password?"
  2. "Can I change my username?"
  3. "How do I delete my account?"

#### Card Styling
- Rounded corners (rounded-xl)
- Border styling (different colors in dark/light)
- Hover transitions
- Padding and spacing
- Text alignment (center for support cards)

---

## Modals & Interactive Elements

### Important Finding: No Traditional Modals Used

**Status:** The Settings page does **NOT utilize traditional modal components**. Instead, it uses:

### Alternative Interactive Patterns

#### 1. **SettingsMobileDrawer**
- **Purpose:** Mobile navigation drawer
- **Props:**
  - `isOpen`: boolean
  - `onClose`: function
  - `activeTab`: string
  - `setActiveTab`: function
  - `isDarkMode`: boolean
  - `toggleTheme`: function

- **Behavior:**
  - Opens/closes based on mobile menu state
  - Allows navigation between settings modules
  - Includes theme toggle
  - Slides over content on mobile

#### 2. **Inline Form Elements (No Modal)**
- Account Settings uses inline forms for:
  - Profile picture upload
  - Profile information editing
  - Connected account management
  - Password changing

#### 3. **Alert-Based Interactions**
- JavaScript `alert()` used for:
  - "GitHub integration is coming soon!"
  - "LinkedIn integration is coming soon!"
  - "Twitter integration is coming soon!"
  - "Discord integration is coming soon!"
  - "Social platform sync feature is coming soon!"
  - "Disconnect feature is coming soon!"
  - Profile update success/error messages
  - Profile picture upload messages

#### 4. **Toggle/Switch Components**
- Notification preferences
- Privacy settings
- Local discovery settings
- All use checkbox-based toggle switches

#### 5. **Inline Confirmation**
- Delete/edit operations show button options
- No separate confirmation modals
- Actions happen inline

---

## State Management

### Component-Level State

#### AccountSettings
```typescript
// Social platform connection states
const [isConnectingGitHub, setIsConnectingGitHub] = useState(false);
const [githubConnected, setGithubConnected] = useState(false);
const [isConnectingLinkedIn, setIsConnectingLinkedIn] = useState(false);
const [linkedinConnected, setLinkedinConnected] = useState(false);
const [isConnectingTwitter, setIsConnectingTwitter] = useState(false);
const [twitterConnected, setTwitterConnected] = useState(false);
const [isConnectingDiscord, setIsConnectingDiscord] = useState(false);
const [discordConnected, setDiscordConnected] = useState(false);
const [isSyncing, setIsSyncing] = useState(false);

// Profile data
const [isSaving, setIsSaving] = useState(false);
const [profilePicture, setProfilePicture] = useState<string | null>(null);
const [userName, setUserName] = useState('');
const [isUploadingPicture, setIsUploadingPicture] = useState(false);
const [formData, setFormData] = useState({
  username: '',
  firstName: '',
  lastName: '',
  email: '',
  bio: '',
  location: '',
  website: '',
  github: '',
  linkedin: '',
  twitter: '',
  instagram: '',
  whatsapp: ''
});
```

#### PaymentMethodSettings
```typescript
const [isCreating, setIsCreating] = useState(false);
const [paymentMethods, setPaymentMethods] = useState<any[]>([]);
const [isLoading, setIsLoading] = useState(true);
```

#### AppearanceSettings
```typescript
const [accentColor, setAccentColor] = useState('#E50914');
```

#### SettingsPage (Parent)
```typescript
const [activeModule, setActiveModule] = useState('');
const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
const [activeTab, setActiveTab] = useState('Settings');
const [isSidebarExpanded, setIsSidebarExpanded] = useState(true);
const [isDarkMode, setIsDarkMode] = useState(false);
```

### Persistent Storage

#### LocalStorage Keys Used
- `theme`: "dark" | "light"
- `userId` or `userid`: User identifier
- `accessToken`: JWT authentication token
- `accentColor`: Hex color code (e.g., "#E50914")

#### Session Storage
- Query parameters for OAuth callbacks:
  - `status`: "success" | "error"
  - `platform`: "github" | "linkedin" | "twitter" | "discord"
  - `message`: Error message if status is error

---

## Theme Support

### Dark Mode Implementation

#### Color Scheme
- **Dark Mode Colors:**
  - Background: `#111` (near black)
  - Text Primary: `#F9E4AD` (warm beige)
  - Text Secondary: `#F4A261` (orange)
  - Borders: `rgba(231, 0, 8, 0.2)` (red with transparency)
  - Card Background: `#222` (dark gray)
  - Hover States: `#333` (lighter dark gray)

- **Light Mode Colors:**
  - Background: `#FDF8F5` (off-white)
  - Text Primary: `#444444` (dark gray)
  - Borders: Gray variants (gray-100, gray-200, etc.)
  - Card Background: `#fff` (white)
  - Hover States: Gray-50 to gray-100

#### Theme Toggle
- Located in top navigation (excluded from analysis)
- Also accessible in mobile drawer via `SettingsMobileDrawer`
- Calls `toggleTheme()` function
- Dispatches custom 'themeChanged' event
- Updates localStorage 'theme' key

#### CSS Classes Applied
```
Dark Mode: 
  - isDarkMode ? 'bg-black text-[#F9E4AD]' : 'bg-[#FDF8F5] text-[#444444]'
  - isDarkMode ? 'bg-[#111]' : 'bg-white'
  - isDarkMode ? 'border-[#E70008]/20' : 'border-gray-100'

Light Mode:
  - Standard white/light gray backgrounds
  - Dark text colors
  - Light borders
```

#### Conditional Rendering
- All components receive `isDarkMode` prop
- Each component independently handles dark/light styling
- No CSS file imports for theme (inline Tailwind classes)

---

## Additional Features

### Icons Used (Lucide React)
- User, CreditCard, History, FolderKanban, Briefcase
- Bell, Lock, Palette, ShieldCheck, MapPin, HelpCircle
- Camera, Chrome, ChevronRight, Github, Loader2, Linkedin
- Twitter, MessageCircle, RefreshCw, Edit, Trash2, ArrowRight
- Plus, Sun, Moon, Monitor, ShieldCheck, MessageSquare, Mail
- AlertCircle, CheckCircle

### Responsive Breakpoints
- **Mobile:** Default styles
- **Tablet (md):** `md:p-8`, `md:pt-[80px]`, `md:ml-[88px]`, `md:flex-row`, `md:grid-cols-2`
- **Desktop (lg):** `lg:ml-[260px]`, `lg:block`, `lg:w-64`, `lg:rounded-[24px]`, `lg:p-8`

### Animation & Transitions
- Framer Motion in AccountLinking component
- CSS transitions on hover states
- Loading spinners with animate-spin class
- Smooth color transitions
- Grid transition for mobile accordion

### API Integration
- Base URL from environment: `process.env.NEXT_PUBLIC_API_URL`
- Alternative base URL: `process.env.NEXT_PUBLIC_API_BASE`
- Bearer token authentication
- Fetch API for all requests
- Error handling with try-catch blocks

---

## Summary of Key Insights

✅ **No traditional modal dialogs are used in the settings page**

✅ **All interactions are inline or use alerts**

✅ **Comprehensive dark mode support throughout**

✅ **Modular component architecture with clear separation of concerns**

✅ **Responsive design supporting mobile, tablet, and desktop**

✅ **State management via React hooks and localStorage**

✅ **OAuth/Social account integration ready (coming soon features)**

✅ **Payment method integration with multiple providers**

✅ **User profile management with image upload**

---

## Files Referenced

- [Settings Page](src/app/settings/page.tsx)
- [Settings Data](src/app/settings/data.tsx)
- [Account Settings Component](src/components/AccountSettings.tsx)
- [Payment Method Settings](src/components/PaymentMethodSettings.tsx)
- [Payment History Settings](src/components/PaymentHistorySettings.tsx)
- [My Projects Settings](src/components/MyProjectsSettings.tsx)
- [My Job Opportunities Settings](src/components/MyJobOpportunitiesSettings.tsx)
- [Notifications Settings](src/components/NotificationsSettings.tsx)
- [Privacy Settings](src/components/PrivacySettings.tsx)
- [Appearance Settings](src/components/AppearanceSettings.tsx)
- [Security Settings](src/components/SecuritySettings.tsx)
- [Local Discovery Settings](src/components/LocalDiscoverySettings.tsx)
- [Help Center Settings](src/components/HelpCenterSettings.tsx)
- [Settings Navigation](src/components/SettingsNavigation.tsx)
- [Account Linking](src/components/AccountLinking.tsx)
