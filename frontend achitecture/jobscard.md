You are the Flutter frontend engineer for the Magna platform.

Your task is to create a reusable **JobCard** widget that appears inside the main feed alongside PostCard and ProjectCard components.

The card must visually match the existing Magna feed cards but display job opportunity information.

---

ENGINEERING RULES

• Do NOT hardcode colors, font sizes, or spacing.
• Use design tokens from:

* theme/colors.dart
* theme/typography.dart
* theme/spacing.dart

• The widget must be reusable and driven entirely by a **Job model**.

• Place the widget here:

lib/features/jobs/ui/widgets/job_card.dart

---

JOB MODEL

Create this domain model if it does not exist.

Job

* id : String
* title : String
* description : String
* companyName : String
* companyLogoUrl : String?
* companyVerified : bool
* jobImageUrl : String?
* location : String
* salary : String?
* jobType : String
* deadline : DateTime?
* createdAt : DateTime
* likesCount : int
* commentsCount : int

---

CARD CONTAINER

Container
padding: MagnaSpacing.md
borderRadius: 16
background: surface color

Child → Column

---

1. HEADER ROW

Row (spaceBetween)

LEFT SIDE

Row

* Company Avatar
* Company Info Column

Avatar rules

If companyLogoUrl exists → NetworkImage
Else → show first letter of company name

Company Info Column

• Company name (bold)
• Timestamp below ("3h ago")

If companyVerified == true show a small verified badge.

RIGHT SIDE

Chip showing jobType

Examples

FULL TIME
PART TIME
CONTRACT
INTERNSHIP

---

2. JOB IMAGE BANNER

If jobImageUrl exists show a banner image.

Requirements

• Full width image
• Height ~180–220
• Rounded corners (16)
• BoxFit.cover

Wrap with ClipRRect.

Example structure

ClipRRect
→ Image.network(jobImageUrl)

---

3. JOB TITLE

Large bold title

Example

"Senior Flutter Developer"

---

4. JOB DESCRIPTION

Short preview text

maxLines: 2
overflow: ellipsis

---

5. KEY INFORMATION ROW

Display important job facts with icons.

Row or Wrap layout

📍 location
💰 salary (if exists)
⏰ deadline ("Closes in 5 days")

---

6. ACTION BUTTON ROW

Row (spaceBetween)

LEFT SIDE

Primary button

"Apply"

RIGHT SIDE

Optional button

"View Job"

---

7. ENGAGEMENT BAR

Below the actions show the interaction row.

Row

Like icon + likesCount
Comment icon + commentsCount
Share icon + text "Share"

Spacing between items: 24px

Icons should be neutral grey.

---

8. FILE STRUCTURE

features/jobs/
domain/job.dart
ui/widgets/job_card.dart

---

9. FEED INTEGRATION

FeedPage renders mixed content.

Example

If item.type == "post"
→ FeedPostCard

If item.type == "project"
→ ProjectCard

If item.type == "job"
→ JobCard

---

GOAL

The JobCard should communicate clearly:

• who is hiring
• what role is available
• visual banner for attention
• job details (location, salary, deadline)
• ability to apply
• social engagement (like, comment, share)

The card must visually match the Magna feed style.
