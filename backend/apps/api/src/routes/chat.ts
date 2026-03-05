import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const chatRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/chat/conversations - List active conversations
chatRoutes.get('/conversations', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const conversations = await c.env.DB.prepare(`
      SELECT c.*, cm.joined_at, (
        SELECT content FROM messages m WHERE m.conversation_id = c.id ORDER BY created_at DESC LIMIT 1
      ) as last_message, (
        SELECT created_at FROM messages m WHERE m.conversation_id = c.id ORDER BY created_at DESC LIMIT 1
      ) as last_message_at
      FROM conversations c
      JOIN conversation_members cm ON c.id = cm.conversation_id
      WHERE cm.user_id = ?
      ORDER BY last_message_at DESC
    `).bind(userId).all();
    return c.json({ conversations: conversations.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/chat/messages/:id - Get conversation history
chatRoutes.get('/messages/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const conversationId = c.req.param('id');
  
  try {
    // Check membership
    const isMember = await c.env.DB.prepare(
      'SELECT id FROM conversation_members WHERE conversation_id = ? AND user_id = ?'
    ).bind(conversationId, userId).first();

    if (!isMember) return c.json({ error: 'Unauthorized' }, 403);

    const messages = await c.env.DB.prepare(`
      SELECT m.*, u.username as sender_name, u.avatar_url as sender_avatar
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = ?
      ORDER BY m.created_at DESC
      LIMIT 100
    `).bind(conversationId).all();

    return c.json({ messages: messages.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/chat/messages - Send a message
chatRoutes.post('/messages', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const { conversation_id, content } = await c.req.json();

  if (!conversation_id || !content) {
    return c.json({ error: 'Missing required fields' }, 400);
  }

  try {
    // Check membership
    const isMember = await c.env.DB.prepare(
      'SELECT id FROM conversation_members WHERE conversation_id = ? AND user_id = ?'
    ).bind(conversation_id, userId).first();

    if (!isMember) return c.json({ error: 'Unauthorized' }, 403);

    const id = crypto.randomUUID();
    await c.env.DB.prepare(
      'INSERT INTO messages (id, conversation_id, sender_id, content) VALUES (?, ?, ?, ?)'
    ).bind(id, conversation_id, userId, content).run();

    return c.json({ message: 'Message sent', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/chat/conversations - Create a new conversation (DM or Group)
chatRoutes.post('/conversations', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  const { name, is_group, participants } = body; // participants: array of user IDs

  try {
    const id = crypto.randomUUID();
    const batch = [
      c.env.DB.prepare('INSERT INTO conversations (id, name, is_group) VALUES (?, ?, ?)').bind(id, name || null, is_group ? 1 : 0),
      c.env.DB.prepare('INSERT INTO conversation_members (id, conversation_id, user_id) VALUES (?, ?, ?)').bind(crypto.randomUUID(), id, userId)
    ];

    if (participants && Array.isArray(participants)) {
      participants.forEach(pId => {
        batch.push(
          c.env.DB.prepare('INSERT INTO conversation_members (id, conversation_id, user_id) VALUES (?, ?, ?)').bind(crypto.randomUUID(), id, pId)
        );
      });
    }

    await c.env.DB.batch(batch);

    return c.json({ message: 'Conversation created', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
