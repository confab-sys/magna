import { Hono } from 'hono';
import { SignJWT } from 'jose';
import * as bcrypt from 'bcryptjs';
import { Bindings, Variables } from '../types';

export const authRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const JWT_ALGO = 'HS256';

authRoutes.post('/register', async (c) => {
  const { username, email, password } = await c.req.json();

  if (!username || !email || !password) {
    return c.json({ error: 'Missing required fields' }, 400);
  }

  try {
    // Check if user exists
    const existingUser = await c.env.DB.prepare(
      'SELECT id FROM users WHERE email = ? OR username = ?'
    ).bind(email, username).first();

    if (existingUser) {
      return c.json({ error: 'User already exists' }, 409);
    }

    const id = crypto.randomUUID();
    const passwordHash = await bcrypt.hash(password, 10);

    await c.env.DB.prepare(
      'INSERT INTO users (id, username, email, password_hash) VALUES (?, ?, ?, ?)'
    ).bind(id, username, email, passwordHash).run();

    return c.json({ 
      message: 'User registered successfully',
      user: { id, username, email }
    }, 201);

  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

authRoutes.post('/login', async (c) => {
  const { email, password } = await c.req.json();

  if (!email || !password) {
    return c.json({ error: 'Missing credentials' }, 400);
  }

  try {
    const user: any = await c.env.DB.prepare(
      'SELECT * FROM users WHERE email = ?'
    ).bind(email).first();

    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return c.json({ error: 'Invalid credentials' }, 401);
    }

    const secret = new TextEncoder().encode(c.env.JWT_SECRET || 'fallback_secret');
    const token = await new SignJWT({ sub: user.id, username: user.username })
      .setProtectedHeader({ alg: JWT_ALGO })
      .setIssuedAt()
      .setExpirationTime('24h')
      .sign(secret);

    return c.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        avatar_url: user.avatar_url
      }
    });

  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
