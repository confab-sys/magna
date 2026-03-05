
Important rules:
- Do not invent a different structure.
- All features must exist as folders even if only placeholders initially.
- Each feature folder must contain at least: `data/`, `domain/`, `ui/` (unless specified otherwise).
- Shared UI primitives must go ONLY in `lib/shared/widgets`.

---

## Navigation + Routing (MUST implement)

Use **bottom tabs (5)** as the always-on primary navigation:

1) Feed  
2) Builders  
3) Chats  
4) Notifications  
5) Magna AI  

Use nested stacks (push screens) for flows:

Auth stack:
- Login
- Register
- OAuth Callback handler (deep link placeholder)
- Verification
- User Guide (optional placeholder)

Feed stack:
- Feed → PostDetails(id) → CreatePost

Projects stack:
- Projects → ProjectDetails(id) → EditProject(id) → CreateProject → MyProjects

Jobs stack:
- Jobs → JobDetails(id) → CreateJob

Messages stack:
- Chats → Conversation(threadId)

Notifications stack:
- Notifications list

Magna AI stack:
- AI Chat screen

Settings stack:
- Settings screen (reachable via Profile or menu)

Contracts stack:
- Contracts list → Contract details/modals

Routing requirements:
- Use `go_router`.
- Implement an **auth gate**: if no valid token, redirect to `/login`.
- The app should boot into a **Bootstrap** step that restores auth state, then routes correctly.
- Must support deep links for OAuth callback (placeholder routing logic is fine).

---

## API Contract (MUST implement `endpoints.dart` exactly)

Create `lib/core/network/endpoints.dart` with constants for:

- `/api/auth/login`
- `/api/auth/register`
- `/api/posts/feed`
- `/api/posts`
- `/api/posts/:id`
- `/api/posts/:id/like`
- `/api/comments`
- `/api/users`
- `/api/users/:id`
- `/api/users/profile`
- `/api/projects`
- `/api/projects/:id`
- `/api/projects/:id/files`
- `/api/jobs`
- `/api/jobs/:id`
- `/api/chat/conversations`
- `/api/chat/messages/:conversationId`
- `/api/chat/messages`
- `/api/notifications`
- `/api/notifications/:id/read`
- `/api/ai/chat`
- `/api/ai/query`
- `/api/coins/balance`
- `/api/courses`
- `/api/courses/:id`
- `/api/podcasts`
- `/api/contracts`

Also include helper functions to build dynamic endpoints:
- `postById(String id)`
- `likePost(String id)`
- `userById(String id)`
- `projectById(String id)`
- `jobById(String id)`
- `courseById(String id)`
- `messagesByConversation(String conversationId)`
- `markNotificationRead(String id)`

---

## Environment Variables (MUST implement)

We will use these env vars:
- `MAGNA_API_BASE`
- `MAGNA_AI_BASE` (only if separate service)

Implement `.env` loading (ex: flutter_dotenv) and expose:
- `ApiConfig.apiBase`
- `ApiConfig.aiBase` (nullable/optional)

No secrets must be hardcoded into the repo.

---

## Networking + Auth (MUST implement)

### Dio API Client
Create `api_client.dart` with:
- Base URL from `MAGNA_API_BASE`
- JSON headers
- Timeout defaults
- Request/response logging (basic)
- Interceptor: attach token from secure storage
- Interceptor: handle 401 (if refresh not implemented, force logout)

### Token Storage
Use `flutter_secure_storage` in `token_storage.dart`:
- readAccessToken()
- writeAccessToken()
- deleteTokens()
Also store optional:
- userId

### Auth Service
Create `auth_service.dart`:
- login(email, password) → calls POST /api/auth/login
- register(...) → calls POST /api/auth/register
- logout() → clears tokens + resets auth state

Use simple models and DTOs; stubs are OK but structure must exist.

---

## WebSocket (MUST scaffold)

Create `websocket_client.dart`:
- connect(String token)
- disconnect()
- Stream messages
- sendMessage(Map payload)

Do not overbuild. Just scaffold that works.

---

## UI Foundation (MUST implement premium baseline)

Create a theme system:
- `colors.dart`: color tokens
- `typography.dart`: text styles
- `spacing.dart`: spacing constants
- `theme.dart`: ThemeData setup

Shared widgets must include at least:
- PrimaryButton
- AppTextField
- AppCard
- AppLoader
- EmptyState

Do not build full UI for every feature yet. Build only a clean baseline.

---

## Required Starter Screens (MUST implement working app)

Implement these screens at minimum:
- Login screen (basic UI, calls AuthService.login)
- Register screen (basic UI)
- AppShell with bottom tabs (placeholders for each tab)
- Feed screen placeholder
- Builders screen placeholder
- Chats screen placeholder
- Notifications screen placeholder
- Magna AI screen placeholder

The app must:
- Start in Bootstrap
- If not logged in → go to Login
- If logged in → show AppShell

---

## Output Format Requirements (STRICT)

Your response must include:

1) `pubspec.yaml` dependencies list (only what we need)
2) Full folder tree (exact)
3) File-by-file content for:
   - lib/app/app.dart
   - lib/app/router.dart
   - lib/app/bootstrap.dart
   - lib/app/theme/theme.dart
   - lib/app/theme/colors.dart
   - lib/app/theme/typography.dart
   - lib/app/theme/spacing.dart
   - lib/core/network/api_client.dart
   - lib/core/network/endpoints.dart
   - lib/core/network/websocket_client.dart
   - lib/core/auth/token_storage.dart
   - lib/core/auth/auth_service.dart
   - shared widgets listed above
   - minimal Login/Register + AppShell screens

4) A “Run Checklist” with the exact terminal commands:
   - create project
   - add packages
   - run app

5) A “Next Steps” section: what module we implement after this (Feed → PostDetails → CreatePost)

---

## Constraints
- Use Flutter stable and best practices.
- Keep code readable and production-ready.
- Do not invent backend behavior not specified.
- Do not skip any required file.
- Do not output vague suggestions; output actual files and code.

Now begin.