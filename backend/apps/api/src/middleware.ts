import { Context, Next } from 'hono';
import { jwtVerify } from 'jose';
import { Bindings, Variables } from './types';

export const authMiddleware = async (c: Context<{ Bindings: Bindings; Variables: Variables }>, next: Next) => {
  const authHeader = c.req.header('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized' }, 401);
  }

  const token = authHeader.split(' ')[1];
  try {
    const secret = new TextEncoder().encode(c.env.JWT_SECRET || 'fallback_secret');
    const { payload } = await jwtVerify(token, secret);
    c.set('userId', payload.sub as string);
    await next();
  } catch (e) {
    return c.json({ error: 'Invalid token' }, 401);
  }
};

export const adminKeyMiddleware = async (c: Context<{ Bindings: Bindings; Variables: Variables }>, next: Next) => {
  const headerKey = c.req.header('x-admin-key');
  const expected = c.env.REALTIME_INTERNAL_KEY;

  if (!headerKey || !expected || headerKey !== expected) {
    return c.json({ error: 'Forbidden' }, 403);
  }

  await next();
};
