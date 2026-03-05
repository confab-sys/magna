import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const notificationRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/notifications - List user notifications
notificationRoutes.get('/', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const notifications = await c.env.DB.prepare(`
      SELECT * FROM notifications 
      WHERE user_id = ? 
      ORDER BY created_at DESC 
      LIMIT 50
    `).bind(userId).all();
    return c.json({ notifications: notifications.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// PUT /api/notifications/:id/read - Mark a notification as read
notificationRoutes.put('/:id/read', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const id = c.req.param('id');
  try {
    await c.env.DB.prepare(
      'UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?'
    ).bind(id, userId).run();
    return c.json({ message: 'Notification marked as read' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// PUT /api/notifications/read-all - Mark all as read
notificationRoutes.put('/read-all', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    await c.env.DB.prepare(
      'UPDATE notifications SET is_read = 1 WHERE user_id = ?'
    ).bind(userId).run();
    return c.json({ message: 'All notifications marked as read' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
