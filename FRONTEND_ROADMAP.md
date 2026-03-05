# Magna Frontend Implementation Roadmap

This roadmap outlines the step-by-step implementation plan for the Magna Flutter application, aligning with the backend endpoints verified in `test-endpoints.js` and the architecture defined in `flutter.md`.

## Phase 1: Foundation & Architecture 🏗️
**Goal:** Set up the project structure, core networking, and authentication flow.

- [ ] **1.1 Project Initialization**
  - Create Flutter project `magna_app`.
  - Set up folder structure (`lib/app`, `lib/core`, `lib/features`, etc.).
  - Add dependencies: `dio`, `go_router`, `flutter_riverpod` (state management), `flutter_secure_storage`, `json_annotation`.

- [ ] **1.2 Core Networking**
  - Implement `ApiClient` (Dio wrapper with interceptors).
  - Create `Endpoints` class with all verified API paths.
  - Set up Environment variables (`MAGNA_API_BASE`).

- [ ] **1.3 Authentication Feature**
  - Implement `AuthService` & `TokenStorage`.
  - Create **Login Screen** (UI + Logic).
  - Create **Register Screen** (UI + Logic).
  - Implement `AuthGuard` (Redirect to Login if no token).

## Phase 2: The Core Social Experience 📱
**Goal:** Implement the main feed and interactions (Tab 1).

- [ ] **2.1 Feed Feature**
  - Create `FeedRepository` (Fetch posts).
  - Build **Feed Screen** (Infinite scroll list).
  - Create `PostCard` widget (Display content, author, likes).
  - Implement **Like Post** functionality.

- [ ] **2.2 Create Post**
  - Build **Create Post Screen**.
  - Implement API call to submit post.
  - Refresh feed after posting.

## Phase 3: Builders & Profiles 👥
**Goal:** Connect users and display profiles (Tab 2).

- [ ] **3.1 Builders Feature**
  - Fetch & Display list of users (`/api/users`).
  - Build **Builders Screen**.

- [ ] **3.2 Profile Feature**
  - Fetch current user profile (`/api/users/profile`).
  - Fetch other user profiles (`/api/users/:id`).
  - Build **Profile Screen** (Avatar, Bio, Stats).

## Phase 4: Communication (Chat) 💬
**Goal:** Real-time(ish) messaging between users (Tab 3).

- [ ] **4.1 Conversations**
  - Fetch list of conversations (`/api/chat/conversations`).
  - Build **Conversation List Screen**.

- [ ] **4.2 Messaging**
  - Fetch messages for a conversation (`/api/chat/messages`).
  - Build **Chat Screen** (Bubble UI).
  - Implement **Send Message**.

## Phase 5: Notifications & AI 🔔🤖
**Goal:** User engagement and AI assistance (Tab 4 & 5).

- [ ] **5.1 Notifications**
  - Fetch notifications (`/api/notifications`).
  - Build **Notifications Screen**.
  - Implement "Mark as Read".

- [ ] **5.2 Magna AI**
  - Build **AI Chat Screen**.
  - Implement Chat/Query API (`/api/ai/query`).

## Phase 6: Professional Features 💼
**Goal:** Projects, Jobs, and Contracts (Drawer/Menu items).

- [ ] **6.1 Projects**
  - Fetch Projects List (`/api/projects`).
  - Build **Projects Screen**.
  - Implement **Create Project**.
  - **Project Details** Screen.

- [ ] **6.2 Jobs**
  - Fetch Jobs List (`/api/jobs`).
  - Build **Jobs Screen**.
  - Implement **Create Job**.
  - **Job Details** Screen.

- [ ] **6.3 Contracts**
  - Fetch Contracts List (`/api/contracts`).
  - Build **Contracts Screen**.

## Phase 7: Extras & Polish 💎
**Goal:** Wallet, Courses, Podcasts, and UI refinement.

- [ ] **7.1 Wallet**
  - Fetch Coin Balance (`/api/coins/balance`).
  - Build **Wallet Widget/Screen**.

- [ ] **7.2 Content (School/Podcasts)**
  - Fetch Courses & Podcasts.
  - Build simple list views for them.

- [ ] **7.3 Final Polish**
  - Error handling (Toast/Snackbars).
  - Loading states (Shimmer effects).
  - App Icon & Splash Screen.
