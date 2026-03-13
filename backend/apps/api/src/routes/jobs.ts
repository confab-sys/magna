import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';
import {
  broadcastNotificationCreated,
  broadcastUnreadCount,
} from '../services/notifications_realtime';

export const jobRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/jobs - List all opportunities
jobRoutes.get('/', authMiddleware, async (c) => {
  const userId = c.get('userId');

  try {
    const jobs = await c.env.DB.prepare(`
      SELECT 
        o.*, 
        c.name as company_name, 
        -- Use creator's avatar as the primary avatar for the job card
        u.avatar_url as company_logo_url,
        c.verified as company_verified,
        EXISTS (SELECT 1 FROM likes WHERE job_id = o.id AND user_id = ?) as is_liked,
        (SELECT COUNT(*) FROM comments WHERE job_id = o.id) as real_comments_count
      FROM jobs o
      LEFT JOIN companies c ON o.company_id = c.id
      JOIN users u ON o.author_id = u.id
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
  
  let body: any;
  const contentType = c.req.header('content-type');
  
  if (contentType?.includes('application/json')) {
    body = await c.req.json();
  } else {
    body = await c.req.parseBody();
  }
  
  const title = body['title'];
  const description = body['description'];
  const company_id = body['company_id'];
  const company_name = body['company_name'];
  const location = body['location'];
  const salary = body['salary'];
  const job_type = body['job_type'];
  const deadline = body['deadline'];
  const category_id = body['category_id'];
  let job_image_url = body['job_image_url'];

  // Handle multipart file upload for 'image'
  const imageFile = body['image'];
  if (imageFile) {
    if (typeof imageFile !== 'string') {
      try {
        const fileId = crypto.randomUUID();
        const fileName = (imageFile as any).name || 'job-image.jpg';
        const key = `jobs/${fileId}-${fileName}`;
        const buffer = await (imageFile as any).arrayBuffer();
        
        // Upload to R2
        await c.env.MEDIA.put(key, buffer);
        
        // Construct public URL
        const origin = new URL(c.req.url).origin;
        job_image_url = `${origin}/api/files/${key}`;
      } catch (e: any) {
        console.error('Failed to upload job image:', e);
      }
    } else {
      job_image_url = imageFile;
    }
  }

  if (!title) {
    return c.json({ error: 'Title is required' }, 400);
  }

  try {
    const id = crypto.randomUUID();
    let effectiveCompanyId = company_id as string | null;

    // If no existing company_id but a free-text company_name is provided, create a simple company record.
    if (!effectiveCompanyId && company_name) {
      const newCompanyId = crypto.randomUUID();
      await c.env.DB.prepare(
        `
        INSERT INTO companies (id, name, logo_url, website_url, description, location, verified)
        VALUES (?, ?, NULL, NULL, NULL, NULL, 0)
      `,
      )
        .bind(newCompanyId, company_name)
        .run();

      effectiveCompanyId = newCompanyId;
    }
    // Ensure all values are either string or null, NOT undefined for D1
    const safeCategoryId = category_id || null;
    const safeCompanyId = effectiveCompanyId || null;
    const safeLocation = location || null;
    const safeSalary = salary || null;
    const safeJobType = job_type || null;
    const safeDeadline = deadline || null;
    const safeJobImageUrl = job_image_url || null;

    await c.env.DB.prepare(`
      INSERT INTO jobs (
        id, title, description, company_id, location, salary, job_type, 
        deadline, author_id, category_id, job_image_url, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `).bind(
      id, title, description, safeCompanyId, safeLocation, safeSalary, safeJobType,
      safeDeadline, userId, safeCategoryId, safeJobImageUrl,
    ).run();

    // Load author metadata (name, avatar) for notifications.
    const authorRow = await c.env.DB.prepare(
      'SELECT username, avatar_url FROM users WHERE id = ?',
    ).bind(userId).first();
    const authorName = (authorRow as any)?.username || 'Someone';
    const authorAvatar = (authorRow as any)?.avatar_url || null;

    // Self-notification for job creation
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
        'job_posted',
        'Job created',
        `Your job "${title}" was created.`,
        userId,
        authorName,
        authorAvatar,
        'job',
        id,
        null,
      )
      .run();

    await broadcastNotificationCreated(c.env, userId, {
      id: notificationId,
      type: 'job_posted',
      title: 'Job created',
      message: `Your job "${title}" was created.`,
      is_read: 0,
      created_at: new Date().toISOString(),
      actor_id: userId,
      actor_name: authorName,
      actor_avatar_url: authorAvatar,
      target_type: 'job',
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

    // Fan-out: notify all other users about the new job

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
          'job_posted',
          'New job',
          `${authorName} posted job "${title}".`,
          userId,
          authorName,
          authorAvatar,
          'job',
          id,
          null,
        )
        .run();

      await broadcastNotificationCreated(c.env, targetId, {
        id: publicNotifId,
        type: 'job_posted',
        title: 'New job',
        message: `${authorName} posted job "${title}".`,
        is_read: 0,
        created_at: new Date().toISOString(),
        actor_id: userId,
        actor_name: authorName,
        actor_avatar_url: null,
        target_type: 'job',
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

      // Notify job author if someone else liked their job
      const jobRow = await c.env.DB.prepare(
        'SELECT author_id, title FROM jobs WHERE id = ?',
      ).bind(jobId).first();

      if (jobRow && (jobRow as any).author_id !== userId) {
        const authorId = (jobRow as any).author_id as string;
        const title = (jobRow as any).title as string;

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
            'job_liked',
            'Job liked',
            'Someone liked your job.',
            userId,
            null,
            null,
            'job',
            jobId,
            null,
          )
          .run();

        await broadcastNotificationCreated(c.env, authorId, {
          id: notifId,
          type: 'job_liked',
          title: 'Job liked',
          message: `Someone liked your job "${title}".`,
          is_read: 0,
          created_at: new Date().toISOString(),
          actor_id: userId,
          actor_name: null,
          actor_avatar_url: null,
          target_type: 'job',
          target_id: jobId,
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

// DELETE /api/jobs/:id - Delete job (author only, or admin via x-admin-key)
jobRoutes.delete('/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const adminKey = c.req.header('x-admin-key');
  const id = c.req.param('id');

  try {
    const existing: any = await c.env.DB.prepare(
      'SELECT author_id FROM jobs WHERE id = ?',
    ).bind(id).first();

    if (!existing) {
      return c.json({ error: 'Job not found' }, 404);
    }

    const isOwner = existing.author_id === userId;
    const isAdmin = !!adminKey && adminKey === c.env.REALTIME_INTERNAL_KEY;

    if (!isOwner && !isAdmin) {
      return c.json({ error: 'Forbidden' }, 403);
    }

    await c.env.DB.prepare(
      'DELETE FROM jobs WHERE id = ?',
    ).bind(id).run();

    return c.json({ message: 'Job deleted' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
