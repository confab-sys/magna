We need to upgrade the Builder Profile hero section to support a **cover photo header** and a **QR code action button**.

Context:
This is part of the Flutter Magna app inside the builders feature.

Current hero section already includes:
- avatar
- name
- location
- role chips
- connection stats
- action buttons

We now want to redesign the top hero section so it includes a cover photo area behind the avatar, similar to a modern profile header.

--------------------------------
GOAL
Implement a builder profile hero header with:

1. Cover photo background at the top
2. Circular avatar overlapping the cover photo and content area
3. A QR code icon button in the top-right corner of the cover photo
4. Proper fallback behavior because backend does not yet provide coverPhotoUrl
5. Data model preparation so backend can support it later without major refactor

--------------------------------
UI REQUIREMENTS

Hero header layout should be:

- Large rounded card container
- Top section = cover photo banner
- Cover photo should have rounded top corners
- Avatar should overlap the bottom of the cover photo and the white/dark content card below it
- QR code icon button should appear on the top-right corner of the cover photo area
- Below avatar:
  - builder name
  - optional verification badge
  - location
  - role chips
  - connection stats
  - action buttons

--------------------------------
COVER PHOTO REQUIREMENTS

The backend does not yet support cover photos.

So implement frontend support now in a future-proof way.

Add this field to the model:

final String? coverPhotoUrl;

If `coverPhotoUrl` is available:
- display it using Image.network

If `coverPhotoUrl` is null:
- show a default fallback header background
- use a soft branded placeholder such as:
  - gradient
  - abstract pattern
  - cloud/sky style background
  - neutral branded illustration
- do NOT leave the area blank

Use `ClipRRect` so cover image respects rounded top corners.

Recommended height:
around 140–180 px depending on screen width

--------------------------------
QR ICON BUTTON

Replace the previous plus button with a QR code action button.

Top-right of cover photo should contain:
- circular white or lightly elevated icon button
- icon: QR code / qr_code / qr_code_2
- onTap callback for future use

Add parameter:

final VoidCallback? onQrTap;

Use:
Icon(Icons.qr_code_2_rounded)

This QR button is for profile sharing / quick scan in the future.

--------------------------------
MODEL UPDATE

Update BuilderProfile model to include:

final String? coverPhotoUrl;

Example:

class BuilderProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? coverPhotoUrl;
  final String? headline;
  final String? location;
  final bool isVerified;
  final bool isAvailable;
  final List<String> roles;
  final int connectionsCount;
  final int mutualConnectionsCount;
  final String? bio;
  final List<String> skills;
  ...
}

--------------------------------
TEMPORARY FRONTEND STRATEGY

Because backend has not added cover photo support yet:

1. Add the field to the Dart model now
2. Keep it optional / nullable
3. Create fallback UI if null
4. Structure code so future backend integration only requires wiring API data into `coverPhotoUrl`

Do NOT block implementation waiting for backend.

--------------------------------
BACKEND-READY INSTRUCTION

Also prepare the frontend for future backend support.

Assume backend will later return:

{
  "id": "123",
  "name": "Alvin",
  "avatarUrl": "...",
  "coverPhotoUrl": "...",
  ...
}

If not present, default to null safely.

--------------------------------
WIDGET REQUIREMENTS

Refactor the current hero section into a reusable widget, for example:

BuilderProfileHeroCard

Constructor example:

BuilderProfileHeroCard({
  required BuilderProfile builder,
  this.onConnectTap,
  this.onMessageTap,
  this.onQrTap,
})

Inside the widget:
- render cover photo area
- overlay QR icon button
- render overlapping avatar
- render builder details below

--------------------------------
LAYOUT DETAILS

Suggested structure:

Stack
  - Card background
  - Column
      - Cover photo section
      - Spacing for overlapping avatar
      - Name
      - Location
      - Role chips
      - Connection stats
      - Button row
  - Positioned avatar
  - Positioned QR button

Avatar should partially overlap cover photo and content section.

--------------------------------
FALLBACK RULES

If no cover photo:
- show branded gradient or placeholder background

If no avatar:
- show initials avatar fallback

If no location:
- hide location row cleanly

If no roles:
- hide roles row cleanly

--------------------------------
DELIVERABLE

Update the Builder Profile hero card code to:
1. include cover photo support
2. include QR icon button instead of plus button
3. support nullable `coverPhotoUrl`
4. use fallback header UI when no cover photo exists
5. remain production-ready and easy to connect to backend later


Prepare the system for future backend support of builder cover photos.

Even if backend endpoints are not implemented yet, update the frontend and shared model assumptions so `coverPhotoUrl` is part of the builder profile contract.

For future backend work, note that builder/user profile data should later support:
- avatarUrl
- coverPhotoUrl

The frontend should be implemented now with `coverPhotoUrl` as an optional field.
Do not hard fail if backend does not send it.
Use safe JSON parsing and nullable handling.

Add coverPhotoUrl to backend User model/schema
Update upload-alvin.js to include cover photo URL
Run upload-alvin.js to update data