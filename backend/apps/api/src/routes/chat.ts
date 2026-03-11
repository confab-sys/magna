import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const chatRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/chat/conversations - List active conversations (v2: conversation-centric)
chatRoutes.get('/conversations', authMiddleware, async (c) => {
  const userId = c.get('userId');

  // Optional flags to align with frontend API
  const includeArchived = c.req.query('includeArchived') === 'true';

  try {
    const conversations = await c.env.DB.prepare(
      `
      SELECT
        c.*,
        cm.joined_at,
        cm.is_pinned,
        cm.is_archived AS member_is_archived,
        cm.notification_preference,
        -- Compute unread count per member based on last_read_at
        (
          SELECT COUNT(*)
          FROM messages m
          WHERE m.conversation_id = c.id
            AND m.created_at > COALESCE(cm.last_read_at, '1970-01-01')
        ) AS unread_count
      FROM conversations c
      JOIN conversation_members cm ON c.id = cm.conversation_id
      WHERE cm.user_id = ?
        AND (? = 1 OR cm.is_archived = 0)
      ORDER BY c.last_message_at DESC NULLS LAST, c.updated_at DESC
    `,
    )
      .bind(userId, includeArchived ? 1 : 0)
      .all();

    // Keep shape `{ conversations: [...] }` for frontend DTO mapping
    return c.json({ conversations: conversations.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/chat/public-groups - Discover public group conversations the user can join
chatRoutes.get('/public-groups', authMiddleware, async (c) => {
  const userId = c.get('userId');

  try {
    const result = await c.env.DB.prepare(
      `
      SELECT
        c.id,
        c.name,
        c.description,
        c.avatar_url,
        c.conversation_type,
        c.is_group,
        c.created_by,
        c.created_at,
        c.updated_at,
        c.last_message_id,
        c.last_message_preview,
        c.last_message_at,
        c.last_sender_id,
        c.is_archived,
        c.is_locked,
        c.is_public,
        (
          SELECT COUNT(*)
          FROM conversation_members cm
          WHERE cm.conversation_id = c.id
        ) AS member_count,
        EXISTS (
          SELECT 1
          FROM conversation_members cm2
          WHERE cm2.conversation_id = c.id
            AND cm2.user_id = ?
        ) AS is_member
      FROM conversations c
      WHERE c.conversation_type = 'group'
        AND c.is_public = 1
      ORDER BY c.last_message_at DESC NULLS LAST, c.updated_at DESC
    `,
    )
      .bind(userId)
      .all();

    return c.json({ success: true, data: result.results });
  } catch (e: any) {
    return c.json(
      {
        success: false,
        error: { message: e.message ?? 'Failed to load public groups' },
      },
      500,
    );
  }
});

// GET /api/chat/conversations/:id - Get a single conversation with members (v2)
chatRoutes.get('/conversations/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const conversationId = c.req.param('id');

  try {
    const conversation = await c.env.DB.prepare(
      `
      SELECT
        c.*,
        cm.joined_at,
        cm.role,
        cm.last_read_message_id,
        cm.last_read_at,
        cm.is_pinned,
        cm.is_archived AS member_is_archived,
        cm.notification_preference,
        (
          SELECT COUNT(*)
          FROM messages m
          WHERE m.conversation_id = c.id
            AND m.created_at > COALESCE(cm.last_read_at, '1970-01-01')
        ) AS unread_count
      FROM conversations c
      JOIN conversation_members cm
        ON c.id = cm.conversation_id
      WHERE c.id = ? AND cm.user_id = ?
    `,
    )
      .bind(conversationId, userId)
      .first();

    if (!conversation) {
      return c.json(
        { success: false, error: { message: 'Conversation not found' } },
        404,
      );
    }

    const members = await c.env.DB.prepare(
      `
      SELECT
        user_id AS userId,
        role,
        joined_at AS joinedAt,
        last_read_message_id AS lastReadMessageId,
        last_read_at AS lastReadAt
      FROM conversation_members
      WHERE conversation_id = ?
    `,
    )
      .bind(conversationId)
      .all();

    // Attach members in camelCase to align with MemberDto
    const data = {
      ...(conversation as any),
      members: members.results,
    };

    return c.json({ success: true, data });
  } catch (e: any) {
    return c.json(
      {
        success: false,
        error: { message: e.message ?? 'Failed to load conversation' },
      },
      500,
    );
  }
});

// GET /api/chat/messages/:id - Get conversation history (legacy endpoint)
chatRoutes.get('/messages/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const conversationId = c.req.param('id');

  try {
    // Check membership
    const isMember = await c.env.DB.prepare(
      'SELECT id FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
    )
      .bind(conversationId, userId)
      .first();

    if (!isMember) return c.json({ error: 'Unauthorized' }, 403);

    const messages = await c.env.DB.prepare(
      `
      SELECT m.*, u.username as sender_name, u.avatar_url as sender_avatar
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = ?
      ORDER BY m.created_at DESC
      LIMIT 100
    `,
    )
      .bind(conversationId)
      .all();

    return c.json({ messages: messages.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/chat/conversations/:id/messages - Get messages for a conversation (v2)
chatRoutes.get('/conversations/:id/messages', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const conversationId = c.req.param('id');

  // Optional pagination params (currently not implemented as cursor-based)
  const limitParam = c.req.query('limit');
  const limit =
    limitParam && !Number.isNaN(Number(limitParam))
      ? Math.min(Number(limitParam), 100)
      : 100;

  try {
    // Check membership
    const isMember = await c.env.DB.prepare(
      'SELECT id FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
    )
      .bind(conversationId, userId)
      .first();

    if (!isMember) {
      return c.json(
        { success: false, error: { message: 'Unauthorized' } },
        403,
      );
    }

    const messages = await c.env.DB.prepare(
      `
      SELECT 
        m.*,
        u.username as sender_name,
        u.avatar_url as sender_avatar
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = ?
      ORDER BY m.created_at DESC
      LIMIT ?
    `,
    )
      .bind(conversationId, limit)
      .all();

    const rows = messages.results as any[];

    const data = rows.map((m) => ({
      id: m.id,
      conversationId: m.conversation_id,
      senderId: m.sender_id,
      content: m.content,
      messageType: m.message_type ?? 'text',
      status: m.status ?? 'sent',
      replyToMessageId: m.reply_to_message_id,
      editedAt: m.edited_at,
      deletedAt: m.deleted_at,
      deliveredAt: m.delivered_at,
      readAt: m.read_at,
      metadata: m.metadata_json ? JSON.parse(m.metadata_json) : null,
      attachments: [] as any[],
      createdAt: m.created_at,
      sender: {
        id: m.sender_id,
        username: m.sender_name,
        avatarUrl: m.sender_avatar,
      },
    }));

    return c.json({ success: true, data });
  } catch (e: any) {
    return c.json(
      {
        success: false,
        error: { message: e.message ?? 'Failed to load messages' },
      },
      500,
    );
  }
});

// POST /api/chat/messages - Send a message (legacy endpoint)
chatRoutes.post('/messages', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const { conversation_id, content } = await c.req.json();

  if (!conversation_id || !content) {
    return c.json({ error: 'Missing required fields' }, 400);
  }

  try {
    // Check membership
    const isMember = await c.env.DB.prepare(
      'SELECT id FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
    )
      .bind(conversation_id, userId)
      .first();

    if (!isMember) return c.json({ error: 'Unauthorized' }, 403);

    const id = crypto.randomUUID();
    await c.env.DB.prepare(
      'INSERT INTO messages (id, conversation_id, sender_id, content) VALUES (?, ?, ?, ?)',
    )
      .bind(id, conversation_id, userId, content)
      .run();

    return c.json({ message: 'Message sent', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/chat/conversations/:id/messages - Send a message (v2)
chatRoutes.post('/conversations/:id/messages', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const conversationId = c.req.param('id');

  let body: any;
  try {
    body = await c.req.json();
  } catch {
    return c.json(
      { success: false, error: { message: 'Invalid JSON body' } },
      400,
    );
  }

  const {
    content,
    messageType = 'text',
    replyToMessageId,
    attachments,
  } = body;

  if (!content || typeof content !== 'string') {
    return c.json(
      { success: false, error: { message: 'content is required' } },
      400,
    );
  }

  try {
    // Check membership
    const isMember = await c.env.DB.prepare(
      'SELECT id FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
    )
      .bind(conversationId, userId)
      .first();

    if (!isMember) {
      return c.json(
        { success: false, error: { message: 'Unauthorized' } },
        403,
      );
    }

    const id = crypto.randomUUID();
    const metadataJson =
      attachments && Array.isArray(attachments) && attachments.length > 0
        ? JSON.stringify({ attachments })
        : null;

    await c.env.DB.prepare(
      `
      INSERT INTO messages (
        id,
        content,
        sender_id,
        conversation_id,
        message_type,
        reply_to_message_id,
        status,
        metadata_json
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `,
    )
      .bind(
        id,
        content,
        userId,
        conversationId,
        messageType,
        replyToMessageId || null,
        'sent',
        metadataJson,
      )
      .run();

    // Update conversation summary fields for inbox
    await c.env.DB.prepare(
      `
      UPDATE conversations
      SET 
        last_message_id = ?,
        last_message_preview = ?,
        last_message_at = CURRENT_TIMESTAMP,
        last_sender_id = ?,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `,
    )
      .bind(id, content, userId, conversationId)
      .run();

    // Fetch the created message in API shape
    const messageResult = await c.env.DB.prepare(
      `
      SELECT 
        m.*,
        u.username as sender_name,
        u.avatar_url as sender_avatar
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.id = ?
    `,
    )
      .bind(id)
      .first();

    if (!messageResult) {
      return c.json(
        {
          success: false,
          error: { message: 'Message created but not found' },
        },
        500,
      );
    }

    const m = messageResult as any;
    const data = {
      id: m.id,
      conversationId: m.conversation_id,
      senderId: m.sender_id,
      content: m.content,
      messageType: m.message_type ?? 'text',
      status: m.status ?? 'sent',
      replyToMessageId: m.reply_to_message_id,
      editedAt: m.edited_at,
      deletedAt: m.deleted_at,
      deliveredAt: m.delivered_at,
      readAt: m.read_at,
      metadata: m.metadata_json ? JSON.parse(m.metadata_json) : null,
      attachments: [] as any[],
      createdAt: m.created_at,
      sender: {
        id: m.sender_id,
        username: m.sender_name,
        avatarUrl: m.sender_avatar,
      },
    };

    return c.json({ success: true, data }, 201);
  } catch (e: any) {
    return c.json(
      {
        success: false,
        error: { message: e.message ?? 'Failed to send message' },
      },
      500,
    );
  }
});

// POST /api/chat/conversations - Create a new conversation (DM or Group)
// Supports both legacy and v2 payloads
chatRoutes.post('/conversations', authMiddleware, async (c) => {
  const userId = c.get('userId');

  let body: any;
  try {
    body = await c.req.json();
  } catch {
    return c.json({ error: 'Invalid JSON body' }, 400);
  }

  // v2 payload: { conversationType, name, description, memberUserIds }
  if (body.conversationType || body.memberUserIds) {
    const {
      conversationType = 'direct',
      name,
      description,
      memberUserIds,
    } = body;

    if (!Array.isArray(memberUserIds) || memberUserIds.length === 0) {
      return c.json(
        {
          success: false,
          error: { message: 'memberUserIds must be a non-empty array' },
        },
        400,
      );
    }

    try {
      const id = crypto.randomUUID();

      const isGroup = conversationType === 'group' ? 1 : 0;

      await c.env.DB.prepare(
        `
        INSERT INTO conversations (
          id,
          name,
          is_group,
          description,
          avatar_url,
          created_by,
          conversation_type
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `,
      )
        .bind(id, name || null, isGroup, description || null, null, userId, conversationType)
        .run();

      const memberIds = new Set<string>([
        userId,
        ...memberUserIds.map((m: any) => String(m)),
      ]);

      const batch = [];

      for (const memberId of memberIds) {
        batch.push(
          c.env.DB.prepare(
            `
            INSERT INTO conversation_members (
              id,
              conversation_id,
              user_id,
              role
            )
            VALUES (?, ?, ?, ?)
          `,
          ).bind(
            crypto.randomUUID(),
            id,
            memberId,
            memberId === userId ? 'OWNER' : 'MEMBER',
          ),
        );
      }

      await c.env.DB.batch(batch);

      // Load conversation in the same shape as GET /conversations/:id
      const conversation = await c.env.DB.prepare(
        `
        SELECT
          c.*,
          cm.joined_at,
          cm.role,
          cm.last_read_message_id,
          cm.last_read_at,
          cm.is_pinned,
          cm.is_archived AS member_is_archived,
          cm.notification_preference,
          0 AS unread_count
        FROM conversations c
        JOIN conversation_members cm
          ON c.id = cm.conversation_id
        WHERE c.id = ? AND cm.user_id = ?
      `,
      )
        .bind(id, userId)
        .first();

      const members = await c.env.DB.prepare(
        `
        SELECT
          user_id AS userId,
          role,
          joined_at AS joinedAt,
          last_read_message_id AS lastReadMessageId,
          last_read_at AS lastReadAt
        FROM conversation_members
        WHERE conversation_id = ?
      `,
      )
        .bind(id)
        .all();

      const data = {
        ...(conversation as any),
        members: members.results,
      };

      return c.json({ success: true, data }, 201);
    } catch (e: any) {
      return c.json(
        {
          success: false,
          error: { message: e.message ?? 'Failed to create conversation' },
        },
        500,
      );
    }
  }

  // Legacy payload: { name, is_group, participants }
  const { name, is_group, participants } = body; // participants: array of user IDs

  try {
    const id = crypto.randomUUID();
    const batch = [
      c.env.DB.prepare(
        'INSERT INTO conversations (id, name, is_group) VALUES (?, ?, ?)',
      ).bind(id, name || null, is_group ? 1 : 0),
      c.env.DB.prepare(
        'INSERT INTO conversation_members (id, conversation_id, user_id) VALUES (?, ?, ?)',
      ).bind(crypto.randomUUID(), id, userId),
    ];

    if (participants && Array.isArray(participants)) {
      participants.forEach((pId: string) => {
        batch.push(
          c.env.DB.prepare(
            'INSERT INTO conversation_members (id, conversation_id, user_id) VALUES (?, ?, ?)',
          ).bind(crypto.randomUUID(), id, pId),
        );
      });
    }

    await c.env.DB.batch(batch);

    return c.json({ message: 'Conversation created', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/chat/public-groups/:id/join - Join a public group conversation
chatRoutes.post('/public-groups/:id/join', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const conversationId = c.req.param('id');

  try {
    const conversation = await c.env.DB.prepare(
      `
      SELECT *
      FROM conversations
      WHERE id = ?
        AND conversation_type = 'group'
        AND is_public = 1
    `,
    )
      .bind(conversationId)
      .first();

    if (!conversation) {
      return c.json(
        {
          success: false,
          error: { message: 'Public group not found' },
        },
        404,
      );
    }

    const existingMember = await c.env.DB.prepare(
      `
      SELECT id
      FROM conversation_members
      WHERE conversation_id = ?
        AND user_id = ?
    `,
    )
      .bind(conversationId, userId)
      .first();

    if (!existingMember) {
      await c.env.DB.prepare(
        `
        INSERT INTO conversation_members (
          id,
          conversation_id,
          user_id,
          role
        )
        VALUES (?, ?, ?, ?)
      `,
      )
        .bind(crypto.randomUUID(), conversationId, userId, 'MEMBER')
        .run();
    }

    const convoWithMember = await c.env.DB.prepare(
      `
      SELECT
        c.*,
        cm.joined_at,
        cm.role,
        cm.last_read_message_id,
        cm.last_read_at,
        cm.is_pinned,
        cm.is_archived AS member_is_archived,
        cm.notification_preference,
        (
          SELECT COUNT(*)
          FROM messages m
          WHERE m.conversation_id = c.id
            AND m.created_at > COALESCE(cm.last_read_at, '1970-01-01')
        ) AS unread_count
      FROM conversations c
      JOIN conversation_members cm
        ON c.id = cm.conversation_id
      WHERE c.id = ? AND cm.user_id = ?
    `,
    )
      .bind(conversationId, userId)
      .first();

    if (!convoWithMember) {
      return c.json(
        {
          success: false,
          error: { message: 'Joined group but failed to load conversation' },
        },
        500,
      );
    }

    return c.json({ success: true, data: convoWithMember });
  } catch (e: any) {
    return c.json(
      {
        success: false,
        error: { message: e.message ?? 'Failed to join public group' },
      },
      500,
    );
  }
});

// PATCH /api/chat/conversations/:id/read - Mark conversation as read (v2)
chatRoutes.patch('/conversations/:id/read', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const conversationId = c.req.param('id');

  let body: any;
  try {
    body = await c.req.json();
  } catch {
    return c.json(
      { success: false, error: { message: 'Invalid JSON body' } },
      400,
    );
  }

  const { lastReadMessageId } = body;

  if (!lastReadMessageId || typeof lastReadMessageId !== 'string') {
    return c.json(
      {
        success: false,
        error: { message: 'lastReadMessageId is required' },
      },
      400,
    );
  }

  try {
    // Ensure membership row exists
    const member = await c.env.DB.prepare(
      `
      SELECT id FROM conversation_members
      WHERE conversation_id = ? AND user_id = ?
    `,
    )
      .bind(conversationId, userId)
      .first();

    if (!member) {
      return c.json(
        { success: false, error: { message: 'Unauthorized' } },
        403,
      );
    }

    await c.env.DB.prepare(
      `
      UPDATE conversation_members
      SET 
        last_read_message_id = ?,
        last_read_at = CURRENT_TIMESTAMP
      WHERE conversation_id = ? AND user_id = ?
    `,
    )
      .bind(lastReadMessageId, conversationId, userId)
      .run();

    return c.json({ success: true });
  } catch (e: any) {
    return c.json(
      {
        success: false,
        error: { message: e.message ?? 'Failed to mark as read' },
      },
      500,
    );
  }
});

// PATCH /api/chat/conversations/:id/preferences - Update per-user preferences (v2)
chatRoutes.patch(
  '/conversations/:id/preferences',
  authMiddleware,
  async (c) => {
    const userId = c.get('userId');
    const conversationId = c.req.param('id');

    let body: any;
    try {
      body = await c.req.json();
    } catch {
      return c.json(
        { success: false, error: { message: 'Invalid JSON body' } },
        400,
      );
    }

    const { isPinned, isArchived, notificationPreference } = body;

    const updates: string[] = [];
    const params: any[] = [];

    if (typeof isPinned === 'boolean') {
      updates.push('is_pinned = ?');
      params.push(isPinned ? 1 : 0);
    }

    if (typeof isArchived === 'boolean') {
      updates.push('is_archived = ?');
      params.push(isArchived ? 1 : 0);
    }

    if (
      typeof notificationPreference === 'string' &&
      notificationPreference.length > 0
    ) {
      updates.push('notification_preference = ?');
      params.push(notificationPreference);
    }

    if (updates.length === 0) {
      return c.json(
        {
          success: false,
          error: { message: 'No updatable fields provided' },
        },
        400,
      );
    }

    params.push(conversationId, userId);

    try {
      await c.env.DB.prepare(
        `
        UPDATE conversation_members
        SET ${updates.join(', ')}
        WHERE conversation_id = ? AND user_id = ?
      `,
      )
        .bind(...params)
        .run();

      return c.json({ success: true });
    } catch (e: any) {
      return c.json(
        {
          success: false,
          error: { message: e.message ?? 'Failed to update preferences' },
        },
        500,
      );
    }
  },
);

// PATCH /api/chat/messages/:id - Edit a message (v2)
chatRoutes.patch('/messages/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const messageId = c.req.param('id');

  let body: any;
  try {
    body = await c.req.json();
  } catch {
    return c.json(
      { success: false, error: { message: 'Invalid JSON body' } },
      400,
    );
  }

  const { content } = body;

  if (!content || typeof content !== 'string') {
    return c.json(
      { success: false, error: { message: 'content is required' } },
      400,
    );
  }

  try {
    // Ensure the user is the sender
    const message = await c.env.DB.prepare(
      'SELECT sender_id FROM messages WHERE id = ?',
    )
      .bind(messageId)
      .first();

    if (!message) {
      return c.json(
        { success: false, error: { message: 'Message not found' } },
        404,
      );
    }

    if ((message as any).sender_id !== userId) {
      return c.json(
        { success: false, error: { message: 'Unauthorized' } },
        403,
      );
    }

    await c.env.DB.prepare(
      `
      UPDATE messages
      SET 
        content = ?,
        edited_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `,
    )
      .bind(content, messageId)
      .run();

    return c.json({ success: true });
  } catch (e: any) {
    return c.json(
      {
        success: false,
        error: { message: e.message ?? 'Failed to edit message' },
      },
      500,
    );
  }
});

// DELETE /api/chat/messages/:id - Soft-delete a message (v2)
chatRoutes.delete('/messages/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const messageId = c.req.param('id');

  try {
    const message = await c.env.DB.prepare(
      `
      SELECT sender_id FROM messages
      WHERE id = ?
    `,
    )
      .bind(messageId)
      .first();

    if (!message) {
      return c.json(
        { success: false, error: { message: 'Message not found' } },
        404,
      );
    }

    if ((message as any).sender_id !== userId) {
      return c.json(
        { success: false, error: { message: 'Unauthorized' } },
        403,
      );
    }

    await c.env.DB.prepare(
      `
      UPDATE messages
      SET 
        deleted_at = CURRENT_TIMESTAMP,
        status = 'deleted'
      WHERE id = ?
    `,
    )
      .bind(messageId)
      .run();

    return c.json({ success: true });
  } catch (e: any) {
    return c.json(
      {
        success: false,
        error: { message: e.message ?? 'Failed to delete message' },
      },
      500,
    );
  }
});
