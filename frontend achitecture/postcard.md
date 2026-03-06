You are the Flutter frontend engineer for the Magna platform.

Your task is to implement a reusable **FeedPostCard** component that represents a social media post in the Magna community feed.

Follow these engineering rules strictly:

• Do not hardcode colors, spacing, or font sizes. Use the Magna design system tokens from:

* theme/colors.dart
* theme/typography.dart
* theme/spacing.dart

• The component must be reusable and accept a **Post model** as input.

• The widget must live inside:
`lib/features/feed/ui/widgets/feed_post_card.dart`

---

POST DATA MODEL

Create a simple domain model if it does not exist:

Post

* id : String
* authorName : String
* authorAvatarUrl : String? (nullable)
* createdAt : DateTime
* title : String
* content : String
* imageUrl : String?
* likesCount : int
* commentsCount : int

---

FEED POST CARD STRUCTURE

The FeedPostCard should visually match a modern social feed card with rounded corners and padding.

Main structure:

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

* Avatar
* Author Info Column

Avatar

* CircleAvatar
* If image exists use NetworkImage
* If not, show first letter of author name
* radius ~18

Author Info Column

* Username (bold)
* Timestamp below (small grey text)

Timestamp format example:
"2 hours ago"
"3 days ago"

RIGHT SIDE
Small pill button labeled **Post**

Button style

* subtle background
* rounded
* small padding

---

2. POST TEXT

Below header add vertical spacing.

Show two text blocks:

Title

* bold
* larger font

Content

* normal body text
* maxLines optional (3)

---

3. IMAGE SECTION (OPTIONAL)

If imageUrl exists display an image.

Requirements:

* Rounded corners (16)
* Full width
* BoxFit.cover
* Height around 220

Wrap with ClipRRect.

---

4. INTERACTION BAR

Below the image add a row containing:

Like
Comment
Share

Each item contains:
Icon + number

Example layout:

Row

* Icon (heart) + likesCount
* Icon (comment) + commentsCount
* Icon (share) + text "Share"

Spacing between items: 24px

Icons should be neutral grey.

---

5. SPACING RULES

Spacing between sections:

Header → Text = MagnaSpacing.sm
Text → Image = MagnaSpacing.md
Image → InteractionBar = MagnaSpacing.md

---

6. FILE ORGANIZATION

Create:

features/feed/
domain/post.dart
ui/widgets/feed_post_card.dart

---


GOAL

The result should look like a modern social media feed card with:

• avatar + name + time
• post title and content
• large rounded image
• like/comment/share bar

The component must be clean, modular, and reusable across the feed and post detail screens.
