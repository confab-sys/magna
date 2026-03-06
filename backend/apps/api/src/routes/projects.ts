import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const projectRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/projects - List all projects
projectRoutes.get('/', authMiddleware, async (c) => {
  const userId = c.get('userId');

  try {
    const projects = await c.env.DB.prepare(`
      SELECT p.*, u.username as owner_name, u.avatar_url as owner_avatar,
      EXISTS (SELECT 1 FROM likes WHERE project_id = p.id AND user_id = ?) as is_liked,
      (SELECT COUNT(*) FROM comments WHERE project_id = p.id) as real_comments_count
      FROM projects p
      JOIN users u ON p.owner_id = u.id
      WHERE p.status = 'published' OR p.status = 'active'
      ORDER BY p.created_at DESC
    `).bind(userId).all();
    
    const mapped = projects.results.map((p: any) => {
      let stack: string[] = [];
      try {
        if (p.tech_stack) {
          // Try to parse as JSON
          const parsed = JSON.parse(p.tech_stack);
          if (Array.isArray(parsed)) {
            stack = parsed;
          } else {
            // If parsed but not array (e.g. string "Node.js" if it was quoted properly), wrap in array
            stack = [String(parsed)];
          }
        }
      } catch (e) {
        // If parsing fails (e.g. plain string "Node.js"), treat as single item
        if (p.tech_stack) {
          stack = [p.tech_stack];
        }
      }

      return {
        ...p,
        tech_stack: stack,
        looking_for_contributors: p.looking_for_contributors === 1,
        is_liked: p.is_liked === 1,
        comments_count: p.real_comments_count // Use dynamic count
      };
    });
    
    return c.json({ projects: mapped });
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
    
    const mapped = projects.results.map((p: any) => {
      let stack: string[] = [];
      try {
        if (p.tech_stack) {
          const parsed = JSON.parse(p.tech_stack);
          stack = Array.isArray(parsed) ? parsed : [String(parsed)];
        }
      } catch (e) {
        if (p.tech_stack) stack = [p.tech_stack];
      }

      return {
        ...p,
        tech_stack: stack,
        looking_for_contributors: p.looking_for_contributors === 1
      };
    });
    
    return c.json({ projects: mapped });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/projects/:id - Project details
projectRoutes.get('/:id', async (c) => {
  const id = c.req.param('id');
  try {
    const project: any = await c.env.DB.prepare(`
      SELECT p.*, u.username as owner_name, u.avatar_url as owner_avatar,
      (SELECT COUNT(*) FROM comments WHERE project_id = p.id) as real_comments_count
      FROM projects p
      JOIN users u ON p.owner_id = u.id
      WHERE p.id = ?
    `).bind(id).first();

    if (!project) {
      return c.json({ error: 'Project not found' }, 404);
    }

    let stack: string[] = [];
    try {
      if (project.tech_stack) {
        const parsed = JSON.parse(project.tech_stack);
        stack = Array.isArray(parsed) ? parsed : [String(parsed)];
      }
    } catch (e) {
      if (project.tech_stack) stack = [project.tech_stack];
    }

    const mapped = {
      ...project,
      tech_stack: stack,
      looking_for_contributors: project.looking_for_contributors === 1,
      comments_count: project.real_comments_count // Use dynamic count
    };

    return c.json({ project: mapped });
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

// POST /api/projects/:id/like - Like a project
projectRoutes.post('/:id/like', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const projectId = c.req.param('id');

  try {
    const existing = await c.env.DB.prepare(
      'SELECT id FROM likes WHERE user_id = ? AND project_id = ?'
    ).bind(userId, projectId).first();

    if (existing) {
      // Unlike
      await c.env.DB.prepare(
        'DELETE FROM likes WHERE user_id = ? AND project_id = ?'
      ).bind(userId, projectId).run();
      
      // Decrement like count
      await c.env.DB.prepare(
        'UPDATE projects SET likes_count = likes_count - 1 WHERE id = ?'
      ).bind(projectId).run();

      return c.json({ message: 'Project unliked', liked: false });
    } else {
      // Like
      const id = crypto.randomUUID();
      await c.env.DB.prepare(
        'INSERT INTO likes (id, user_id, project_id) VALUES (?, ?, ?)'
      ).bind(id, userId, projectId).run();
      
      // Increment like count
      await c.env.DB.prepare(
        'UPDATE projects SET likes_count = likes_count + 1 WHERE id = ?'
      ).bind(projectId).run();

      return c.json({ message: 'Project liked', liked: true });
    }
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/projects - Create project
projectRoutes.post('/', authMiddleware, async (c) => {
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
  const short_description = body['short_description'];
  const category_id = body['category_id'];
  const tech_stack = body['tech_stack'];
  const looking_for_contributors = body['looking_for_contributors'] === 'true' || body['looking_for_contributors'] === true || body['looking_for_contributors'] === 1;
  const max_contributors = body['max_contributors'] ? parseInt(String(body['max_contributors'])) : null;
  let image_url = body['image_url'];
  const repository_url = body['repository_url'];
  const start_date = body['start_date'];
  const end_date = body['end_date'];
  const visibility = body['visibility'];
  const status = body['status'];

  // Handle multipart file upload for 'image'
  const imageFile = body['image'];
  
  if (imageFile) {
    if (typeof imageFile !== 'string') {
      try {
        const fileId = crypto.randomUUID();
        const fileName = (imageFile as any).name || 'project-image.jpg';
        const key = `projects/${fileId}-${fileName}`;
        
        const buffer = await (imageFile as any).arrayBuffer();
        
        // Upload to R2
        await c.env.MEDIA.put(key, buffer);
        
        // Construct public URL
        const origin = new URL(c.req.url).origin;
        image_url = `${origin}/api/files/${key}`;
      } catch (e: any) {
        console.error('Failed to upload project image:', e);
      }
    } else {
      // If it's already a string, use it
      image_url = imageFile;
    }
  }

  if (!title) {
    return c.json({ error: 'Title is required' }, 400);
  }

  try {
    const id = crypto.randomUUID();
    // Use NULL for optional category_id if not provided
    const safeCategoryId = category_id || null;
    
    // tech_stack handling for both JSON array and string
    let stackJson = null;
    if (tech_stack) {
      if (typeof tech_stack === 'string') {
        try {
          // Check if it's already a JSON string
          JSON.parse(tech_stack);
          stackJson = tech_stack;
        } catch (e) {
          // If not, it's a plain string, wrap it
          stackJson = JSON.stringify([tech_stack]);
        }
      } else {
        stackJson = JSON.stringify(tech_stack);
      }
    }
    
    await c.env.DB.prepare(`
      INSERT INTO projects (
        id, title, description, short_description, category_id, tech_stack, 
        looking_for_contributors, max_contributors, owner_id, status, visibility, image_url, 
        repository_url, start_date, end_date, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `).bind(
      id, 
      title, 
      description, 
      short_description, 
      safeCategoryId, 
      stackJson, 
      looking_for_contributors ? 1 : 0, 
      max_contributors, 
      userId, 
      status || 'published',
      visibility || 'public',
      image_url || null,
      repository_url || null,
      start_date || null,
      end_date || null
    ).run();

    return c.json({ 
      message: 'Project created', 
      id, 
      imageUrl: image_url
    }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// PUT /api/projects/:id - Update project
projectRoutes.put('/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const id = c.req.param('id');
  const body = await c.req.json();
  const { title, description, status, tech_stack, looking_for_contributors, image_url } = body;

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
        image_url = COALESCE(?, image_url),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `).bind(title, description, status, tech_stack ? JSON.stringify(tech_stack) : null, looking_for_contributors ? 1 : 0, image_url, id).run();

    return c.json({ message: 'Project updated' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
