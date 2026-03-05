import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const jobRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/jobs - List all opportunities
jobRoutes.get('/', async (c) => {
  try {
    const opportunities = await c.env.DB.prepare(`
      SELECT o.*, c.name as company_name, c.logo_url as company_logo
      FROM jobs o
      LEFT JOIN companies c ON o.company_id = c.id
      ORDER BY o.created_at DESC
    `).all();
    return c.json({ opportunities: opportunities.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/jobs/:id - Job details
jobRoutes.get('/:id', async (c) => {
  const id = c.req.param('id');
  try {
    const opportunity = await c.env.DB.prepare(`
      SELECT o.*, c.name as company_name, c.logo_url as company_logo, u.username as author_name
      FROM jobs o
      LEFT JOIN companies c ON o.company_id = c.id
      JOIN users u ON o.author_id = u.id
      WHERE o.id = ?
    `).bind(id).first();

    if (!opportunity) {
      return c.json({ error: 'Opportunity not found' }, 404);
    }

    return c.json({ opportunity });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/jobs - Create job opportunity
jobRoutes.post('/', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  const { title, description, company_id, location, salary, job_type, deadline, category_id } = body;

  if (!title) {
    return c.json({ error: 'Title is required' }, 400);
  }

  try {
    const id = crypto.randomUUID();
    // Use NULL for optional category_id if not provided
    const safeCategoryId = category_id || null;

    await c.env.DB.prepare(`
      INSERT INTO jobs (
        id, title, description, company_id, location, salary, job_type, 
        deadline, author_id, category_id, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `).bind(
      id, title, description, company_id, location, salary, job_type, 
      deadline, userId, safeCategoryId
    ).run();

    return c.json({ message: 'Opportunity created', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/jobs/apply/:id - Apply for job
jobRoutes.post('/apply/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const opportunityId = c.req.param('id');
  const body = await c.req.json();
  const { resume_url, cover_letter } = body;

  try {
    // Check if already applied
    const existing = await c.env.DB.prepare(
      'SELECT id FROM applications WHERE jobs_id = ? AND user_id = ?'
    ).bind(opportunityId, userId).first();

    if (existing) {
      return c.json({ error: 'Application already submitted' }, 409);
    }

    const id = crypto.randomUUID();
    await c.env.DB.prepare(`
      INSERT INTO applications (
        id, jobs_id, user_id, resume_url, cover_letter, status, submitted_at
      ) VALUES (?, ?, ?, ?, ?, 'submitted', CURRENT_TIMESTAMP)
    `).bind(id, opportunityId, userId, resume_url, cover_letter).run();

    return c.json({ message: 'Application submitted', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
