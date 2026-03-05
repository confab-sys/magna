import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const fileRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/files/upload-url - Generate an R2 upload URL
fileRoutes.get('/upload-url', authMiddleware, async (c) => {
  const filename = c.req.query('filename');
  // const contentType = c.req.query('contentType');

  if (!filename) return c.json({ error: 'Filename is required' }, 400);

  const userId = c.get('userId');
  const key = `${userId}/${Date.now()}-${filename}`;

  // Placeholder for real signed URL logic (R2 doesn't have native getSignedUrl in Worker)
  // Usually this is done via a separate service or a custom implementation
  return c.json({
    uploadUrl: `https://media.magnacoders.com/${key}?sig=mock-signature`,
    key,
    publicUrl: `https://media.magnacoders.com/${key}`
  });
});

// GET /api/files/:key - Get file info
fileRoutes.get('/:key', async (c) => {
  const key = c.req.param('key');
  const object = await c.env.MEDIA.get(key);

  if (!object) return c.json({ error: 'File not found' }, 404);

  const headers = new Headers();
  object.writeHttpMetadata(headers);
  headers.set('etag', object.httpEtag);

  return new Response(object.body, { headers });
});
