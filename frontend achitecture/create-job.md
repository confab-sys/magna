You are the Flutter frontend engineer for the Magna platform.

Your task is to create a new screen called **CreateJobPage** that allows users to create and publish a job posting fully compatible with the existing backend API and matching Magna’s current UI system.

The page must follow Magna’s design system and existing frontend architecture.

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
- Keep the page production-ready, modular, and clean.
- The UI must visually match the existing Create Project page and the existing JobCard style.

============================================================
FILE STRUCTURE
============================================================

Create the following files:

lib/features/jobs/
  ui/pages/create_job_page.dart
  ui/widgets/job_banner_picker.dart
  ui/widgets/job_form_section.dart
  data/job_create_api.dart
  domain/create_job_request.dart

If shared widgets already exist for form sections, image pickers, dropdowns, or submit bars, reuse them instead of duplicating.

============================================================
ROUTING
============================================================

Add a new route:

/create-job

Register it in:

lib/app/router.dart

Example navigation:

context.push('/create-job')

============================================================
PAGE GOAL
============================================================

The CreateJobPage should allow a user to successfully submit a job posting to the backend endpoint:

POST /api/jobs

The payload must match the backend schema.

============================================================
BACKEND-COMPATIBLE FIELDS
============================================================

The form must support these fields:

Required:
- title : String
- description : String

Optional:
- company_id : String
- location : String
- salary : String
- job_type : String
- deadline : DateTime
- category_id : String
- job_image_url : String

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
- Title: "Create Job"
- Optional draft/pending indicator if useful

Body should be divided into reusable visual sections using a widget like:

JobFormSection

Recommended form sections:

1. Job Banner
2. Company
3. Core Details
4. Logistics
5. Classification
6. Submission

============================================================
SECTION 1 — JOB BANNER
============================================================

Create widget:

JobBannerPicker

Features:
- Allow selecting a banner image for the job
- Show preview after image is selected
- Allow remove / replace image
- Use rounded corners
- Full width
- Height around 180–220

Placeholder state:
- Icon
- Text: "Add Job Banner"

Important:
Handle image in one of these ways:

Option A:
If backend supports only job_image_url,
upload the image first using the existing upload endpoint (for example /api/files/upload),
then store the returned URL in job_image_url.

Option B:
If backend is later upgraded for multipart support, structure the code so it can be adapted cleanly.

For now, implement the frontend assuming image is uploaded first, then the returned URL is sent in the create job payload.

============================================================
SECTION 2 — COMPANY
============================================================

Add a Company Selector field.

Field:
- company_id

UI behavior:
- Dropdown, searchable dropdown, or selector modal
- Show existing companies by name
- Save selected company UUID internally

Display:
- Company name in the UI
- Store selected company_id in the request model

If no company data source exists yet:
- Build the selector with mock data or placeholder structure that can be easily connected later

Optional helper text:
"Select the company posting this job"

============================================================
SECTION 3 — CORE DETAILS
============================================================

Fields:
- Job Title (required)
- Description (required)

Rules:
- Title = single-line text field
- Max length around 120 characters
- Description = multiline text field
- Description should support long-form job details, responsibilities, and requirements

Validation:
- Title cannot be empty
- Description cannot be empty

============================================================
SECTION 4 — LOGISTICS
============================================================

Fields:
- Location
- Salary
- Deadline

Location:
- Text field
- Placeholder examples:
  - Remote
  - Nairobi, Kenya

Salary:
- Text field
- Placeholder examples:
  - KES 150k - 200k
  - Negotiable

Deadline:
- Date picker
- Save as DateTime
- Show formatted date in the UI

Validation:
- If deadline is selected, it must be today or in the future

============================================================
SECTION 5 — CLASSIFICATION
============================================================

Fields:
- Job Type
- Category

Job Type:
Use a dropdown with these options:
- Full-time
- Part-time
- Contract
- Internship
- Freelance

Store selected value in:
- job_type

Category:
Use a dropdown / selector for categories

Suggested seeded values:
- tech
- design
- business
- social

Store selected category UUID/value in:
- category_id

If categories are already fetched elsewhere in the app, reuse that source.
If not, scaffold the category dropdown cleanly so it can be wired later.

============================================================
FORM MODEL
============================================================

Create a DTO / request model:

CreateJobRequest

Fields:
- title
- description
- companyId
- location
- salary
- jobType
- deadline
- categoryId
- jobImageUrl

Implement:
- toJson()

Map fields to backend keys exactly:

{
  "title": ...,
  "description": ...,
  "company_id": ...,
  "location": ...,
  "salary": ...,
  "job_type": ...,
  "deadline": ...,
  "category_id": ...,
  "job_image_url": ...
}

Make sure null values are either omitted cleanly or sent in a backend-safe way.

============================================================
API INTEGRATION
============================================================

Create:

lib/features/jobs/data/job_create_api.dart

Functions:
- uploadJobImage(File imageFile) -> String imageUrl
- createJob(CreateJobRequest request)

Behavior:
1. If the user selected an image:
   - Upload image first
   - Receive URL
   - Set jobImageUrl in request
2. Send POST request to /api/jobs using ApiClient
3. Include auth token automatically through existing auth interceptors / middleware

Use:
- Authorization: Bearer <token>
through the existing authenticated API client

============================================================
FORM SUBMISSION FLOW
============================================================

Bottom fixed submit bar should have:

- Save Draft (optional placeholder for now if backend doesn’t support job drafts)
- Publish Job

If drafts are not supported by backend yet:
- Save Draft button can be hidden
OR
- disabled with TODO comment
OR
- saved locally only if local draft system exists

Primary action:
- Publish Job

On submit:
- Validate required fields
- Upload image first if selected
- Build CreateJobRequest
- Send request to backend
- Show loading state during submission
- Disable submit button while submitting

============================================================
SUCCESS FLOW
============================================================

On success:
- Show snackbar:
  "Job created successfully"
- Redirect user to:
  /job/{jobId}
  using the returned created job id if the backend response includes it

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
- Keep the page visually consistent with the Magna Create Project page
- Make the create flow feel focused and professional, not cluttered

============================================================
DELIVERABLES CHECKLIST
============================================================

- [ ] CreateJobPage created
- [ ] Route /create-job registered
- [ ] Banner image picker works
- [ ] Company selector works or is scaffolded cleanly
- [ ] Title and description fields work
- [ ] Job type dropdown works
- [ ] Category selector works
- [ ] Location, salary, and deadline fields work
- [ ] Validation works
- [ ] CreateJobRequest DTO maps correctly to backend JSON
- [ ] Image upload flow works before create request
- [ ] POST /api/jobs request works
- [ ] Successful submission redirects to job details
- [ ] Uses Magna design tokens only

Build it clean, modular, and production-ready.