Build a new Flutter feature called Magna AI for the Magna app.

This is not just a simple chat screen.
It is the AI home + AI conversation system for Magna.

The screen must function as an AI command center where users can:

start conversations with Magna AI

use quick AI actions

type prompts

attach images

use voice input scaffolding

see and open previous conversation history

continue old chats from a conversation panel

A critical requirement:

The Magna AI page must include a conversation panel that stores and shows chat history.

Users must be able to:

see previous AI conversations

tap a conversation to reopen it

start a new conversation

continue chatting inside the selected conversation

keep the active conversation state cleanly managed

Do not build this as a fake static marketing screen.
Build it as a real feature-ready AI system entry point.

1. Feature purpose

Magna AI should act like:

technical assistant

coding/debugging helper

architecture assistant

builder/project assistant

job/opportunity helper

collaboration assistant

The AI screen must feel like a real product feature inside Magna, not a random chatbot page.

2. Core feature structure

Build this feature under:

lib/features/magna_ai/

Use this structure:

lib/features/magna_ai/
  data/
    dto/
      ai_conversation_dto.dart
      ai_message_dto.dart
    models/
      ai_conversation_model.dart
      ai_message_model.dart
      ai_quick_action_model.dart
    services/
      magna_ai_api_service.dart
      magna_ai_socket_service.dart
    repositories/
      magna_ai_repository_impl.dart

  domain/
    entities/
      ai_conversation_entity.dart
      ai_message_entity.dart
    repositories/
      magna_ai_repository.dart

  ui/
    controllers/
      magna_ai_controller.dart
    pages/
      magna_ai_page.dart
    widgets/
      magna_ai_header.dart
      magna_ai_greeting.dart
      magna_ai_quick_actions.dart
      magna_ai_quick_action_card.dart
      magna_ai_input_bar.dart
      magna_ai_conversation_panel.dart
      magna_ai_conversation_list_item.dart
      magna_ai_chat_area.dart
      magna_ai_message_bubble.dart
      magna_ai_empty_state.dart
      magna_ai_typing_indicator.dart

If helper files are needed, create them cleanly.

3. Screen structure

Build the MagnaAiPage as a two-mode AI interface:

Mode A — AI Home / command center

Used when no conversation is selected yet.

Contains:

header

greeting / AI intro

quick action cards

input bar

conversation history panel

Mode B — Active AI conversation

Used when a conversation is selected or created.

Contains:

header

conversation panel/history

active chat messages

input bar

quick actions can be minimized or hidden in active chat mode

The page must support switching between:

home state

active conversation state

4. Required layout

The layout should conceptually look like this:

MagnaAiPage
├── MagnaAiHeader
├── Body
│   ├── MagnaAiConversationPanel
│   └── MainAiContent
│       ├── MagnaAiGreeting / QuickActions (home mode)
│       └── MagnaAiChatArea (active conversation mode)
└── MagnaAiInputBar

On mobile:

conversation panel can be collapsible, drawer-style, or top sheet style

active conversation should still be easy to access

On tablet/desktop:

conversation panel can sit on the left side permanently

The architecture must be adaptive.

5. Conversation panel requirement

This is mandatory.

Build a MagnaAiConversationPanel that stores and displays AI chat history.

It must support:

showing a list of previous AI conversations

active conversation highlight

tapping a conversation to load it

creating a new conversation

showing title + last updated time

handling empty state if no chats exist

Each conversation list item should display:

title

short preview if available

updated timestamp

selected/active state

The panel must feel like a real AI conversation sidebar/history list.

6. AI conversation data model

Build models/entities for:

AIConversation

Fields should support:

id

title

createdAt

updatedAt

lastMessagePreview

messageCount

isPinned if useful later

AIMessage

Fields should support:

id

conversationId

role (user, assistant, system)

content

createdAt

status

attachments if applicable

Use clean enums where useful.

7. Backend/API alignment

Use the backend AI chat structure if available.

The old schema already suggests:

ai_conversations

ai_messages

So the feature should align with a conversation-based AI history model.

Support or scaffold endpoints like:

GET /api/ai/conversations
POST /api/ai/conversations
GET /api/ai/conversations/:conversationId/messages
POST /api/ai/conversations/:conversationId/messages
POST /api/ai/chat

If your existing backend contract is slightly different, map cleanly.

Update core/network/endpoints.dart with proper helpers and do not hardcode URLs inside widgets.

8. WebSocket / realtime requirement

If Magna AI is already designed to support streaming or realtime updates, structure for it cleanly.

Use websocket_client.dart or a dedicated AI socket service if appropriate.

Support events like:

ai.message.chunk

ai.message.completed

ai.conversation.updated

If streaming is not fully implemented yet, scaffold the architecture cleanly so the UI can support:

typing indicator

partial streaming response

final assistant message completion

Do not tightly couple socket logic to widgets.

9. Header requirements

Create MagnaAiHeader.

It should include:

panel/drawer button if app shell uses one

title or AI identity cue

notifications shortcut if appropriate

