Build the Notifications feature for the Magna Flutter app using a WebSocket-first architecture.

The notifications system must prioritize real-time delivery through WebSockets and use REST only as fallback, recovery, or synchronization when WebSocket fails, disconnects, or misses events.

This feature must support notifications for these user events:

when a user posts a job

when a user posts a project

when a user creates a post

when someone likes my post, project, or job

when someone comments on my post, project, or job

when someone sends me a friend request

Do not build fake demo behavior. Connect this to the real Magna architecture and real backend design.

Use the current stack assumptions:

Flutter frontend

Cloudflare Workers backend

WebSocket realtime worker

REST API for backup sync and read updates

feature-based frontend architecture

shared websocket_client.dart, api_client.dart, and endpoints.dart

The goal is:

notifications arrive instantly through WebSocket when possible

the notifications screen stays accurate even if WebSocket disconnects

REST is used only to recover state, backfill missed notifications, and mark items as read

unread count remains correct

notifications navigate to the relevant screens

Build this as a production-quality feature, not a mockup.

1. Core architecture rule

Use this priority order:

Primary source of truth for delivery:

WebSocket

Secondary recovery/sync source:

REST

That means:

on app/session start, establish WebSocket subscription for user notifications

when a realtime event arrives, immediately insert/update the notification in local state

if WebSocket is disconnected, reconnect

if reconnect happens or socket fails, use REST to backfill and resync notifications

do not rely on periodic polling as the primary method

This is WebSocket-first, REST-recovery, not REST-first with socket decoration.

2. Feature requirements

Build a complete Notifications module with:

notifications page

notification model / DTO mapping

WebSocket subscription handling

notifications controller/state

notifications repository

notifications API fallback service

unread count

mark-as-read support

tap-to-navigate support

deduplication and sync recovery logic

3. Canonical naming

Use only:

notification

notifications

notificationType

unreadCount

Do not invent alternate naming like:

alerts

events

activity feed

inbox alerts

Keep naming precise and stable.

4. Flutter folder structure

Implement under:

lib/features/notifications/

Use this structure:

lib/features/notifications/
  data/
    dto/
    models/
    services/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  ui/
    controllers/
    pages/
    widgets/

Create or update files such as:

lib/features/notifications/data/dto/notification_dto.dart
lib/features/notifications/data/models/notification_model.dart
lib/features/notifications/data/services/notifications_api_service.dart
lib/features/notifications/data/services/notifications_socket_service.dart
lib/features/notifications/data/repositories/notifications_repository_impl.dart

lib/features/notifications/domain/entities/notification_entity.dart
lib/features/notifications/domain/repositories/notifications_repository.dart

lib/features/notifications/ui/controllers/notifications_controller.dart
lib/features/notifications/ui/pages/notifications_page.dart
lib/features/notifications/ui/widgets/notification_list_item.dart
lib/features/notifications/ui/widgets/empty_notifications_state.dart
lib/features/notifications/ui/widgets/notification_unread_dot.dart

If helper files are needed, create them cleanly.

5. Backend communication strategy
WebSocket must be primary

Use the existing:

lib/core/network/websocket_client.dart

Create a notifications socket layer that:

subscribes to user-specific notification events

listens for new notification creation

listens for read-state updates

listens for unread count updates

reconnects safely

avoids duplicate subscriptions

disposes listeners properly

REST must be fallback / sync only

Use REST for:

initial recovery if socket connection is unavailable

backfill after reconnect

manual refresh

mark-as-read requests

optional mark-all-as-read requests

consistency repair if local state appears stale

Do not design the screen as “fetch from REST and then also listen to socket.”
Design it as “listen to socket first; use REST when you need to recover missing truth.”

6. REST endpoints

Use the backend notifications endpoints:

GET /api/notifications
PATCH /api/notifications/:id/read

If bulk mark-all-as-read exists, support it. If not, scaffold it safely.

Update core/network/endpoints.dart with helpers like:

class Endpoints {
  static const String notifications = '/api/notifications';

  static String markNotificationRead(String notificationId) =>
      '/api/notifications/$notificationId/read';
}

Do not hardcode endpoints inside widgets.

7. Notification model design

Build a notification model/entity that supports all required types.

Fields should support:

id

type

title

message

isRead

createdAt

actorId

actorName

actorAvatarUrl

targetType

targetId

metadata

Recommended enums:

enum NotificationType {
  jobPosted,
  projectPosted,
  postCreated,
  postLiked,
  projectLiked,
  jobLiked,
  postCommented,
  projectCommented,
  jobCommented,
  friendRequestReceived,
  unknown,
}
enum NotificationTargetType {
  post,
  project,
  job,
  user,
  friendRequest,
  unknown,
}

Map backend strings in the DTO layer carefully.

8. WebSocket event contract

Design the frontend around websocket events such as:

notification.created

notification.updated

notification.read

notifications.count.updated

If backend names differ, isolate the mapping in the socket service so the rest of the app stays clean.

Expected event behavior:

notification.created

add new notification to local list at the top

increment unread count if unread

