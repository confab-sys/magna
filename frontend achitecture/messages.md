Build the Messages UI module for the Magna Flutter app.

You must strictly align the implementation to these reference files and treat them as the source of truth:

messages_schema_v2.sql

messages_api_contract_v2.md

messages_backend_adjustments.ts

The goal is to build a production-ready Messages feature using the canonical word conversation everywhere in frontend naming, models, API calls, routes, state management, widgets, and comments.

Do not use the words:

thread

room

chatRoom

threadId

Use only:

conversation

conversationId

member

sender

content

This feature must fit into the existing Magna Flutter architecture below, and must not drift from it:

lib/
app/
app.dart
router.dart
bootstrap.dart
theme/
core/
network/
api_client.dart
endpoints.dart
websocket_client.dart
auth/
storage/
utils/
features/
auth/
feed/
profile/
projects/
jobs/
builders/
friends/
messages/
notifications/
magna_ai/
magna_coin/
magna_school/
magna_podcast/
contracts/
settings/
shared/
widgets/
icons/
constants/

The messages feature must live under:

lib/features/messages/

and follow this clean feature structure:

lib/features/messages/
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
    pages/
    widgets/
    controllers/

Build the full Messages feature with these screens:

MessagesInboxPage

ConversationPage

CreateConversationPage (simple v1 version)

Also build all supporting widgets, models, DTOs, API services, repositories, and state controllers needed for the feature.

1. Core implementation rules

Follow these rules strictly:

The canonical screen flow is:

MessagesInboxPage

ConversationPage(conversationId)

CreateConversationPage

Use conversation as the only container word.

Use camelCase in Dart models and variables.

Assume the backend API contract is the source of truth.

If the backend returns snake_case JSON, create proper DTO mapping into camelCase Dart models.

Do not hardcode endpoint strings inside widgets or controllers. All endpoints must come from core/network/endpoints.dart.

Use the existing api_client.dart for HTTP requests.

Use the existing websocket_client.dart for realtime subscriptions.

Keep the UI clean, modern, lightweight, and responsive.

Do not over-design. Prioritize clarity, scan-ability, speed, and production realism.

Avoid fake functionality not supported by the backend contract.

If a feature is not supported by the contract, structure for it cleanly but label it as future-safe, not active.

2. Files to create

Create all necessary files for the Messages feature. At minimum, include:

lib/features/messages/data/dto/conversation_dto.dart
lib/features/messages/data/dto/message_dto.dart
lib/features/messages/data/dto/member_dto.dart
lib/features/messages/data/dto/message_attachment_dto.dart

lib/features/messages/data/models/conversation_model.dart
lib/features/messages/data/models/message_model.dart
lib/features/messages/data/models/member_model.dart
lib/features/messages/data/models/message_attachment_model.dart

lib/features/messages/data/services/messages_api_service.dart
lib/features/messages/data/repositories/messages_repository_impl.dart

lib/features/messages/domain/entities/conversation_entity.dart
lib/features/messages/domain/entities/message_entity.dart
lib/features/messages/domain/entities/member_entity.dart
lib/features/messages/domain/entities/message_attachment_entity.dart

lib/features/messages/domain/repositories/messages_repository.dart

lib/features/messages/ui/controllers/messages_inbox_controller.dart
lib/features/messages/ui/controllers/conversation_controller.dart
lib/features/messages/ui/controllers/create_conversation_controller.dart

lib/features/messages/ui/pages/messages_inbox_page.dart
lib/features/messages/ui/pages/conversation_page.dart
lib/features/messages/ui/pages/create_conversation_page.dart

lib/features/messages/ui/widgets/conversation_list_item.dart
lib/features/messages/ui/widgets/unread_badge.dart
lib/features/messages/ui/widgets/online_status_dot.dart
lib/features/messages/ui/widgets/conversation_app_bar.dart
lib/features/messages/ui/widgets/message_bubble.dart
lib/features/messages/ui/widgets/message_input_bar.dart
lib/features/messages/ui/widgets/date_separator.dart
lib/features/messages/ui/widgets/typing_indicator.dart
lib/features/messages/ui/widgets/empty_messages_state.dart
lib/features/messages/ui/widgets/empty_conversation_state.dart
lib/features/messages/ui/widgets/message_attachment_preview.dart

