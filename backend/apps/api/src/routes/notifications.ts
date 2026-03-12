import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';
import {
  broadcastNotificationRead,
  broadcastUnreadCount,
} from '../services/notifications_realtime';

export const notificationRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/notifications - List user notifications
notificationRoutes.get('/', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const notifications = await c.env.DB.prepare(
      `
      SELECT *
      FROM notifications
      WHERE user_id = ?
      ORDER BY created_at DESC
      LIMIT 50
    `,
    )
      .bind(userId)
      .all();

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
      `
      UPDATE notifications
      SET is_read = 1
      WHERE id = ? AND user_id = ?
    `,
    )
      .bind(id, userId)
      .run();

    const unreadRow = await c.env.DB.prepare(
      `
      SELECT COUNT(*) AS count
      FROM notifications
      WHERE user_id = ? AND is_read = 0
    `,
    )
      .bind(userId)
      .first();

    const unreadCount = (unreadRow as any)?.count ?? 0;

    await broadcastNotificationRead(c.env, userId, id);
    await broadcastUnreadCount(c.env, userId, unreadCount);

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
      `
      UPDATE notifications
      SET is_read = 1
      WHERE user_id = ?
    `,
    )
      .bind(userId)
      .run();

    await broadcastUnreadCount(c.env, userId, 0);

    return c.json({ message: 'All notifications marked as read' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
