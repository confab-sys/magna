You are the Flutter frontend engineer for the Magna platform.

Goal:
When a user taps a JobCard in the Feed, navigate to a dedicated Job Details screen that shows the expanded job view, full job information, and the full comment thread, with like/comment/reply/delete working consistently.

STRICT RULES
- Do not hardcode colors, spacing, or typography. Use the Magna design tokens in:
  - lib/theme/colors.dart
  - lib/theme/typography.dart
  - lib/theme/spacing.dart
- Reuse existing components where possible. Avoid duplicating UI.
- Keep Feed fast: do not load full comment threads in the feed list.
- Use the existing API client + auth interceptors (core/network/api_client.dart) and your endpoints mapping.
- All actions (like, comment, reply, delete) must update UI state immediately (optimistic update) and then reconcile with API results.
- Reuse the same comment widgets/patterns already created for post details and project details if possible.

------------------------------------------------------------
1) ROUTING / NAVIGATION
Add a new route for job details:

Route: /job/:jobId

Use go_router:
- In lib/app/router.dart, create a route that takes jobId from path params.
- From JobCard, on tap of the card (or tap of main content area), navigate:
  context.push('/job/${job.id}')

------------------------------------------------------------
2) FILE STRUCTURE
Create a new feature module (preferred):

lib/features/job_details/
  data/
    job_details_api.dart
  domain/
    job_details_models.dart   (optional; reuse existing Job/Comment models if they exist)
  ui/
    pages/job_details_page.dart
    widgets/job_header_section.dart
    widgets/job_meta_section.dart
    widgets/job_company_section.dart
    widgets/job_actions_section.dart
    widgets/comment_thread.dart
    widgets/comment_tile.dart
    widgets/comment_composer.dart

If shared comment widgets already exist, reuse them instead of duplicating.

------------------------------------------------------------
3) JOB DETAILS PAGE UI
Create:
lib/features/job_details/ui/pages/job_details_page.dart

Layout requirements:
- Scaffold
- AppBar:
  - Back button
  - Title: “Job”
  - Optional more menu
- Body:
  A) Expanded Job view
  B) Full comment thread
- Bottom:
  - Fixed comment composer bar

Use:
- SafeArea
- Keyboard handling so composer stays visible above keyboard
- Scrollable body

------------------------------------------------------------
4) REUSE JOB CARD UI (NO DUPLICATION)
Modify your existing JobCard (or extract a shared JobView widget) so it can render in two modes:

JobCard(job: ..., mode: JobCardMode.feed)
JobCard(job: ..., mode: JobCardMode.details)

In details mode:
- Show full description (no truncation)
- Show full banner image if available
- Show full salary, location, deadline, and job type
- Show company details more clearly
- Keep like button functional
- Do NOT show truncated preview-only layout
- Do NOT show comment preview inside the card; full comments are below

In feed mode:
- Keep current compact card behavior

If you already implemented JobCard as a widget, add:
  final bool isDetailView;
and branch only where necessary.

------------------------------------------------------------
5) JOB DATA MODEL
Use the existing job schema and frontend model.

Job should support these fields:
- id
- title
- description
- companyName
- companyLogoUrl
- companyVerified
- companyWebsiteUrl
- location
- salary
- jobType
- deadline
- createdAt
- imageUrl
- likesCount
- commentsCount

If some of these are not available yet from API, design the UI to support them cleanly.

------------------------------------------------------------
6) DATA LOADING REQUIREMENTS
When JobDetailsPage opens, load:
- Job by id (fresh copy)
- Comments for that job (top-level + replies)

Use your ApiClient and endpoints.
If endpoints are not defined yet, define them in core/network/endpoints.dart consistently.

Suggested endpoints (adapt to backend):
- GET /api/jobs/:id
- GET /api/jobs/:id/comments
- POST /api/jobs/:id/like
- POST /api/jobs/:id/comments
- POST /api/job-comments/:commentId/reply
- DELETE /api/job-comments/:commentId

Implement a small API wrapper in:
lib/features/job_details/data/job_details_api.dart

