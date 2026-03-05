import { Hono } from 'hono';
import { Bindings, Variables } from '../types';

export const podcastRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/podcasts - List all podcasts
podcastRoutes.get('/', async (c) => {
  try {
    const podcasts = await c.env.DB.prepare(`
      SELECT * FROM podcasts 
      ORDER BY created_at DESC
    `).all();
    return c.json({ podcasts: podcasts.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/podcasts/:id - Podcast details and episodes
podcastRoutes.get('/:id', async (c) => {
  const id = c.req.param('id');
  try {
    const podcast = await c.env.DB.prepare('SELECT * FROM podcasts WHERE id = ?').bind(id).first();
    if (!podcast) return c.json({ error: 'Podcast not found' }, 404);

    const episodes = await c.env.DB.prepare('SELECT * FROM podcast_episodes WHERE podcast_id = ? ORDER BY published_at DESC').bind(id).all();

    return c.json({ podcast, episodes: episodes.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