deduplicate by id

notification.updated

update an existing notification if data changed

notification.read

update local read state

decrement unread count if needed

notifications.count.updated

synchronize unread count from server if available

9. Recovery logic

This is critical.

When the socket disconnects or reconnects, do not assume local state is complete.

Implement this logic:

connect socket

subscribe to notification events

if socket connection fails on startup:

fallback to REST fetch

if socket reconnects after interruption:

trigger REST sync/backfill

if local state and unread count drift:

use REST to repair state

This gives you a resilient system.

Suggested behavior:

WebSocket = live stream

REST = repair kit

That is the correct mental model.

10. Controller/state requirements

Create a NotificationsController responsible for:

initializing socket subscription

reacting to socket events

local notification insertion and update

unread count tracking

fallback REST loading

recovery sync after reconnect

mark-as-read action

manual refresh

deduplication by notification id

Suggested public methods:

initialize()

subscribeToNotifications()

handleSocketNotificationCreated(...)

handleSocketNotificationUpdated(...)

handleSocketNotificationRead(...)

syncFromRest()

markAsRead(notificationId)

refreshNotifications()

dispose()

Keep socket lifecycle out of widget trees.

11. Repository responsibilities
notifications_socket_service.dart

Responsible for:

subscribing to websocket events

mapping raw websocket payloads into DTOs/models

exposing event streams or callbacks

reconnection-safe listener setup

notifications_api_service.dart

Responsible for:

fetching notifications from REST

marking notifications as read

optional bulk mark-all-as-read

notifications_repository_impl.dart

Responsible for:

combining socket + REST behavior

exposing clean methods to controller

deduplicating by notification id

reconciling local state after reconnect

The repository should unify both channels so the UI does not care where updates came from.

12. Notifications page UI requirements

Build NotificationsPage as a real product screen.

Screen should include:

title: Notifications

optional mark all as read action

unread/read visual distinction

list of notifications

empty state

pull to refresh

maybe subtle connection state indicator only if useful, not noisy

Each notification item should show:

actor avatar or icon

primary text

secondary message if needed

timestamp

unread indicator

Examples:

Brian liked your project

Sandra commented on your post

Walter sent you a friend request

New job posted by Kelvin

New project posted by Magna Builders

Unread notifications should be visually stronger than read ones.

Keep the screen clean, modern, and scannable.

13. Tap behavior

When a user taps a notification:

mark it as read locally immediately

send REST mark-as-read request

navigate to the correct screen using targetType and targetId

Examples:

post → PostDetailsPage(postId)

project → ProjectDetailsPage(projectId)

job → JobDetailsPage(jobId)

friend request → friends / requests page or user profile

unknown target → fail gracefully

Do not crash on missing navigation target.

14. Trigger scenarios the frontend must support

The frontend must correctly display notifications generated by the backend for:

content creation

new post

new project

new job

interactions

like on my post

like on my project

like on my job

comment on my post

comment on my project

comment on my job

social

friend request received

The frontend does not decide recipients. The backend does.

15. Unread count behavior

Unread count must be maintained from socket events first.

Rules:

increment on new unread notification

decrement when notification becomes read

update from notifications.count.updated event if server sends it

recover via REST sync if count drifts

Expose unread count in a way that can power:

notifications page header

bottom tab badge

any shared badge widget

16. Deduplication rules

Prevent duplicate notifications.

Rules:

deduplicate by id

if same id arrives from socket and already exists locally, update instead of insert

if REST sync returns an existing id, merge or ignore appropriately

preserve ordering by createdAt

Do not allow duplicate rows due to reconnect or refresh overlap.

17. UI polish rules

Keep the Notifications screen:

clean

dark-theme compatible

readable

not noisy

compact but elegant

Avoid:

giant cards

excessive colors

debug-style raw payload rendering

overly complex animations

This is a product notification center, not a server log dumpster.

18. Authentication and socket lifecycle

When the user is authenticated:

connect WebSocket with user auth context/token

subscribe once

do not open duplicate listeners on rebuild

reconnect safely

dispose listeners on logout or controller teardown

If auth is lost, cleanly unsubscribe and clear sensitive state as appropriate.

19. Navigation + app integration

Ensure this feature integrates with existing app routing and tabs.

If the app uses a notifications bottom tab:

unread badge should bind to the same unread count source

If the app already has a shared badge system:

wire notifications count into it cleanly

20. Deliverables

Return:

all created and updated files

notification DTO/model/entity mapping

socket service

REST fallback service

repository implementation

controller/state logic

notifications page UI

navigation handling

unread count handling

explanation of socket-first + REST-fallback design

any backend assumptions or TODOs

Also provide a final checklist confirming:

socket-first flow works

REST fallback works

reconnect recovery works

notifications deduplicate correctly

unread count stays accurate

mark as read works

navigation works

21. Important constraint

Do not rewrite unrelated features.

Touch only:

notifications feature

websocket integration pieces if needed

endpoint constants

shared unread badge plumbing if needed

Do not break auth, feed, projects, jobs, messages, or routing.