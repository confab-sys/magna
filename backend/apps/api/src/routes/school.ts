import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const schoolRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/courses - List all courses
schoolRoutes.get('/', async (c) => {
  try {
    const courses = await c.env.DB.prepare(`
      SELECT * FROM courses 
      WHERE is_published = 1 
      ORDER BY created_at DESC
    `).all();
    return c.json({ courses: courses.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/courses/:id - Course details including lessons
schoolRoutes.get('/:id', async (c) => {
  const id = c.req.param('id');
  try {
    const course = await c.env.DB.prepare('SELECT * FROM courses WHERE id = ?').bind(id).first();
    if (!course) return c.json({ error: 'Course not found' }, 404);

    const lessons = await c.env.DB.prepare('SELECT * FROM lessons WHERE course_id = ? ORDER BY order_index ASC').bind(id).all();

    return c.json({ course, lessons: lessons.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/courses/enroll/:id - Enroll in a course
schoolRoutes.post('/enroll/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const courseId = c.req.param('id');

  try {
    // Check if already enrolled
    const existing = await c.env.DB.prepare(
      'SELECT id FROM lesson_progress WHERE user_id = ? AND lesson_id IN (SELECT id FROM lessons WHERE course_id = ?)'
    ).bind(userId, courseId).first();

    if (existing) return c.json({ error: 'Already enrolled' }, 409);

    // In a real app, we might have a dedicated enrollment table.
    // For now, let's just return success or update a placeholder logic.
    return c.json({ message: 'Enrolled successfully' }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
