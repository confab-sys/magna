import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const aiRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/ai/conversations - List conversations
aiRoutes.get('/conversations', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const result = await c.env.DB.prepare(`
      SELECT c.*, 
        (SELECT content FROM ai_messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1) as last_message,
        (SELECT created_at FROM ai_messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1) as last_message_at
      FROM ai_conversations c
      WHERE c.user_id = ?
      ORDER BY last_message_at DESC
    `).bind(userId).all();
    return c.json({ conversations: result.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/ai/conversations - Create new conversation
aiRoutes.post('/conversations', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const { title } = await c.req.json().catch(() => ({ title: null }));
  
  const id = crypto.randomUUID();
  const conversationTitle = title || 'New Chat';
  
  try {
    await c.env.DB.prepare(`
      INSERT INTO ai_conversations (id, user_id, title) VALUES (?, ?, ?)
    `).bind(id, userId, conversationTitle).run();
    
    return c.json({ 
      conversation: { id, user_id: userId, title: conversationTitle, created_at: new Date().toISOString() } 
    }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/ai/conversations/:id/messages - Get messages
aiRoutes.get('/conversations/:id/messages', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const conversationId = c.req.param('id');
  
  try {
    // Verify ownership
    const conv = await c.env.DB.prepare('SELECT id FROM ai_conversations WHERE id = ? AND user_id = ?')
      .bind(conversationId, userId).first();
      
    if (!conv) return c.json({ error: 'Conversation not found' }, 404);
    
    const messages = await c.env.DB.prepare(`
      SELECT * FROM ai_messages WHERE conversation_id = ? ORDER BY created_at ASC
    `).bind(conversationId).all();
    
    return c.json({ messages: messages.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/ai/conversations/:id/messages - Send message & get response
aiRoutes.post('/conversations/:id/messages', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const conversationId = c.req.param('id');
  const { content } = await c.req.json();
  
  if (!content) return c.json({ error: 'Content required' }, 400);
  
  try {
    // Verify ownership
    const conv = await c.env.DB.prepare('SELECT id FROM ai_conversations WHERE id = ? AND user_id = ?')
      .bind(conversationId, userId).first();
      
    if (!conv) return c.json({ error: 'Conversation not found' }, 404);
    
    // 1. Save User Message
    const userMsgId = crypto.randomUUID();
    await c.env.DB.prepare(`
      INSERT INTO ai_messages (id, conversation_id, role, content) VALUES (?, ?, 'user', ?)
    `).bind(userMsgId, conversationId, content).run();
    
    // 2. Generate AI Response (Mock or Proxy)
    let aiContent = "I'm Magna AI. I can help you with coding, architecture, and debugging.";
    
    // Simple mock logic for demo purposes
    if (content.toLowerCase().includes('debug')) {
        aiContent = "I can help you debug that. Please paste the error logs or the code snippet you're having trouble with.";
    } else if (content.toLowerCase().includes('job')) {
        aiContent = "I can help you find job opportunities. Have you checked the Jobs tab? I can also help optimize your profile.";
    }
    
    // If MAGNA_AI_BASE is set, we could proxy real LLM here
    if (c.env.MAGNA_AI_BASE) {
       try {
           const aiRes = await fetch(`${c.env.MAGNA_AI_BASE}/chat`, {
               method: 'POST',
               headers: { 'Content-Type': 'application/json' },
               body: JSON.stringify({ message: content, userId, session_id: conversationId })
           });
           if (aiRes.ok) {
               const data: any = await aiRes.json();
               if (data.response) aiContent = data.response;
           }
       } catch (err) {
           console.error('AI Service Error:', err);
           aiContent = "I'm having trouble connecting to my brain right now. Please try again later.";
       }
    }
    
    // 3. Save AI Message
    const aiMsgId = crypto.randomUUID();
    await c.env.DB.prepare(`
      INSERT INTO ai_messages (id, conversation_id, role, content) VALUES (?, ?, 'assistant', ?)
    `).bind(aiMsgId, conversationId, aiContent).run();
    
    // 4. Update conversation title if it's the first message and title is generic
    // (Optional logic, skipped for simplicity)
    
    return c.json({ 
      userMessage: { id: userMsgId, role: 'user', content, created_at: new Date().toISOString() },
      aiMessage: { id: aiMsgId, role: 'assistant', content: aiContent, created_at: new Date().toISOString() }
    });
    
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

