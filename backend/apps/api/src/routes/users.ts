import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const userRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/users - Builders list
userRoutes.get('/', async (c) => {
  try {
    const users = await c.env.DB.prepare(`
      SELECT id, username, avatar_url, location, bio, tagline, role
      FROM users
      ORDER BY created_at DESC
      LIMIT 50
    `).all();
    return c.json({ users: users.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/users/profile - Get current user profile
userRoutes.get('/profile', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const user = await c.env.DB.prepare('SELECT * FROM users WHERE id = ?').bind(userId).first();
    if (!user) return c.json({ error: 'User not found' }, 404);
    return c.json({ user });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/users/:id - Get specific user profile
userRoutes.get('/:id', async (c) => {
  const id = c.req.param('id');
  try {
    const user = await c.env.DB.prepare(`
      SELECT id, username, avatar_url, location, bio, tagline, role, website_url, github_url, linkedin_url
      FROM users WHERE id = ?
    `).bind(id).first();
    if (!user) return c.json({ error: 'User not found' }, 404);
    return c.json({ user });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// PUT /api/users/profile - Update profile
userRoutes.put('/profile', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  const { avatar_url, location, bio, tagline, website_url, github_url, linkedin_url, twitter_url, whatsapp_url } = body;

  try {
    await c.env.DB.prepare(`
      UPDATE users SET 
        avatar_url = COALESCE(?, avatar_url),
        location = COALESCE(?, location),
        bio = COALESCE(?, bio),
        tagline = COALESCE(?, tagline),
        website_url = COALESCE(?, website_url),
        github_url = COALESCE(?, github_url),
        linkedin_url = COALESCE(?, linkedin_url),
        twitter_url = COALESCE(?, twitter_url),
        whatsapp_url = COALESCE(?, whatsapp_url),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `).bind(avatar_url, location, bio, tagline, website_url, github_url, linkedin_url, twitter_url, whatsapp_url, userId).run();

    return c.json({ message: 'Profile updated' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
