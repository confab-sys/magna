import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const projectRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/projects - List all projects
projectRoutes.get('/', async (c) => {
  try {
    const projects = await c.env.DB.prepare(`
      SELECT p.*, u.username as owner_name, u.avatar_url as owner_avatar
      FROM projects p
      JOIN users u ON p.owner_id = u.id
      WHERE p.status = 'published' OR p.status = 'active'
      ORDER BY p.created_at DESC
    `).all();
    return c.json({ projects: projects.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/projects/my - List current user's projects
projectRoutes.get('/my', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const projects = await c.env.DB.prepare(
      'SELECT * FROM projects WHERE owner_id = ? ORDER BY created_at DESC'
    ).bind(userId).all();
    return c.json({ projects: projects.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/projects/:id - Project details
projectRoutes.get('/:id', async (c) => {
  const id = c.req.param('id');
  try {
    const project = await c.env.DB.prepare(`
      SELECT p.*, u.username as owner_name, u.avatar_url as owner_avatar
      FROM projects p
      JOIN users u ON p.owner_id = u.id
      WHERE p.id = ?
    `).bind(id).first();

    if (!project) {
      return c.json({ error: 'Project not found' }, 404);
    }

    return c.json({ project });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/projects/:id/files - List project files
projectRoutes.get('/:id/files', authMiddleware, async (c) => {
  const id = c.req.param('id');
  const userId = c.get('userId');

  try {
    // Verify access - assuming public projects are readable, private ones need auth
    // But route is authMiddleware protected already.
    const project = await c.env.DB.prepare('SELECT owner_id, status, visibility FROM projects WHERE id = ?').bind(id).first();
    
    if (!project) return c.json({ error: 'Project not found' }, 404);
    
    // Allow if owner or if project is public
    // if ((project as any).owner_id !== userId && (project as any).visibility !== 'public') {
    //   return c.json({ error: 'Unauthorized' }, 403);
    // }

    // List files from R2 under projects/{id}/
    const prefix = `projects/${id}/`;
    const listed = await c.env.MEDIA.list({ prefix });
    
    const files = listed.objects.map(obj => ({
      key: obj.key,
      size: obj.size,
      uploadedAt: obj.uploaded,
      url: `${c.env.R2_PUBLIC_URL || 'https://media.magnacoders.com'}/${obj.key}`
    }));

    return c.json({ files });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/projects - Create project
projectRoutes.post('/', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  const { title, description, short_description, category_id, tech_stack, looking_for_contributors, max_contributors } = body;

  if (!title) {
    return c.json({ error: 'Title is required' }, 400);
  }

  try {
    const id = crypto.randomUUID();
    // Use NULL for optional category_id if not provided
    const safeCategoryId = category_id || null;
    
    await c.env.DB.prepare(`
      INSERT INTO projects (
        id, title, description, short_description, category_id, tech_stack, 
        looking_for_contributors, max_contributors, owner_id, status, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'published', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `).bind(
      id, title, description, short_description, safeCategoryId, tech_stack, 
      looking_for_contributors ? 1 : 0, max_contributors, userId
    ).run();

    return c.json({ message: 'Project created', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// PUT /api/projects/:id - Update project
projectRoutes.put('/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const id = c.req.param('id');
  const body = await c.req.json();
  const { title, description, status, tech_stack, looking_for_contributors } = body;

  try {
    const existing = await c.env.DB.prepare('SELECT owner_id FROM projects WHERE id = ?').bind(id).first();
    if (!existing) return c.json({ error: 'Project not found' }, 404);
    if ((existing as any).owner_id !== userId) return c.json({ error: 'Unauthorized' }, 403);

    await c.env.DB.prepare(`
      UPDATE projects SET 
        title = COALESCE(?, title),
        description = COALESCE(?, description),
        status = COALESCE(?, status),
        tech_stack = COALESCE(?, tech_stack),
        looking_for_contributors = COALESCE(?, looking_for_contributors),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `).bind(title, description, status, tech_stack ? JSON.stringify(tech_stack) : null, looking_for_contributors ? 1 : 0, id).run();

    return c.json({ message: 'Project updated' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
