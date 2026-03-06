You are the Flutter frontend engineer for the Magna platform.

Your task is to create a reusable **ProjectCard** widget that appears inside the main feed alongside normal posts. The card visually matches the FeedPostCard style but displays project information and opportunities for developers to participate.

Follow these engineering rules strictly:

• Use the Magna design tokens from:

* theme/colors.dart
* theme/typography.dart
* theme/spacing.dart

• Do not hardcode colors or font sizes.

• The card must be reusable and driven entirely by a **Project model**.

• Place the widget in:

lib/features/projects/ui/widgets/project_card.dart

---

PROJECT MODEL

Create a domain model if it does not exist.

Project

* id : String
* title : String
* shortDescription : String
* ownerName : String
* ownerAvatarUrl : String?
* createdAt : DateTime
* techStack : List<String>
* lookingForContributors : bool
* maxContributors : int?
* repositoryUrl : String?
* liveDemoUrl : String?
* status : String
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

* Avatar (CircleAvatar)
* Owner name
* Timestamp below

Avatar rules
If avatar exists → NetworkImage
If not → first letter of owner name

Timestamp example
"2h ago"
"3d ago"

RIGHT SIDE

Status pill (small chip)

Example values
OPEN
IN PROGRESS
COMPLETED

---

2. PROJECT TITLE

Large bold title

Example
"Magna AI Voice Assistant"

---

3. PROJECT DESCRIPTION

Short description
maxLines: 2
overflow: ellipsis

---

4. TECH STACK

Display tech stack as chips.

Example row

Flutter   Cloudflare   D1   Workers

Limit to first 4 chips.
If more exist show "+X".

---

5. CONTRIBUTOR NEEDS

If lookingForContributors == true show a small row:

Icon: group
Text example:

"Looking for contributors"

If maxContributors exists show:

"2 / 5 slots filled"

---

6. ACTION BUTTON ROW

Row (spaceBetween)

LEFT SIDE

Primary button

"View Project"

This opens project details.

RIGHT SIDE

If repositoryUrl exists show GitHub icon button.

If liveDemoUrl exists show external-link icon button.

---

7. ENGAGEMENT BAR (SAME STYLE AS POSTS)

Below everything add the interaction row.

Row:

Like icon + likesCount
Comment icon + commentsCount
Share icon + text "Share"

Spacing between items: 24px

Icons should be neutral grey.

---

8. FILE STRUCTURE

features/projects/
domain/project.dart
ui/widgets/project_card.dart

---

9. EXAMPLE USAGE

Inside FeedPage render mixed feed items:

ListView.builder

If item.type == "post"
→ FeedPostCard

If item.type == "project"
→ ProjectCard

---

GOAL

The ProjectCard should visually match the Magna feed style while clearly communicating:

• who owns the project
• what the project is
• what technologies are used
• whether contributors are needed
• how users can interact (view, like, comment, share)
