import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const postRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/posts - List all posts
postRoutes.get('/', async (c) => {
  try {
    const posts = await c.env.DB.prepare(`
      SELECT p.*, u.username as author_name, u.avatar_url as author_avatar
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

postRoutes.get('/feed', async (c) => {
  // Try to get from cache first
  const cachedFeed = await c.env.CACHE.get('global_feed');
  if (cachedFeed) {
    return c.json({ posts: JSON.parse(cachedFeed), source: 'cache' });
  }

  try {
    const posts = await c.env.DB.prepare(`
      SELECT p.*, u.username as author_name, u.avatar_url as author_avatar
      FROM posts p
      JOIN users u ON p.author_id = u.id
      ORDER BY p.created_at DESC
      LIMIT 50
    `).all();

    // Cache the result for 60 seconds
    await c.env.CACHE.put('global_feed', JSON.stringify(posts.results), { expirationTtl: 60 });

    return c.json({ posts: posts.results, source: 'db' });
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
      (SELECT COUNT(*) FROM comments WHERE post_id = p.id) as comment_count
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
  const { title, content, post_type, category_id } = await c.req.json();

  if (!title) {
    return c.json({ error: 'Title is required' }, 400);
  }

  try {
    const id = crypto.randomUUID();
    await c.env.DB.prepare(`
      INSERT INTO posts (id, title, content, post_type, author_id, category_id)
      VALUES (?, ?, ?, ?, ?, ?)
    `).bind(id, title, content, post_type || 'regular', userId, category_id || null).run();

    // Invalidate feed cache
    await c.env.CACHE.delete('global_feed');

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
      return c.json({ message: 'Post unliked' });
    } else {
      // Like
      const id = crypto.randomUUID();
      await c.env.DB.prepare(
        'INSERT INTO likes (id, user_id, post_id) VALUES (?, ?, ?)'
      ).bind(id, userId, postId).run();
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

    return c.json({ message: 'Comment added', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
