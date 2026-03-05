import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const aiRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// POST /api/ai/chat - Proxy chat request to AI service
aiRoutes.post('/chat', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const { message, session_id } = await c.req.json();

  if (!message) return c.json({ error: 'Message is required' }, 400);

  try {
    // 1. Log interaction in D1
    const interactionId = crypto.randomUUID();
    await c.env.DB.prepare(`
      INSERT INTO ai_interactions (id, user_id, session_id, query_summary)
      VALUES (?, ?, ?, ?)
    `).bind(interactionId, userId, session_id || 'default', message.substring(0, 100)).run();

    // 2. Proxy to real AI service (e.g., Python backend or Cloudflare AI)
    // For now, we'll return a mock response or forward if MAGNA_AI_BASE is set
    if (c.env.MAGNA_AI_BASE) {
      const response = await fetch(`${c.env.MAGNA_AI_BASE}/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message, userId, session_id })
      });
      return response;
    }

    return c.json({ 
      response: "I'm Magna AI. I'm currently in development mode. How can I help you today?",
      interactionId: interactionId 
    });

  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/ai/query - Single-turn AI query (no session)
aiRoutes.post('/query', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const { prompt } = await c.req.json();

  if (!prompt) return c.json({ error: 'Prompt is required' }, 400);

  try {
    // 1. Log query
    const interactionId = crypto.randomUUID();
    await c.env.DB.prepare(`
      INSERT INTO ai_interactions (id, user_id, session_id, query_summary)
      VALUES (?, ?, ?, ?)
    `).bind(interactionId, userId, 'query', prompt.substring(0, 100)).run();

    // 2. Mock response or forward
    if (c.env.MAGNA_AI_BASE) {
      const response = await fetch(`${c.env.MAGNA_AI_BASE}/query`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt, userId })
      });
      return response;
    }

    return c.json({ 
      result: `Processed query: "${prompt}". This is a mock AI response.`,
      interactionId: interactionId 
    });

  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/ai/history - Get user's AI interaction history
aiRoutes.get('/history', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const history = await c.env.DB.prepare(`
      SELECT * FROM ai_interactions 
      WHERE user_id = ? 
      ORDER BY created_at DESC 
      LIMIT 20
    `).bind(userId).all();
    return c.json({ history: history.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
