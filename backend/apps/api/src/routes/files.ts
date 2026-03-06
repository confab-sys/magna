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

  // For testing/dev purposes (and simple production use cases), we can proxy the upload through the Worker.
  // In a high-scale production setup, you should use Presigned URLs with AWS SDK.
  const origin = new URL(c.req.url).origin;
  
  // We encode the key to ensure it works with path parameters, OR we rely on wildcard matching.
  // Let's use wildcard matching in the routes below to handle slashes in keys.
  return c.json({
    uploadUrl: `${origin}/api/files/upload/${key}`,
    key,
    publicUrl: `${origin}/api/files/${key}`
  });
});

// PUT /api/files/upload/* - Upload file content to R2
fileRoutes.put('/upload/*', async (c) => {
  // Extract key from the path, removing '/upload/' prefix
  const path = c.req.path; // e.g. /api/files/upload/user/file.jpg
  // We need to be careful about the mount point. 
  // If mounted at /api/files, c.req.path in sub-router might be /upload/user/file.jpg or full path.
  // Hono sub-app routing can be tricky with c.req.path.
  // Let's rely on string manipulation relative to known structure.
  
  // A safer way in Hono for wildcards is using named wildcards if supported or just parsing c.req.path
  // If fileRoutes is mounted at /api/files
  // Request to /api/files/upload/a/b/c
  // We want 'a/b/c'
  
  // Let's grab the full URL and parse it to be safe
  const url = new URL(c.req.url);
  const match = url.pathname.match(/\/api\/files\/upload\/(.+)/);
  if (!match) return c.json({ error: 'Invalid upload path' }, 400);
  
  const key = match[1]; // The part after /upload/
  
  // Try to get body from various sources
  let body = c.req.body; 
  if (!body) {
    // Fallback: try raw request body
    body = c.req.raw.body;
  }

  if (!body) {
      // Last resort: check content-length
      const length = c.req.header('content-length');
      return c.json({ 
          error: 'No file content provided', 
          details: { 
              contentLength: length,
              contentType: c.req.header('content-type')
          }
      }, 400);
  }

  try {
    // R2 put accepts ReadableStream | ArrayBuffer | string
    await c.env.MEDIA.put(key, body);
    return c.json({ message: 'File uploaded successfully', key });
  } catch (e: any) {
    return c.json({ error: `Upload failed: ${e.message}` }, 500);
  }
});

// GET /api/files/* - Get file info
fileRoutes.get('/*', async (c) => {
  // Avoid matching /upload-url again if it falls through (though specific routes usually take precedence)
  // But /upload-url is defined above, so it should be hit first.
  
  // Parse key from URL
  const url = new URL(c.req.url);
  // Match /api/files/(.+) but NOT /api/files/upload/
  // Actually, since we have specific routes above, this catch-all should work for download.
  const match = url.pathname.match(/\/api\/files\/(.+)/);
  if (!match) return c.json({ error: 'Invalid file path' }, 400);
  
  const key = match[1];
  if (key.startsWith('upload/')) {
      // This technically shouldn't happen if the PUT matches, but for GET requests to /upload/...
      return c.json({ error: 'Invalid method for upload path' }, 405);
  }

  const object = await c.env.MEDIA.get(key);

  if (!object) return c.json({ error: 'File not found' }, 404);

  const headers = new Headers();
  object.writeHttpMetadata(headers);
  headers.set('etag', object.httpEtag);

  return new Response(object.body, { headers });
});
