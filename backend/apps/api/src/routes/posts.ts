import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware, adminKeyMiddleware } from '../middleware';
import {
  broadcastNotificationCreated,
  broadcastUnreadCount,
} from '../services/notifications_realtime';

export const postRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/posts - List all posts
postRoutes.get('/', async (c) => {
  try {
    const posts = await c.env.DB.prepare(`
      SELECT p.*, u.username as author_name, u.avatar_url as author_avatar,
      (SELECT m.url FROM media m JOIN post_media pm ON pm.media_id = m.id WHERE pm.post_id = p.id LIMIT 1) as image_url
      FROM posts p
      JOIN users u ON p.author_id = u.id
      ORDER BY p.created_at DESC
      LIMIT 20
    `).all();
    return c.json({ posts: posts.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

postRoutes.get('/feed', authMiddleware, async (c) => {
  const userId = c.get('userId');

  try {
    const posts = await c.env.DB.prepare(`
      SELECT 
        p.*, 
        u.username as author_name, 
        u.avatar_url as author_avatar,
        (SELECT m.url FROM media m JOIN post_media pm ON pm.media_id = m.id WHERE pm.post_id = p.id LIMIT 1) as image_url,
        EXISTS (SELECT 1 FROM likes WHERE post_id = p.id AND user_id = ?) as is_liked
      FROM posts p
      JOIN users u ON p.author_id = u.id
      ORDER BY p.created_at DESC
      LIMIT 50
    `).bind(userId).all();

    // Map is_liked to boolean
    const results = posts.results.map((p: any) => ({
      ...p,
      is_liked: p.is_liked === 1
    }));

    return c.json({ posts: results, source: 'db' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/posts/:id - Get a single post
postRoutes.get('/:id', async (c) => {
  const id = c.req.param('id');
  try {
    const post = await c.env.DB.prepare(`
      SELECT p.*, u.username as author_name, u.avatar_url as author_avatar,
      (SELECT COUNT(*) FROM likes WHERE post_id = p.id) as like_count,
      (SELECT COUNT(*) FROM comments WHERE post_id = p.id) as comment_count,
      (SELECT m.url FROM media m JOIN post_media pm ON pm.media_id = m.id WHERE pm.post_id = p.id LIMIT 1) as image_url
      FROM posts p
      JOIN users u ON p.author_id = u.id
      WHERE p.id = ?
    `).bind(id).first();

    if (!post) {
      return c.json({ error: 'Post not found' }, 404);
    }

    return c.json({ post });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

postRoutes.post('/', authMiddleware, async (c) => {
  const userId = c.get('userId');
  
  let body: any;
  const contentType = c.req.header('content-type');
  
  if (contentType?.includes('application/json')) {
    body = await c.req.json();
  } else {
    body = await c.req.parseBody();
  }
  
  const title = body['title'];
  const content = body['content'];
  const post_type = body['post_type'];
  const category_id = body['category_id'];
  let image_url = body['image_url'];

  // Handle multipart file upload for 'image'
  const imageFile = body['image'];
  if (imageFile) {
    if (typeof imageFile !== 'string') {
      try {
        const fileId = crypto.randomUUID();
        const fileName = (imageFile as any).name || 'post-image.jpg';
        const key = `posts/${fileId}-${fileName}`;
        const buffer = await (imageFile as any).arrayBuffer();
        
        // Upload to R2
        await c.env.MEDIA.put(key, buffer);
        
        // Construct public URL
        const origin = new URL(c.req.url).origin;
        image_url = `${origin}/api/files/${key}`;
      } catch (e: any) {
        console.error('Failed to upload post image:', e);
      }
    } else {
      image_url = imageFile;
    }
  }

  if (!title) {
    return c.json({ error: 'Title is required' }, 400);
  }

  try {
    const id = crypto.randomUUID();
    // Ensure D1 compatibility by using null instead of undefined
    const safeContent = content || null;
    const safePostType = post_type || 'regular';
    const safeCategoryId = category_id || null;

    await c.env.DB.prepare(`
      INSERT INTO posts (id, title, content, post_type, author_id, category_id)
      VALUES (?, ?, ?, ?, ?, ?)
    `).bind(id, title, safeContent, safePostType, userId, safeCategoryId).run();

    if (image_url) {
      const mediaId = crypto.randomUUID();
      await c.env.DB.prepare(`
        INSERT INTO media (id, url, type) VALUES (?, ?, ?)
      `).bind(mediaId, image_url, 'image').run();

      const postMediaId = crypto.randomUUID();
      await c.env.DB.prepare(`
        INSERT INTO post_media (id, post_id, media_id) VALUES (?, ?, ?)
      `).bind(postMediaId, id, mediaId).run();
    }

    // Load author metadata (name, avatar) for notifications.
    const authorRow = await c.env.DB.prepare(
      'SELECT username, avatar_url FROM users WHERE id = ?',
    ).bind(userId).first();
    const authorName = (authorRow as any)?.username || 'Someone';
    const authorAvatar = (authorRow as any)?.avatar_url || null;

    // Create a simple self-notification for the author so we can
    // verify the notifications pipeline end-to-end.
    const notificationId = crypto.randomUUID();
    await c.env.DB.prepare(
      `
      INSERT INTO notifications (
        id,
        user_id,
        type,
        title,
        message,
        is_read,
        actor_id,
        actor_name,
        actor_avatar_url,
        target_type,
        target_id,
        metadata_json
      )
      VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?)
    `,
    )
      .bind(
        notificationId,
        userId,
        'post_created',
        'Post created',
        `Your post "${title}" was created.`,
        userId,
        authorName,
        authorAvatar,
        'post',
        id,
        null,
      )
      .run();

    // Broadcast via realtime channel
    await broadcastNotificationCreated(c.env, userId, {
      id: notificationId,
      type: 'post_created',
      title: 'Post created',
      message: `Your post "${title}" was created.`,
      is_read: 0,
      created_at: new Date().toISOString(),
      actor_id: userId,
      actor_name: authorName,
      actor_avatar_url: authorAvatar,
      target_type: 'post',
      target_id: id,
      metadata_json: null,
    });

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
    await broadcastUnreadCount(c.env, userId, unreadCount);

    // Fan-out: notify all other users that a new post was created
    const audience = await c.env.DB.prepare(
      'SELECT id FROM users WHERE id != ?',
    ).bind(userId).all();

    for (const row of audience.results as any[]) {
      const targetId = row.id as string;
      const publicNotifId = crypto.randomUUID();

      await c.env.DB.prepare(
        `
        INSERT INTO notifications (
          id,
          user_id,
          type,
          title,
          message,
          is_read,
          actor_id,
          actor_name,
          actor_avatar_url,
          target_type,
          target_id,
          metadata_json
        )
        VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?)
      `,
      )
        .bind(
          publicNotifId,
          targetId,
          'post_posted',
          'New post',
          `${authorName} posted "${title}".`,
          userId,
          authorName,
          authorAvatar,
          'post',
          id,
          null,
        )
        .run();

      await broadcastNotificationCreated(c.env, targetId, {
        id: publicNotifId,
        type: 'post_posted',
        title: 'New post',
        message: `${authorName} posted "${title}".`,
        is_read: 0,
        created_at: new Date().toISOString(),
        actor_id: userId,
        actor_name: authorName,
        actor_avatar_url: null,
        target_type: 'post',
        target_id: id,
        metadata_json: null,
      });

      const publicUnreadRow = await c.env.DB.prepare(
        `
        SELECT COUNT(*) AS count
        FROM notifications
        WHERE user_id = ? AND is_read = 0
      `,
      )
        .bind(targetId)
        .first();

      const publicUnreadCount = (publicUnreadRow as any)?.count ?? 0;
      await broadcastUnreadCount(c.env, targetId, publicUnreadCount);
    }

    return c.json({ message: 'Post created', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/posts/:id/like - Like a post
postRoutes.post('/:id/like', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const postId = c.req.param('id');

  try {
    const existing = await c.env.DB.prepare(
      'SELECT id FROM likes WHERE user_id = ? AND post_id = ?'
    ).bind(userId, postId).first();

    if (existing) {
      // Unlike
      await c.env.DB.prepare(
        'DELETE FROM likes WHERE user_id = ? AND post_id = ?'
      ).bind(userId, postId).run();
      
      // Decrement like count
      await c.env.DB.prepare(
        'UPDATE posts SET like_count = like_count - 1 WHERE id = ?'
      ).bind(postId).run();
      
      return c.json({ message: 'Post unliked' });
    } else {
      // Like
      const id = crypto.randomUUID();
      await c.env.DB.prepare(
        'INSERT INTO likes (id, user_id, post_id) VALUES (?, ?, ?)'
      ).bind(id, userId, postId).run();
      
      // Increment like count
      await c.env.DB.prepare(
        'UPDATE posts SET like_count = like_count + 1 WHERE id = ?'
      ).bind(postId).run();

      // Notify post author if someone else liked their post
      const postRow = await c.env.DB.prepare(
        'SELECT author_id, title FROM posts WHERE id = ?',
      ).bind(postId).first();

      if (postRow && (postRow as any).author_id !== userId) {
        const authorId = (postRow as any).author_id as string;
        const title = (postRow as any).title as string;

      const notifId = crypto.randomUUID();
      await c.env.DB.prepare(
        `
        INSERT INTO notifications (
          id,
          user_id,
          type,
          title,
          message,
          is_read,
          actor_id,
          actor_name,
          actor_avatar_url,
          target_type,
          target_id,
          metadata_json
        )
        VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?)
      `,
      )
        .bind(
          notifId,
          authorId,
          'post_liked',
          'Post liked',
          'Someone liked your post.',
          userId,
          null,
          null,
          'post',
          postId,
          null,
        )
        .run();

        await broadcastNotificationCreated(c.env, authorId, {
          id: notifId,
          type: 'post_liked',
          title: 'Post liked',
          message: `Your post "${title}" was liked.`,
          is_read: 0,
          created_at: new Date().toISOString(),
          actor_id: userId,
          actor_name: null,
          actor_avatar_url: null,
          target_type: 'post',
          target_id: postId,
          metadata_json: null,
        });

        const unreadRow = await c.env.DB.prepare(
          `
          SELECT COUNT(*) AS count
          FROM notifications
          WHERE user_id = ? AND is_read = 0
        `,
        )
          .bind(authorId)
          .first();

        const unreadCount = (unreadRow as any)?.count ?? 0;
        await broadcastUnreadCount(c.env, authorId, unreadCount);
      }

      return c.json({ message: 'Post liked' });
    }
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/posts/:id/comments - Get comments for a post
postRoutes.get('/:id/comments', async (c) => {
  const postId = c.req.param('id');
  try {
    const comments = await c.env.DB.prepare(`
      SELECT c.*, u.username as author_name, u.avatar_url as author_avatar
      FROM comments c
      JOIN users u ON c.author_id = u.id
      WHERE c.post_id = ?
      ORDER BY c.created_at ASC
    `).bind(postId).all();
    return c.json({ comments: comments.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/posts/:id/comments - Add a comment
postRoutes.post('/:id/comments', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const postId = c.req.param('id');
  const { content, parent_id } = await c.req.json();

  if (!content) return c.json({ error: 'Content is required' }, 400);

  try {
    const id = crypto.randomUUID();
    await c.env.DB.prepare(`
      INSERT INTO comments (id, content, author_id, post_id, parent_id)
      VALUES (?, ?, ?, ?, ?)
    `).bind(id, content, userId, postId, parent_id || null).run();

    // Increment comment count
    await c.env.DB.prepare(
      'UPDATE posts SET comment_count = comment_count + 1 WHERE id = ?'
    ).bind(postId).run();

    // Notify post author if someone else commented
    const postRow = await c.env.DB.prepare(
      'SELECT author_id, title FROM posts WHERE id = ?',
    ).bind(postId).first();

    if (postRow && (postRow as any).author_id !== userId) {
      const authorId = (postRow as any).author_id as string;
      const title = (postRow as any).title as string;

      const notifId = crypto.randomUUID();
      await c.env.DB.prepare(
        `
        INSERT INTO notifications (
          id,
          user_id,
          type,
          title,
          message,
          is_read,
          actor_id,
          actor_name,
          actor_avatar_url,
          target_type,
          target_id,
          metadata_json
        )
        VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?)
      `,
      )
        .bind(
          notifId,
          authorId,
          'post_commented',
          'New comment',
          'Someone commented on your post.',
          userId,
          null,
          null,
          'post',
          postId,
          null,
        )
        .run();

      await broadcastNotificationCreated(c.env, authorId, {
        id: notifId,
        type: 'post_commented',
        title: 'New comment',
        message: `Someone commented on your post "${title}".`,
        is_read: 0,
        created_at: new Date().toISOString(),
        actor_id: userId,
        actor_name: null,
        actor_avatar_url: null,
        target_type: 'post',
        target_id: postId,
        metadata_json: null,
      });

      const unreadRow = await c.env.DB.prepare(
        `
        SELECT COUNT(*) AS count
        FROM notifications
        WHERE user_id = ? AND is_read = 0
      `,
      )
        .bind(authorId)
        .first();

      const unreadCount = (unreadRow as any)?.count ?? 0;
      await broadcastUnreadCount(c.env, authorId, unreadCount);
    }

    return c.json({ message: 'Comment added', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// DELETE /api/posts/:id - Delete a post (owner only, or admin via x-admin-key)
postRoutes.delete('/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const adminKey = c.req.header('x-admin-key');
  const id = c.req.param('id');

  try {
    const existing: any = await c.env.DB.prepare(
      'SELECT author_id FROM posts WHERE id = ?',
    ).bind(id).first();

    if (!existing) {
      return c.json({ error: 'Post not found' }, 404);
    }

    const isOwner = existing.author_id === userId;
    const isAdmin = !!adminKey && adminKey === c.env.REALTIME_INTERNAL_KEY;

    if (!isOwner && !isAdmin) {
      return c.json({ error: 'Forbidden' }, 403);
    }

    await c.env.DB.prepare(
      'DELETE FROM posts WHERE id = ?',
    ).bind(id).run();

    return c.json({ message: 'Post deleted' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