Expose:
- fetchJob(jobId)
- fetchComments(jobId)
- toggleLike(jobId, currentlyLiked)
- createComment(jobId, text)
- replyToComment(commentId, text)
- deleteComment(commentId)

------------------------------------------------------------
7) JOB DETAILS SCREEN CONTENT
The details page should present the job in this order:

A. HEADER SECTION
- Company logo/avatar
- Company name
- Timestamp
- Verified badge if companyVerified == true
- Job type pill on the right

B. JOB BANNER IMAGE
- Full width
- Rounded corners
- BoxFit.cover
- Show if imageUrl exists

C. TITLE + DESCRIPTION
- Large bold title
- Full job description text (not truncated)

D. KEY JOB META
Display with icons in a Wrap or Column:
- Location
- Salary
- Deadline
- Job type

Examples:
📍 Nairobi, Kenya
💰 KES 80,000 - 120,000
⏰ Closes in 5 days
🧾 Full Time

E. COMPANY SECTION
If available, show:
- Company logo
- Company name
- Verified badge
- Website button if companyWebsiteUrl exists

F. PRIMARY ACTIONS
- Primary button: Apply
- Secondary button: View Company or Save Job
- Keep this section visually strong and clear

G. ENGAGEMENT BAR
Below job info show:
- Like icon + likesCount
- Comment icon + commentsCount
- Share icon + text “Share”

Then below that:
H. FULL COMMENT THREAD

------------------------------------------------------------
8) COMMENT THREAD UI (WITH REPLIES)
Reuse the same comment architecture used for Post Details and Project Details if possible.

A comment should support:
- id
- authorName
- authorAvatarUrl?
- createdAt
- text
- parentId? (null for top-level)
- replies: List<Comment>

Rendering rules:
- Show top-level comments in a list inside the page scroll
- Each comment tile shows:
  - avatar, name, timestamp
  - comment text
  - actions row: Reply, Delete (only if owned by current user), Like (optional)
- Replies are indented
- Support reply flow:
  - Tapping Reply sets composer into “replying to @username” mode
  - Sending posts a reply under that comment
  - Provide “cancel reply” action

Implementation hint:
- Use flat list and group by parentId, or render nested structure directly if backend already returns nested replies

------------------------------------------------------------
9) COMMENT COMPOSER (BOTTOM BAR)
Create or reuse:
lib/features/job_details/ui/widgets/comment_composer.dart

Features:
- TextField (multiline up to 4 lines)
- Send icon button
- Disabled send when empty
- Reply mode:
  - If replyingTo != null, show “Replying to @Name” + X to cancel

On send:
- If reply mode: call replyToComment(replyingTo.id, text)
- Else: call createComment(jobId, text)

Optimistic UI:
- Insert temporary comment immediately
- Replace with real API result after success

------------------------------------------------------------
10) STATE MANAGEMENT
Use whatever state approach is already in the app (Riverpod/Provider/setState).

Requirements:
- Loading state
- Error state with retry
- Optimistic updates for like/comment/reply/delete
- Pull-to-refresh optional

Like behavior:
- Toggle instantly in UI
- If API fails, revert and show snackbar/toast

Delete behavior:
- Remove comment instantly
- If API fails, restore and show error

------------------------------------------------------------
11) FEED INTEGRATION
From the Feed, ensure:
- Tapping a JobCard navigates to JobDetailsPage
- Returning back updates the feed item’s likes/comments count if possible

Recommended:
- Return updated job snapshot on pop
or
- Refresh only that one item locally

------------------------------------------------------------
12) DELIVERABLES CHECKLIST
- [ ] New route /job/:jobId works
- [ ] JobDetailsPage loads and displays expanded job
- [ ] Full description and full image render correctly
- [ ] Salary, location, deadline, and job type display correctly
- [ ] Company section displays correctly
- [ ] Apply button works or is wired as placeholder
- [ ] Comments load and render with replies
- [ ] Reply flow works
- [ ] Delete comment works
- [ ] Like works from both feed and details
- [ ] No duplicated UI (JobCard reused with details mode)
- [ ] Uses design system tokens only

Build it clean, modular, and production-ready.