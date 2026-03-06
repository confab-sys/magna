You are the Flutter frontend engineer for the Magna platform.

Your task is to create a new screen called **CreatePostPage** that allows users to create and publish a normal social post fully compatible with the backend API and matching Magna’s current design system.

The page must follow Magna’s frontend architecture and integrate cleanly into the existing feed flow.

============================================================
GENERAL RULES
============================================================

- Do NOT hardcode colors, spacing, border radius, or typography.
- Use Magna design tokens from:
  - lib/theme/colors.dart
  - lib/theme/typography.dart
  - lib/theme/spacing.dart
- Reuse shared UI components where possible.
- Follow the existing feature-based folder architecture.
- Use proper form validation.
- Keep the page clean, modular, and production-ready.
- The UI must visually match the existing Create Project page and Create Job page where appropriate.

============================================================
FILE STRUCTURE
============================================================

Create the following files:

lib/features/feed/
  ui/pages/create_post_page.dart
  ui/widgets/post_image_picker.dart
  ui/widgets/post_form_section.dart
  data/post_create_api.dart
  domain/create_post_request.dart

If shared widgets already exist for form sections, image pickers, dropdowns, or submit bars, reuse them instead of duplicating.

============================================================
ROUTING
============================================================

Add a new route:

/create-post

Register it in:

lib/app/router.dart

Example navigation:

context.push('/create-post')

Also connect this route to the existing “Create Post” action in the FeedPage floating action menu or create menu.

============================================================
PAGE GOAL
============================================================

The CreatePostPage should allow a user to successfully submit a post to the backend endpoint:

POST /api/posts

The payload must match the backend schema.

============================================================
BACKEND-COMPATIBLE FIELDS
============================================================

The form must support these fields:

Required:
- title : String

Optional:
- content : String
- post_type : String
- category_id : String
- image_url : String

============================================================
PAGE LAYOUT
============================================================

Create a scrollable form page using:

Scaffold
AppBar
Scrollable body
Fixed submit bar at bottom

AppBar:
- Back button
- Title: "Create Post"

Body should be divided into reusable sections using a widget like:

PostFormSection

Recommended sections:

1. Media Attachment
2. Core Content
3. Classification
4. Submission

============================================================
SECTION 1 — MEDIA ATTACHMENT
============================================================

Create widget:

PostImagePicker

Features:
- Allow selecting a single image for the post
- Show preview after image is selected
- Allow remove / replace image
- Use rounded corners
- Full width
- Height around 180–220

Placeholder state:
- Icon
- Text: "Add Post Image"

Important:
The backend currently expects image_url, not raw file upload in the create post request.

So implement this flow:
1. User selects image
2. Upload image first using existing upload endpoint (example: /api/files/upload)
3. Receive uploaded image URL
4. Include that URL in image_url when creating the post

Structure the code cleanly so it can be adapted later if backend adds multipart support.

============================================================
SECTION 2 — CORE CONTENT
============================================================

Fields:
- Title (required)
- Content (optional)

Title:
- Single-line text field
- Max length around 120 characters
- Placeholder example: "What’s happening at Magna today?"

Content:
- Multiline text field
- Supports longer post body
- Placeholder example: "Write your post here..."

Validation:
- Title cannot be empty
- Content may be empty if title exists

============================================================
SECTION 3 — CLASSIFICATION
============================================================

Fields:
- Category
- Post Type

Category:
- Dropdown / selector
- Examples: tech, design, business, social
- Store selected value in category_id

Post Type:
- Default value = "regular"
- Keep hidden from normal users unless needed
- Optionally allow admin/test mode to select:
  - regular
  - news

For now:
- Default post_type to "regular"
- No need to expose complex UI for this unless app already supports role-based controls

============================================================
FORM MODEL
============================================================

Create a DTO / request model:

CreatePostRequest

Fields:
- title
- content
- postType
- categoryId
- imageUrl

Implement:
- toJson()

Map fields to backend keys exactly:

{
  "title": ...,
  "content": ...,
  "post_type": ...,
  "category_id": ...,
  "image_url": ...
}

Make sure null values are either omitted cleanly or sent in a backend-safe way.

============================================================
API INTEGRATION
============================================================

Create:

lib/features/feed/data/post_create_api.dart

Functions:
- uploadPostImage(File imageFile) -> String imageUrl
- createPost(CreatePostRequest request)

Behavior:
1. If the user selected an image:
   - Upload image first
   - Receive URL
   - Set imageUrl in request
2. Send POST request to /api/posts using ApiClient
3. Include auth token automatically through existing auth interceptors / middleware

Use:
- Authorization: Bearer <token>
through the existing authenticated API client

============================================================
FORM SUBMISSION FLOW
============================================================

Bottom fixed submit bar should have:

- Cancel
- Publish Post

Primary action:
- Publish Post

On submit:
- Validate required fields
- Upload image first if selected
- Build CreatePostRequest
- Send request to backend
- Show loading state during submission
- Disable submit button while submitting

Cancel action:
- Pop the page or show confirmation if there is unsaved content

============================================================
SUCCESS FLOW
============================================================

On success:
- Show snackbar:
  "Post created successfully"
- Redirect user to:
  /post/{postId}
using the returned created post id if the backend response includes it

If the backend response shape differs, adapt using the actual response body.

============================================================
ERROR HANDLING
============================================================

- Show inline validation errors below fields
- Show snackbar or error state on API failure
- Keep user-entered data intact if submission fails
- Show upload failure separately if image upload fails

============================================================
UX DETAILS
============================================================

- Use keyboard-safe scrolling
- Ensure the bottom submit bar remains usable when keyboard is open
- Use proper field spacing and visual grouping
- Show selected image preview elegantly
- Keep the page visually consistent with Magna’s create flows
- The page should feel lightweight and fast, not heavy like project/job forms

============================================================
DELIVERABLES CHECKLIST
============================================================

- [ ] CreatePostPage created
- [ ] Route /create-post registered
- [ ] Post image picker works
- [ ] Title field works
- [ ] Content field works
- [ ] Category selector works
- [ ] post_type defaults to "regular"
- [ ] CreatePostRequest DTO maps correctly to backend JSON
- [ ] Image upload flow works before create request
- [ ] POST /api/posts request works
- [ ] Successful submission redirects to post details
- [ ] Uses Magna design tokens only

Build it clean, modular, and production-ready.