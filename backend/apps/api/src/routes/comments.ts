import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';
import {
  broadcastNotificationCreated,
  broadcastUnreadCount,
} from '../services/notifications_realtime';

export const commentRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/comments/post/:postId - List comments for a post or job or project
commentRoutes.get('/post/:postId', authMiddleware, async (c) => {
  const targetId = c.req.param('postId');
  const userId = c.get('userId'); // For checking if user liked comments

  try {
    const comments = await c.env.DB.prepare(`
      SELECT 
        c.*, 
        u.username as author_name, 
        u.avatar_url as author_avatar,
        (SELECT COUNT(*) FROM likes l WHERE l.comment_id = c.id AND l.user_id = ?) as is_liked
      FROM comments c
      JOIN users u ON c.author_id = u.id
      WHERE (c.post_id = ? OR c.job_id = ? OR c.project_id = ?)
      ORDER BY c.created_at ASC
    `).bind(userId, targetId, targetId, targetId).all();
    
    // Map boolean for is_liked
    const results = comments.results.map((comment: any) => ({
      ...comment,
      is_liked: comment.is_liked === 1
    }));

    return c.json({ comments: results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/comments - Create a comment
commentRoutes.post('/', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  const { post_id, job_id, project_id, content, parent_id } = body;

  if ((!post_id && !job_id && !project_id) || !content) {
    return c.json({ error: 'Target ID (post_id, job_id, or project_id) and content are required' }, 400);
  }

  try {
    const id = crypto.randomUUID();
    
    if (post_id) {
        await c.env.DB.prepare(`
          INSERT INTO comments (id, post_id, author_id, content, parent_id, created_at)
          VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        `).bind(id, post_id, userId, content, parent_id || null).run();

        // Increment comment count on post
        await c.env.DB.prepare(`
          UPDATE posts SET comment_count = comment_count + 1 WHERE id = ?
        `).bind(post_id).run();
        
        // Notify post author
        const postRow = await c.env.DB.prepare(
          'SELECT author_id, title FROM posts WHERE id = ?',
        ).bind(post_id).first();

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
              post_id,
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
            target_id: post_id,
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
    } else if (job_id) {
        await c.env.DB.prepare(`
          INSERT INTO comments (id, job_id, author_id, content, parent_id, created_at)
          VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        `).bind(id, job_id, userId, content, parent_id || null).run();
        
        await c.env.DB.prepare(`
          UPDATE jobs SET comments_count = comments_count + 1 WHERE id = ?
        `).bind(job_id).run();
    } else if (project_id) {
        await c.env.DB.prepare(`
          INSERT INTO comments (id, project_id, author_id, content, parent_id, created_at)
          VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        `).bind(id, project_id, userId, content, parent_id || null).run();
        
        await c.env.DB.prepare(`
          UPDATE projects SET comments_count = comments_count + 1 WHERE id = ?
        `).bind(project_id).run();
    }

    // Fetch the created comment to return full object
    const newComment = await c.env.DB.prepare(`
      SELECT c.*, u.username as author_name, u.avatar_url as author_avatar
      FROM comments c
      JOIN users u ON c.author_id = u.id
      WHERE c.id = ?
    `).bind(id).first();

    return c.json({ message: 'Comment added', comment: newComment }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/comments/:id/like - Like a comment
commentRoutes.post('/:id/like', authMiddleware, async (c) => {
  const commentId = c.req.param('id');
  const userId = c.get('userId');

  try {
    const id = crypto.randomUUID();
    
    const existing = await c.env.DB.prepare(
      'SELECT id FROM likes WHERE comment_id = ? AND user_id = ?'
    ).bind(commentId, userId).first();

    if (existing) {
       // Unlike
       await c.env.DB.prepare(
         'DELETE FROM likes WHERE id = ?'
       ).bind(existing.id).run();
       
       // Decrement like count
       await c.env.DB.prepare(
         'UPDATE comments SET likes_count = likes_count - 1 WHERE id = ?'
       ).bind(commentId).run();

       return c.json({ message: 'Comment unliked', liked: false });
    } else {
       // Like
       await c.env.DB.prepare(`
         INSERT INTO likes (id, comment_id, user_id)
         VALUES (?, ?, ?)
       `).bind(id, commentId, userId).run();

       // Increment like count
       await c.env.DB.prepare(
         'UPDATE comments SET likes_count = likes_count + 1 WHERE id = ?'
       ).bind(commentId).run();

       return c.json({ message: 'Comment liked', liked: true });
    }
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// DELETE /api/comments/:id - Delete a comment
commentRoutes.delete('/:id', authMiddleware, async (c) => {
  const commentId = c.req.param('id');
  const userId = c.get('userId');

  try {
    // Verify ownership
    const comment = await c.env.DB.prepare(
      'SELECT author_id, post_id FROM comments WHERE id = ?'
    ).bind(commentId).first();

    if (!comment) {
      return c.json({ error: 'Comment not found' }, 404);
    }

    if (comment.author_id !== userId) {
      return c.json({ error: 'Unauthorized' }, 403);
    }

    // Delete comment
    await c.env.DB.prepare(
      'DELETE FROM comments WHERE id = ?'
    ).bind(commentId).run();

    // Decrement post comment count
    if (comment.post_id) {
        await c.env.DB.prepare(
          'UPDATE posts SET comment_count = comment_count - 1 WHERE id = ?'
        ).bind(comment.post_id).run();
    }

    return c.json({ message: 'Comment deleted' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