If additional helper files are needed, create them cleanly.

3. Endpoint alignment

Update or create the relevant constants in:

lib/core/network/endpoints.dart

Use these endpoint constants aligned to the backend contract:

class Endpoints {
  static const String conversations = '/api/chat/conversations';
  static String conversationMessages(String conversationId) =>
      '/api/chat/conversations/$conversationId/messages';
  static String markConversationRead(String conversationId) =>
      '/api/chat/conversations/$conversationId/read';
  static String messageById(String messageId) =>
      '/api/chat/messages/$messageId';
}

If the backend contract defines extra endpoints for create conversation or edit/delete message, expose them here too.

Do not use the older ambiguous format:

/api/chat/messages/:conversationId

Prefer:

/api/chat/conversations/:conversationId/messages

4. Data model expectations

Build Dart models and DTOs aligned to the new backend contract.

Conversation should support:

id

name

avatarUrl

description

isGroup

createdBy

lastMessagePreview

lastMessageAt

lastSenderId

unreadCount

isPinned

isArchived

notificationPreference

members

Member should support:

id

userId

displayName

username

avatarUrl

role

isOnline

Message should support:

id

conversationId

sender

content

messageType

replyToMessageId

status

attachments

createdAt

editedAt

deletedAt

deliveredAt

readAt

isOwnMessage

MessageAttachment should support:

id

type

url

fileName

mimeType

sizeBytes

thumbnailUrl

Map DTOs carefully from JSON into strongly typed Dart models.

Create enums where useful:

ConversationNotificationPreference

MessageType

MessageStatus

ConversationMemberRole

Handle nulls safely and defensively.

5. Messages Inbox UI requirements

Build MessagesInboxPage as a clean, mobile-first inbox screen.

Layout:

Top section:

page title: Messages

optional search bar below title

optional “new conversation” action button

Body:

list of conversations

pinned conversations appear first

archived conversations excluded from default main view unless already supported

empty state if no conversations exist

Each conversation card must show:

avatar

conversation name

last message preview

timestamp of last activity

unread badge if unread count > 0

online indicator for direct conversation if supported

pin icon subtly if pinned

group indicator if isGroup == true

Behavior:

tap opens ConversationPage(conversationId)

pull to refresh supported

search filters list locally in v1 if backend search is not defined

maintain fast scroll and lightweight rendering

Style:

modern and minimal

compact enough for productivity

use proper spacing, rounded corners, subtle dividers

avoid excessive shadow noise

prioritize readability over flashy decoration

6. Conversation screen requirements

Build ConversationPage as the main realtime chat UI.

App bar:

Include:

back button

avatar

conversation title

subtitle showing either:

online status for direct conversation

member count or group label for group conversation

optional overflow menu icon

Body:

scrollable list of messages

messages grouped in natural chronological order

show date separators between different days

support text messages first

support rendering attachment previews if message has attachments

support reply target preview if replyToMessageId exists and related message is available

deleted messages should render as a muted placeholder if deletedAt != null

edited messages should show a subtle “edited” state

Message bubbles:

Own messages:

aligned right

Other messages:

aligned left

Each bubble should support:

content text

timestamp

status indicator for own messages where relevant

optional sender name for group conversations

attachment preview block if attachments exist

Input bar:

At the bottom:

text input

attachment button

send button

disable send when trimmed input is empty and there are no attachments

structure for future voice note support, but do not fake it if backend does not support it

Behavior:

load messages on page entry

auto-scroll to latest message when entering conversation

on send, optimistically insert message if architecture allows safely

listen for realtime events from websocket

mark conversation as read on open and when appropriate

maintain smooth keyboard handling

respect safe areas

7. Create conversation page requirements

