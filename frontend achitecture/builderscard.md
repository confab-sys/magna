Build a production-ready Flutter widget for the Magna app called `BuilderCard`.

Context:
This card belongs in the `features/builders/ui/widgets/` layer of our Flutter architecture. It is used in the Builders feed to display a developer/builder profile summary in a compact, premium, dark-themed card. The goal is fast scanning, not full profile display. The card must feel like a blend of LinkedIn, GitHub, and Upwork, but styled for Magna.

Architecture context:
Use our Flutter feature-based structure:
lib/
  features/
    builders/
      domain/
      data/
      ui/
        widgets/
          builder_card.dart

Design intent:
This card is not a resume block. It is a collaboration signal card.
It should communicate:
1. identity
2. what the builder does
3. what they are looking for
4. top skills
5. location + availability
6. social proof links
7. actions to connect or message

Important rules:
- Show at most 2 visible items for each chip/list category.
- If there are more than 2 items, show a `+N` overflow chip.
- Keep the card compact, premium, modern, and easy to scan.
- Use clean spacing, rounded corners, subtle borders, and strong hierarchy.
- Must be responsive and work well on mobile widths.
- Use null-safe Flutter code.
- Write reusable, clean, maintainable code.
- Do not hardcode fake UI only; make it data-driven.
- Include mock preview/sample usage inside the file or in example code.

Color/theme direction:
- Dark background card
- Warm golden/orange accent for key text and primary CTA
- Soft outlined secondary button
- Chips should have category-based visual hierarchy but remain elegant
- Premium modern appearance, not playful
- Make it fit Magna’s visual language

Data model:
Create a model or expect a model like this:

class BuilderCardData {
  final String id;
  final String name;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final String headline;
  final String? bio;
  final List<String> categories;     // e.g. ["AI/ML Engineer", "Backend Developer", "Designer"]
  final List<String> lookingFor;     // e.g. ["Frontend Developer", "UI Designer", "Project Manager"]
  final List<String> skills;         // e.g. ["Python", "SQL", "TensorFlow", "Dart"]
  final String? location;            // e.g. "Nairobi, Kenya"
  final bool isAvailable;
  final List<BuilderSocialLink> socialLinks;
}

class BuilderSocialLink {
  final String type;   // website, github, twitter, whatsapp, linkedin, etc.
  final String label;  // display text
  final String url;
}

Main widget requirements:
Create a widget:
`class BuilderCard extends StatelessWidget`

Constructor should accept:
- `BuilderCardData builder`
- `VoidCallback? onConnectTap`
- `VoidCallback? onMessageTap`
- `ValueChanged<BuilderSocialLink>? onSocialTap`
- optional `VoidCallback? onCardTap`

UI structure:
1. Card container
   - rounded corners
   - dark background
   - thin subtle border
   - comfortable padding
   - premium elevation or shadow, but restrained

2. Top row
   - avatar on left
   - on right: name and headline
   - name should be prominent
   - headline should be 1 line or max 2 lines with ellipsis
   - do NOT show email on the card unless needed for fallback; prefer username or nothing under headline
   - if avatarUrl is null or invalid, show initials avatar fallback

3. Categories section
   - label optional, or just chips directly
   - show first 2 category chips
   - if more exist, show overflow chip like `+2`

4. Looking For section
   - explicitly include a small section title: `Looking for`
   - show first 2 chips
   - if more exist, show overflow chip
   - visually distinguish these chips from regular skills/categories so intent is clear

5. Skills section
   - section title: `Skills`
   - show first 2 skill chips
   - if more exist, show overflow chip
   - compact chips, readable, premium spacing

6. Meta info row
   - location with icon if available
   - availability badge with icon/color state
   - examples:
     - Available
     - Not Available
   - if location is null, do not leave awkward empty space

7. Social links row
   - show at most 2 visible social items
   - if more than 2, show a `+N` chip/button
   - each visible link should have icon + label
   - clicking a social link should call `onSocialTap`
   - choose icons based on social link type
   - use lucide/phosphor-like equivalents available in Flutter, preferably from Icons or flutter_svg if needed
   - keep implementation simple and dependable

8. Bottom action row
   - two buttons:
     - primary: `Connect`
     - secondary: `Message`
   - Connect should be filled/emphasized
   - Message should be outlined/subtle
   - buttons should share row width nicely and feel modern

Behavior requirements:
- Entire card may be tappable if `onCardTap` is provided
- Buttons must have proper touch targets
- Text overflow must be handled gracefully
- Lists must not break layout on small screens
- Chips should wrap properly
- If a section has no data, hide it cleanly
  - no empty “Looking for” if list is empty
  - no empty “Skills” if list is empty
  - no social row if no social links
  - no location if absent

Implementation details:
- Build small helper widgets if useful, for example:
  - `_SectionTitle`
  - `_SmartChipList`
  - `_OverflowChip`
  - `_SocialLinkItem`
  - `_AvailabilityBadge`
  - `_AvatarView`
- Write a reusable helper that receives a list and returns first 2 + overflow count.
- Keep code modular and readable.
- Use `Wrap` for chips.
- Use `InkWell` or `GestureDetector` appropriately.
- Keep the widget stateless unless state is absolutely needed.
- Make the code compile cleanly.

Chip behavior:
Implement a reusable chip renderer where:
- only first 2 items show
- if item count > 2, append an overflow chip with `+${count - 2}`
- style variants:
  - category chip
  - lookingFor chip
  - skill chip
  - overflow chip

Typography hierarchy:
- Name: bold and most prominent
- Headline: muted but readable
- Section titles: small uppercase or semibold, subtle
- Meta/social text: compact and clean
- Avoid dense paragraph blocks

Do not do this:
- Do not make the card too tall
- Do not show full bio paragraph
- Do not expose too much data at once
- Do not use overly bright colors everywhere
- Do not clutter with too many icons
- Do not use tables
- Do not write placeholder-only code without structure

Need from you:
1. Full Flutter code for `builder_card.dart`
2. Supporting model classes if needed in same snippet
3. Helper widgets/functions in same file for now
4. A sample `BuilderCardData` instance
5. A simple demo widget/page showing the card in use

Use Material 3. Prefer clean native Flutter widgets over overengineering. Keep everything in one file for the first pass, but structure it so it can later be split into smaller files. Make sure the widget is feed-ready and not full-profile sized.

Critical UI rule:
For categories, lookingFor, skills, and socialLinks, show only the first 2 items and then a final overflow chip/button like `+N` if more items exist. This rule must be implemented consistently across all those sections.

Expected final result:
A polished, production-ready Builder card widget for Flutter that is compact, elegant, dark-themed, mobile-responsive, and optimized for the Magna Builders feed.


i want you to create a script and add this user ( Name: Alvin
- Headline: Data Scientist and AI Specialist
- Categories: ["AI/ML Engineer", "Backend Developer", "Designer", "Developer"]
- Looking For: ["Frontend Developer", "UI Designer", "Mobile Engineer"]
- Skills: ["Python", "SQL", "JavaScript", "Machine Learning", "Data Analytics"]
- Location: "Nairobi, Kenya"
- isAvailable: true
- Social links:
  - Website
  - GitHub
  - Twitter
  - WhatsApp) and then on the builders page to fetch the builders card with the users details and also use the alvin png as our users profile pic