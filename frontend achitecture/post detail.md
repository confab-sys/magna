You are the Flutter frontend engineer for the Magna platform.

Goal: When a user taps a PostCard in the Feed, navigate to a dedicated Post Details screen that shows the expanded post view and the full comment thread (including replies), with like/comment/reply/delete working consistently.

STRICT RULES

* Do not hardcode colors, spacing, or typography. Use the Magna design tokens in:

  * lib/theme/colors.dart
  * lib/theme/typography.dart
  * lib/theme/spacing.dart
* Reuse existing components where possible. Avoid duplicating UI.
* Keep Feed fast: do not load full comment threads in the feed list.
* Use the existing API client + auth interceptors (core/network/api_client.dart) and your endpoints mapping.
* All actions (like, comment, reply, delete) must update UI state immediately (optimistic update) and then reconcile with API results.

---

1. ROUTING / NAVIGATION
   Add a new route for post details:

Route: /post/:postId

Use go_router:

* In lib/app/router.dart, create a route that takes postId from path params.
* From FeedPostCard, on tap of the card (or tap of main content area), navigate:
  context.push('/post/${post.id}')

---

2. FILE STRUCTURE
   Create a new feature module (preferred):

lib/features/post_details/
data/
post_details_api.dart
domain/
post_details_models.dart   (optional; reuse existing Post/Comment models if they exist)
ui/
pages/post_details_page.dart
widgets/comment_thread.dart
widgets/comment_tile.dart
widgets/comment_composer.dart

If you already have features/posts or features/comments, integrate logically without duplicating. The key deliverable is a clean PostDetailsPage and reusable comment widgets.

---

3. POST DETAILS PAGE UI
   Create: lib/features/post_details/ui/pages/post_details_page.dart

Layout requirements:

* Scaffold
* AppBar:

  * Back button
  * Title: “Post”
  * Optional actions: more menu (placeholder ok)

Body:

* A scrollable layout that contains:
  A) Expanded Post view
  B) Full comment thread list

Bottom:

* A fixed comment composer bar (text input + send button)

Use:

* SafeArea
* Keyboard handling: avoid composer being hidden by keyboard (use viewInsets padding).

---

4. REUSE POST CARD UI (NO DUPLICATION)
   Modify your existing FeedPostCard (or extract a shared PostCard widget) so it can render in two modes:

PostCard(post: ..., mode: PostCardMode.feed)
PostCard(post: ..., mode: PostCardMode.details)

In details mode:

* Show full text (no truncation)
* Show full media (same as feed, but allow larger if you prefer)
* Keep like button functional
* Do NOT show “comment preview” inside the card; the full comments live below.

In feed mode:

* Keep existing behavior (truncation allowed)

If you already implemented PostCard as a widget, add a boolean like:
final bool isDetailView;
and branch only where necessary.

---

5. DATA LOADING REQUIREMENTS
   When PostDetailsPage opens, load:

* Post by id (fresh copy)
* Comments for that post (top-level + replies)

Use your ApiClient and endpoints.
If endpoints aren’t defined yet, define them in core/network/endpoints.dart consistently.

Suggested endpoints (adapt to your backend):

* GET /api/posts/:id
* GET /api/posts/:id/comments
* POST /api/posts/:id/like
* POST /api/posts/:id/comments
* POST /api/comments/:commentId/reply
* DELETE /api/comments/:commentId
  (If your backend differs, match existing routes, but keep the same behaviors.)

Implement a small API wrapper in:
lib/features/post_details/data/post_details_api.dart
that exposes:

* fetchPost(postId)
* fetchComments(postId)
* toggleLike(postId, currentlyLiked)
* createComment(postId, text)
* replyToComment(commentId, text)
* deleteComment(commentId)

---

6. COMMENT THREAD UI (WITH REPLIES)
   Create Comment models if needed, or reuse existing.

A comment should support:

* id
* authorName
* authorAvatarUrl?
* createdAt
* text
* parentId? (null for top-level)
* replies: List<Comment> (or build this in UI from flat list)

Rendering rules:

* Show top-level comments in a ListView (inside the page scroll).
* Each comment tile shows:

  * avatar, name, timestamp
  * comment text
  * actions row: Reply, Delete (only if owned by current user), Like (optional if you support)
* Replies are indented (e.g., left padding).
* Support “Reply” flow:

  * Tapping Reply sets composer into “replying to @username” mode
  * Sending posts a reply and attaches it under that comment
  * Provide a small “cancel reply” X in the composer.

Implementation hint:

* Use a flat list from API and group in UI by parentId, OR if API already returns nested replies, render directly.
* Ensure performance: don’t use deeply recursive heavy widgets; keep indentation simple.

---

7. COMMENT COMPOSER (BOTTOM BAR)
   Create: lib/features/post_details/ui/widgets/comment_composer.dart

Features:

* TextField (multiline up to 4 lines)
* Send icon button
* Disabled send when empty
* Reply mode:

  * If replyingTo != null, show a small chip/pill: “Replying to @Name” + X to cancel.

On send:

* If reply mode: call replyToComment(replyingTo.id, text)
* Else: call createComment(postId, text)

Optimistic UI:

* Immediately insert the new comment/reply into the UI with a temporary id, then replace when API returns real id.

---

8. STATE MANAGEMENT
   Use whatever state approach is already in the app (Riverpod/Provider/setState).
   Requirements:

* Loading state (spinner/skeleton)
* Error state (MagnaEmptyState with retry)
* Pull-to-refresh optional but nice
* Optimistic updates for like/comment/reply/delete

Like behavior:

* Toggle like instantly in UI
* If API fails, revert state and show a snackbar/toast.

Delete behavior:

* Remove comment instantly
* If API fails, restore comment and show error.

---

9. FEED INTEGRATION
   From the Feed, ensure:

* Tapping a PostCard navigates to PostDetailsPage
* When user returns (back), the feed card reflects updated likes/comments count if possible.

  * Simple approach: update counts locally before navigation and on pop.
  * Better approach: return updated post snapshot via Navigator pop result.

---

10. DELIVERABLES CHECKLIST

* [ ] New route /post/:postId works
* [ ] PostDetailsPage loads and displays expanded post
* [ ] Comments load and render with replies
* [ ] Reply flow works
* [ ] Delete comment works
* [ ] Like works from both feed and details
* [ ] No duplicated UI (PostCard reused with details mode)
* [ ] Uses design system tokens (no hardcoded styling)

Build it clean, modular, and production-ready.
