import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const userRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const parseStringArray = (value: any): string[] => {
  if (!value) return [];
  if (Array.isArray(value)) return value.map((v) => String(v));
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value);
      return Array.isArray(parsed) ? parsed.map((v) => String(v)) : [];
    } catch {
      // If it's a simple comma-separated string, split it
      if (value.includes(',')) {
        return value.split(',').map((v: string) => v.trim()).filter(Boolean);
      }
      return [value];
    }
  }
  return [];
};

// GET /api/users - List users (builders)
userRoutes.get('/', authMiddleware, async (c) => {
  try {
    const result = await c.env.DB.prepare(
      `SELECT 
        id,
        username,
        email,
        avatar_url,
        cover_photo_url,
        location,
        bio,
        website_url,
        github_url,
        linkedin_url,
        twitter_url,
        whatsapp_url,
        tagline,
        categories,
        looking_for,
        skills
      FROM users
      ORDER BY created_at DESC`
    ).all();

    const users = (result.results as any[]).map((u) => {
      const { categories, looking_for, skills, ...rest } = u as any;
      return {
        ...rest,
        categories: parseStringArray(categories),
        lookingFor: parseStringArray(looking_for),
        skills: parseStringArray(skills),
      };
    });

    return c.json({ users });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/users/profile - Current user's profile
userRoutes.get('/profile', authMiddleware, async (c) => {
  const userId = c.get('userId');

  try {
    const user: any = await c.env.DB.prepare(
      'SELECT * FROM users WHERE id = ?'
    ).bind(userId).first();

    if (!user) {
      return c.json({ error: 'User not found' }, 404);
    }

    const { categories, looking_for, skills, ...rest } = user as any;

    return c.json({
      user: {
        ...rest,
        categories: parseStringArray(categories),
        lookingFor: parseStringArray(looking_for),
        skills: parseStringArray(skills),
      },
    });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/users/:id - Public profile for a specific user
userRoutes.get('/:id', authMiddleware, async (c) => {
  const id = c.req.param('id');

  try {
    const user: any = await c.env.DB.prepare(
      'SELECT * FROM users WHERE id = ?'
    ).bind(id).first();

    if (!user) {
      return c.json({ error: 'User not found' }, 404);
    }

    const { categories, looking_for, skills, ...rest } = user as any;

    return c.json({
      user: {
        ...rest,
        categories: parseStringArray(categories),
        lookingFor: parseStringArray(looking_for),
        skills: parseStringArray(skills),
      },
    });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// PUT /api/users/profile - Update current user's profile
userRoutes.put('/profile', authMiddleware, async (c) => {
  const userId = c.get('userId');

  let body: any;
  try {
    body = await c.req.json();
  } catch {
    return c.json({ error: 'Invalid JSON body' }, 400);
  }

  // Normalize list fields from camelCase to snake_case for storage
  if (Array.isArray(body.categories)) {
    body.categories = JSON.stringify(body.categories);
  }
  if (Array.isArray(body.skills)) {
    body.skills = JSON.stringify(body.skills);
  }
  if (Array.isArray(body.lookingFor)) {
    body.looking_for = JSON.stringify(body.lookingFor);
  } else if (Array.isArray(body.looking_for)) {
    body.looking_for = JSON.stringify(body.looking_for);
  }

  // Allow partial updates; only update fields that are present in the payload
  const allowedFields = [
    'avatar_url',
    'cover_photo_url',
    'location',
    'bio',
    'tagline',
    'website_url',
    'github_url',
    'linkedin_url',
    'twitter_url',
    'whatsapp_url',
    'categories',
    'looking_for',
    'skills',
  ] as const;

  const updates: string[] = [];
  const params: any[] = [];

  for (const field of allowedFields) {
    if (Object.prototype.hasOwnProperty.call(body, field)) {
      updates.push(`${field} = ?`);
      params.push(body[field]);
    }
  }

  if (updates.length === 0) {
    return c.json({ error: 'No updatable fields provided' }, 400);
  }

  // Always bump updated_at timestamp when profile is changed
  updates.push('updated_at = CURRENT_TIMESTAMP');

  params.push(userId);

  try {
    await c.env.DB.prepare(
      `UPDATE users SET ${updates.join(', ')} WHERE id = ?`
    ).bind(...params).run();

    const updatedUser: any = await c.env.DB.prepare(
      'SELECT * FROM users WHERE id = ?'
    ).bind(userId).first();

    return c.json({ user: updatedUser });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

