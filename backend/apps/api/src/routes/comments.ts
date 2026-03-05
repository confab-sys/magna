import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const commentRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/comments - List recent comments (admin/global view)
commentRoutes.get('/', authMiddleware, async (c) => {
  try {
    const comments = await c.env.DB.prepare(`
      SELECT c.*, u.username as author_name, u.avatar_url as author_avatar
      FROM comments c
      JOIN users u ON c.author_id = u.id
      ORDER BY c.created_at DESC
      LIMIT 50
    `).all();
    return c.json({ comments: comments.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/comments/my - List my comments
commentRoutes.get('/my', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const comments = await c.env.DB.prepare(`
      SELECT c.*, p.title as post_title
      FROM comments c
      JOIN posts p ON c.post_id = p.id
      WHERE c.author_id = ?
      ORDER BY c.created_at DESC
    `).bind(userId).all();
    return c.json({ comments: comments.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
