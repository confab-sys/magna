Your tabs will be:

All
Direct
Groups
Archived
Discover
Unread

Two of them behave differently from the others.

Discover groups is not just a filter; it is an entry point into a discovery page.

Unread is a dynamic filter based on message state.

So the structure becomes slightly smarter.

The top section of the screen should contain three parts: the header, the segmented filters, and the conversation list.

The component structure should look like this.

MessagesPage
│
├── MessagesHeader
│     ├── Title
│     └── HeaderActions
│
├── ConversationFilters
│     └── HorizontalScrollableTabs
│            ├── Tab(All)
│            ├── Tab(Direct)
│            ├── Tab(Groups)
│            ├── Tab(Archived)
│            ├── Tab(Discover)
│            └── Tab(Unread)
│
├── ConversationList
│     └── ConversationCard
│
└── NewConversationButton

Notice something subtle here. Because there are six tabs, they should scroll horizontally, not compress into one row. That prevents cramped layout.

Now let’s define the behavior of each filter so your AI builds it correctly.

All shows every conversation that is not archived.

Direct filters conversations where the backend field conversation_type equals "direct".

Groups filters conversations where conversation_type equals "group".

Archived shows conversations where is_archived == 1.

Unread filters conversations where the unread count is greater than zero.

Discover should not filter the list at all. Instead it navigates to a separate screen called something like DiscoverGroupsPage.

That page will eventually show public groups users can join.

Next, redesign the conversation item structure based on the inspiration screen you sent.

Each row should contain five logical zones.

Avatar on the far left. If the conversation has no image, generate an avatar with the first letter of the conversation name. For groups, you can later support group icons.

The middle section contains two stacked text rows: the conversation title and the message preview.

The right side contains the timestamp and unread badge.

The layout flow becomes:

ConversationCard
│
├── Avatar
│
├── ConversationContent
│     ├── ConversationTitle
│     └── MessagePreview
│
└── ConversationMeta
      ├── Timestamp
      └── UnreadBadge

Spacing matters more than color here. The vertical rhythm should be comfortable so the eye can scan quickly.

The avatar should be around 44–48 pixels. That size is standard in messaging apps because it balances density and recognition.

The title should be slightly stronger than the preview text. The preview text should be muted but still readable.

The timestamp should be smaller and lower contrast.

The unread badge should be compact and aligned to the right edge.

Now let’s talk about the filters visually. Instead of rigid buttons, use pill-shaped tabs with a sliding active indicator.

When the user taps a filter, the active tab receives the highlighted background, and the conversation list updates.

Because you already have the backend JSON returning conversations successfully, the filtering can initially be done client-side.

For example, when the selected filter is "direct", the list simply filters where conversationType == "direct".

This keeps the UI responsive.

One more improvement from the inspiration design: the floating compose button.

Place a circular button at the bottom-right corner.

Its purpose is to start a new conversation. In code it will navigate to CreateConversationPage.

Now I will give you the prompt to rebuild the UI with this structure.

Give this prompt to your AI:

Build a redesigned Messages screen for the Magna Flutter app based on a modern messaging UI structure.

Do not change backend integration or existing conversation data models.

The screen must contain three main sections: header, filter tabs, and conversation list.

Create a MessagesHeader widget that contains the title “Messages” and two icon buttons on the right side for search and menu actions. The header should have comfortable top spacing and a clean minimal layout.

Below the header create a horizontally scrollable filter bar called ConversationFilters. It should contain pill-style tabs for the following filters: All, Direct, Groups, Archived, Discover, and Unread.

The tabs must scroll horizontally because there are six options. The active tab should have a filled pill background while inactive tabs use muted text.

Each tab has the following behavior. All shows every conversation except archived ones. Direct shows conversations where conversation_type equals direct. Groups shows conversations where conversation_type equals group. Archived shows conversations where is_archived equals true. Unread shows conversations where unreadCount is greater than zero. Discover should navigate to a DiscoverGroupsPage instead of filtering.

Below the filters build a ConversationList widget that displays conversations using a ListView.builder.

Each conversation must render using a ConversationCard widget.

ConversationCard layout must contain three zones: avatar on the left, content in the middle, and metadata on the right.

The avatar must support both image avatars and fallback initials generated from the conversation name. The avatar size should be approximately 46 pixels with a circular shape.

The content section must contain the conversation title and the message preview stacked vertically. The title should be slightly stronger than the preview text.

The metadata section must contain the timestamp and unread badge aligned to the right side.

If the conversation has no messages, the preview text should show “No messages yet”.

Add proper vertical spacing between conversation rows so the list feels breathable and modern.

Add a floating compose button at the bottom-right corner that opens the CreateConversationPage.

The screen must support filtering when tabs are selected without breaking existing navigation or API data flow.

Keep the design clean, minimal, and modern with strong spacing, good typography hierarchy, and smooth interaction states.

Do not change backend endpoints or conversation parsing logic.

If you send me your next screenshot after implementing this, I can help you push it from “good UI” into something that feels truly premium.