Build a simple but clean CreateConversationPage.

v1 scope:

searchable list of users or placeholder selection flow depending on what backend already supports

allow selecting one or more members

if one member selected, create direct conversation

if multiple members selected, allow optional group name entry

submit to backend through repository/service layer

after success, navigate directly to ConversationPage

If the backend contract does not fully support user search yet, scaffold the page cleanly and isolate mock/dev placeholders so they can be swapped later.

Do not contaminate the rest of the Messages feature with fake data assumptions.

8. State management requirements

Use the project’s preferred state management approach already present in the codebase. If not yet clearly established, use a clean lightweight controller approach consistent with existing modules.

Create controllers for:

inbox state

conversation state

create conversation state

The controllers should handle:

loading

loaded

empty

error

refreshing

sending message

pagination readiness if backend supports it later

Keep UI widgets dumb where possible and move logic into controllers/repositories.

9. Realtime requirements

Use the existing websocket_client.dart integration.

Support event handling for contract-aligned events such as:

message.created

message.updated

message.deleted

conversation.updated

conversation.read

user.typing

user.presence

Implement the integration so that:

inbox updates when new message events arrive

active conversation updates live when a new message arrives

message edit/delete updates the visible message

read events update status where relevant

typing indicator support is scaffolded cleanly

presence updates can toggle online indicator if backend sends them

Do not tightly couple widgets directly to socket code. Route realtime updates through controller/service layers.

10. Error handling and resilience

Implement robust handling for:

empty conversations

empty inbox

failed send

failed fetch

null avatars

unknown message type

deleted messages

missing attachment fields

malformed timestamps

Use safe fallbacks:

avatar placeholder with initials

generic file icon for unknown attachments

human-readable timestamps

retry state for failed sends if reasonable

The UI should never crash just because backend data is messy. Reality is messy. Code should be less stupid than reality.

11. UI/UX standards

Design principles for this Messages module:

high clarity

low friction

minimal taps

strong information hierarchy

social urgency aware

clean scan pattern

consistent spacing

subtle modern visuals

fast-feeling interaction

Avoid:

oversized cards

giant paddings

noisy gradients

decorative clutter

deeply nested widget chaos

business logic inside widget trees

Aim for something that feels like a modern hybrid of:

WhatsApp inbox efficiency

Telegram clarity

Discord structure discipline

iMessage softness

But still clearly Magna-branded and app-consistent.

12. Routing requirements

Update router.dart so the messages routes are properly defined.

Use canonical route naming based on conversation:

Examples:

/messages

/messages/new

/messages/conversation/:conversationId

Ensure tapping a conversation from the inbox navigates correctly into ConversationPage(conversationId).

Remove or refactor any older naming that still references:

thread

threadId

13. Deliverables required from you

When you implement this, provide:

All created and updated files

A short explanation of architecture decisions

Any assumptions made from the backend contract

Any TODOs where backend support is still required

A final checklist confirming:

canonical word is conversation

endpoints match backend contract

DTO mapping is correct

inbox works

conversation page works

create conversation page is scaffolded or functional

websocket integration is connected cleanly

14. Important implementation constraints

Do not rewrite unrelated app modules.

Only touch the Messages feature and tightly related shared network/routing files.

Keep code production-readable and modular.

Do not generate placeholder fluff code with no integration path.

Build with realistic API consumption in mind.

Prefer maintainable code over clever code.

Preserve extensibility for:

replies

file attachments

typing indicators

read receipts

message edits

soft deletes

group conversations

15. Reference-first instruction

Before writing code, inspect and align implementation to these files:

messages_schema_v2.sql

messages_api_contract_v2.md

messages_backend_adjustments.ts

Treat them as the contract authority for:

database-backed message fields

endpoint shapes

naming rules

future-safe feature support

Do not invent conflicting structures.

16. Final build target

The result should be a polished, maintainable, extensible Messages UI module for Magna Flutter that is fully aligned with the new conversation-based backend contract and is ready to connect to real data with minimal additional refactoring.