conversation panel toggle on mobile

The header must feel integrated into Magna, not generic chatbot UI.

10. Greeting / AI intro block

Create MagnaAiGreeting.

When no conversation is selected, show a greeting block like:

Hi Ashwa if profile is available

fallback greeting if profile fails

a concise statement of what Magna AI helps with

But rewrite the copy so it feels Magna-specific, not generic chatbot fluff.

It should communicate things like:

solve technical problems

design systems

debug code

find collaborators

discover opportunities

turn ideas into software

Make it product-specific and credible.

11. Quick actions requirement

Create a quick actions section using cards, not giant generic buttons.

Required quick actions:

Job Opportunities

Search Builders & Collabs

Debug Code

Optional later-ready quick actions:

Design System Help

Architecture Review

Project Planning

Each quick action card should:

have icon

title

short description

tap action

These are AI intents, not just links.

Tapping a quick action should either:

create/open a conversation with a seeded prompt
or

navigate into a focused AI workflow

For now, the simplest correct implementation is:

create/select an AI conversation

prefill or send a starter prompt related to the quick action

Example:

Debug Code seeds prompt: "Help me debug a code issue."

12. Chat area requirements

Create MagnaAiChatArea.

This is the active conversation view.

It must include:

message list

user message bubbles

assistant message bubbles

typing / streaming indicator

empty conversation state if selected conversation has no messages yet

The message list must be scrollable and production-readable.

Bubble structure should support:

role-based alignment

timestamp if useful

future attachment rendering

13. Input bar requirements

Create MagnaAiInputBar.

It must support:

text input

add/plus button

image attachment button

microphone button

send button

Behavior:

send button disabled if no text and no attachment

support multiline text input for prompts

support image attach scaffolding

support voice input scaffolding

preserve clean layout and touch targets

The input bar should feel like the primary interaction area, not a detached floating toy.

14. Mobile behavior

On mobile, the conversation panel must not make the UI cramped.

Use one of these approaches:

collapsible side drawer

modal panel

slide-over conversation history panel

The user must still easily:

open history

switch conversations

start new chat

On larger screens, show the conversation panel side-by-side with the main content.

15. New conversation flow

Add a clear New Chat / New Conversation action.

When tapped:

create a new AI conversation

clear active message input

switch UI into a fresh conversation state

If the backend does not yet create conversations explicitly before first message, handle it gracefully:

create a temporary local conversation state

create actual conversation on first message send

then replace temp state with real conversation id

Structure the code clearly.

16. Conversation title logic

Conversation titles should be auto-derived if backend does not provide one yet.

Possible rules:

use first user prompt shortened

or use backend-provided title

fallback to New Conversation

Keep titles readable in the panel.

17. Loading and empty states

Support these states cleanly:

Conversation panel empty state

No previous AI conversations yet

Home state

greeting + quick actions visible

Active conversation empty state

Start chatting with Magna AI

Loading messages

skeletons or simple loading indicator

AI response pending

typing indicator / streaming placeholder

Do not leave blank dead zones.

18. Navigation and routing

The Magna AI page should integrate with existing Magna routing cleanly.

If the app uses a panel drawer to reach Magna AI, preserve that.

Do not make Magna AI a conflicting second navigation system.

The page can be a feature page accessed from panel navigation, while bottom tabs remain:

Feed

Search Builders

Chats

Profile

19. UI design direction

The screen should feel:

modern

premium

technical

clean

dark-theme compatible

clearly part of Magna

Avoid:

generic chatbot landing pages

giant marketing paragraphs

oversized bright CTA pills

flat dead whitespace

clumsy floating input bars

Use:

better hierarchy

action cards

conversation panel structure

stronger AI identity

elegant surfaces

readable spacing

adaptive layout

This should look like a serious AI workspace inside Magna.

20. Controller/state requirements

Create MagnaAiController to manage:

conversation list

active conversation

loading conversation history

loading active messages

creating new conversation

selecting conversation

sending message

receiving AI response

typing/streaming state

quick action seeding

panel open/close state on mobile

Suggested methods:

initialize()

loadConversations()

selectConversation(String id)

createNewConversation()

loadMessages(String conversationId)

sendMessage(String text, {attachments})

handleQuickAction(AiQuickAction action)

toggleConversationPanel()

Keep the logic out of widget trees.

21. Deliverables

Return:

all created/updated Magna AI files

conversation panel/history implementation

active chat area implementation

quick actions implementation

input bar implementation

controller/state management

backend/API alignment

websocket/streaming scaffolding if relevant

explanation of architecture and adaptive layout choices

Also confirm:

conversation panel exists

previous chats are visible

user can switch between chats

new conversation works

active conversation renders messages

quick actions work

input bar works

Magna AI page adapts for mobile and larger layouts

22. Final build target

The final result should be a full Magna AI page that acts as:

an AI command center

an AI chat interface

a history-aware conversation workspace

with a conversation panel that stores chat history and lets users continue previous AI chats cleanly.

This must feel like a serious product feature, not a static AI promo page