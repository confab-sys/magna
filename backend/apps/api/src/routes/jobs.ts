import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const jobRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/jobs - List all opportunities
jobRoutes.get('/', authMiddleware, async (c) => {
  const userId = c.get('userId');

  try {
    const jobs = await c.env.DB.prepare(`
      SELECT o.*, c.name as company_name, c.logo_url as company_logo_url, c.verified as company_verified,
      EXISTS (SELECT 1 FROM likes WHERE job_id = o.id AND user_id = ?) as is_liked,
      (SELECT COUNT(*) FROM comments WHERE job_id = o.id) as real_comments_count
      FROM jobs o
      LEFT JOIN companies c ON o.company_id = c.id
      ORDER BY o.created_at DESC
    `).bind(userId).all();
    
    const mapped = jobs.results.map((j: any) => ({
      ...j,
      is_liked: j.is_liked === 1,
      comments_count: j.real_comments_count // Use dynamic count
    }));
    
    return c.json({ jobs: mapped });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/jobs/:id - Job details
jobRoutes.get('/:id', async (c) => {
  const id = c.req.param('id');
  try {
    const job: any = await c.env.DB.prepare(`
      SELECT o.*, c.name as company_name, c.logo_url as company_logo, u.username as author_name,
      (SELECT COUNT(*) FROM comments WHERE job_id = o.id) as real_comments_count
      FROM jobs o
      LEFT JOIN companies c ON o.company_id = c.id
      JOIN users u ON o.author_id = u.id
      WHERE o.id = ?
    `).bind(id).first();

    if (!job) {
      return c.json({ error: 'Job not found' }, 404);
    }

    // Use dynamic count
    job.comments_count = job.real_comments_count;

    return c.json({ job });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/jobs/companies - Create a company (Helper for demo)
jobRoutes.post('/companies', authMiddleware, async (c) => {
  const body = await c.req.json();
  const { name, logo_url, website_url, description, location } = body;

  if (!name) return c.json({ error: 'Name is required' }, 400);

  try {
    const id = crypto.randomUUID();
    await c.env.DB.prepare(`
      INSERT INTO companies (id, name, logo_url, website_url, description, location, verified)
      VALUES (?, ?, ?, ?, ?, ?, 1)
    `).bind(id, name, logo_url, website_url, description, location).run();

    return c.json({ message: 'Company created', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/jobs - Create job
jobRoutes.post('/', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  const { title, description, company_id, location, salary, job_type, deadline, category_id, job_image_url } = body;

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
        deadline, author_id, category_id, job_image_url, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `).bind(
      id, title, description, company_id, location, salary, job_type, 
      deadline, userId, safeCategoryId, job_image_url
    ).run();

    return c.json({ message: 'Job created', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/jobs/:id/like - Like a job
jobRoutes.post('/:id/like', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const jobId = c.req.param('id');

  try {
    const existing = await c.env.DB.prepare(
      'SELECT id FROM likes WHERE user_id = ? AND job_id = ?'
    ).bind(userId, jobId).first();

    if (existing) {
      // Unlike
      await c.env.DB.prepare(
        'DELETE FROM likes WHERE user_id = ? AND job_id = ?'
      ).bind(userId, jobId).run();
      
      // Decrement like count
      await c.env.DB.prepare(
        'UPDATE jobs SET likes_count = likes_count - 1 WHERE id = ?'
      ).bind(jobId).run();

      return c.json({ message: 'Job unliked', liked: false });
    } else {
      // Like
      const id = crypto.randomUUID();
      await c.env.DB.prepare(
        'INSERT INTO likes (id, user_id, job_id) VALUES (?, ?, ?)'
      ).bind(id, userId, jobId).run();
      
      // Increment like count
      await c.env.DB.prepare(
        'UPDATE jobs SET likes_count = likes_count + 1 WHERE id = ?'
      ).bind(jobId).run();

      return c.json({ message: 'Job liked', liked: true });
    }
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/jobs/apply/:id - Apply for job
jobRoutes.post('/apply/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const jobId = c.req.param('id');
  const body = await c.req.json();
  const { resume_url, cover_letter } = body;

  try {
    // Check if already applied
    const existing = await c.env.DB.prepare(
      'SELECT id FROM applications WHERE jobs_id = ? AND user_id = ?'
    ).bind(jobId, userId).first();

    if (existing) {
      return c.json({ error: 'Application already submitted' }, 409);
    }

    const id = crypto.randomUUID();
    await c.env.DB.prepare(`
      INSERT INTO applications (
        id, jobs_id, user_id, resume_url, cover_letter, status, submitted_at
      ) VALUES (?, ?, ?, ?, ?, 'submitted', CURRENT_TIMESTAMP)
    `).bind(id, jobId, userId, resume_url, cover_letter).run();

    return c.json({ message: 'Application submitted', id }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
