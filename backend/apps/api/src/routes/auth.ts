import { Hono } from 'hono';
import { SignJWT } from 'jose';
import * as bcrypt from 'bcryptjs';
import { Bindings, Variables } from '../types';

export const authRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const JWT_ALGO = 'HS256';

// --- OAuth Helpers ---

async function getGoogleUser(code: string, clientId: string, clientSecret: string, redirectUri: string) {
  const tokenParams = new URLSearchParams({
    code,
    client_id: clientId,
    client_secret: clientSecret,
    redirect_uri: redirectUri,
    grant_type: 'authorization_code',
  });

  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: tokenParams,
  });

  const tokenData: any = await tokenRes.json();
  if (!tokenData.access_token) throw new Error('Failed to get Google access token');

  const userRes = await fetch('https://www.googleapis.com/oauth2/v2/userinfo', {
    headers: { Authorization: `Bearer ${tokenData.access_token}` },
  });

  return userRes.json();
}

async function getGithubUser(code: string, clientId: string, clientSecret: string) {
  const tokenParams = new URLSearchParams({
    code,
    client_id: clientId,
    client_secret: clientSecret,
  });

  const tokenRes = await fetch('https://github.com/login/oauth/access_token', {
    method: 'POST',
    headers: { Accept: 'application/json' },
    body: tokenParams,
  });

  const tokenData: any = await tokenRes.json();
  if (!tokenData.access_token) throw new Error('Failed to get GitHub access token');

  const userRes = await fetch('https://api.github.com/user', {
    headers: { Authorization: `Bearer ${tokenData.access_token}` },
  });

  const userData: any = await userRes.json();
  
  // GitHub email might be private, fetch it separately if needed
  if (!userData.email) {
      const emailRes = await fetch('https://api.github.com/user/emails', {
        headers: { Authorization: `Bearer ${tokenData.access_token}` },
      });
      const emails: any = await emailRes.json();
      const primary = emails.find((e: any) => e.primary && e.verified);
      userData.email = primary ? primary.email : null;
  }
  
  return userData;
}

// --- Routes ---

authRoutes.get('/google', async (c) => {
  const redirectUri = c.req.query('redirect_uri');
  if (!redirectUri) return c.json({ error: 'Missing redirect_uri' }, 400);

  const clientId = c.env.GOOGLE_CLIENT_ID;
  const scope = 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email';
  
  const url = `https://accounts.google.com/o/oauth2/v2/auth?client_id=${clientId}&redirect_uri=${encodeURIComponent(redirectUri)}&response_type=code&scope=${encodeURIComponent(scope)}`;
  
  return c.redirect(url);
});

authRoutes.get('/google/callback', async (c) => {
    // This endpoint might be hit by the frontend forwarding the code, 
    // OR the frontend handles the callback and sends the code here.
    // Based on `startOAuth` in frontend, it opens a URL.
    // The redirect_uri provided to Google must match what's configured in Google Console.
    // If the frontend handles the callback (e.g. deep link), it will extract the code.
    // BUT the standard flow usually involves the backend exchanging the code.
    
    // Let's assume the frontend redirects to this backend endpoint for the callback?
    // Looking at frontend code: `Endpoints.oauthCallback` seems to be a frontend route '/oauth/callback'.
    // So the provider redirects to the FRONTEND.
    // The frontend then needs to exchange the code for a session.
    
    // Wait, the frontend `startOAuth` uses `Endpoints.googleAuthStart` as the initial URL.
    // And passes `redirect_uri` as the frontend callback page.
    // Google will redirect the browser to `redirect_uri` (Frontend) with `?code=...`.
    // The Frontend then needs to call an API to exchange that code.
    
    // We need a POST /api/auth/google/exchange endpoint.
    return c.json({error: 'Use POST /api/auth/google/exchange'}, 405);
});

authRoutes.post('/google/exchange', async (c) => {
    const { code, redirect_uri } = await c.req.json();
    
    try {
        const googleUser: any = await getGoogleUser(code, c.env.GOOGLE_CLIENT_ID, c.env.GOOGLE_CLIENT_SECRET, redirect_uri);
        
        // Find or Create User
        const email = googleUser.email;
        const googleId = googleUser.id;
        const name = googleUser.name;
        const picture = googleUser.picture;
        
        // Logic to find/create user similar to register but trusting Google
        // For now, let's implement a simple version
        let user: any = await c.env.DB.prepare('SELECT * FROM users WHERE email = ?').bind(email).first();
        
        if (!user) {
             // Create user
             const id = crypto.randomUUID();
             // We don't have a password, so password_hash is null
             // We need a username.
             let username = email.split('@')[0];
             // Ensure unique username (simple check)
             const existing = await c.env.DB.prepare('SELECT 1 FROM users WHERE username = ?').bind(username).first();
             if (existing) username = `${username}_${id.substring(0, 4)}`;
             
             await c.env.DB.prepare(
                'INSERT INTO users (id, username, email, avatar_url, is_email_verified) VALUES (?, ?, ?, ?, 1)'
             ).bind(id, username, email, picture).run();
             
             // Also link Account table if we were using it properly
             await c.env.DB.prepare(
                'INSERT INTO Account (id, user_id, provider, provider_account_id, created_at, updated_at) VALUES (?, ?, ?, ?, datetime("now"), datetime("now"))'
             ).bind(crypto.randomUUID(), id, 'google', googleId).run();
             
             user = { id, username, email };
        } else {
            // Check if account link exists, if not create it
             const account = await c.env.DB.prepare('SELECT * FROM Account WHERE provider = ? AND provider_account_id = ?').bind('google', googleId).first();
             if (!account) {
                 await c.env.DB.prepare(
                    'INSERT INTO Account (id, user_id, provider, provider_account_id, created_at, updated_at) VALUES (?, ?, ?, ?, datetime("now"), datetime("now"))'
                 ).bind(crypto.randomUUID(), user.id, 'google', googleId).run();
             }
        }
        
        // Generate Token
        const secret = new TextEncoder().encode(c.env.JWT_SECRET || 'fallback_secret');
        const token = await new SignJWT({ sub: user.id, username: user.username })
          .setProtectedHeader({ alg: JWT_ALGO })
          .setIssuedAt()
          .setExpirationTime('24h')
          .sign(secret);
          
        return c.json({ token, user: { id: user.id, username: user.username, email: user.email } });
        
    } catch (e: any) {
        return c.json({ error: e.message }, 500);
    }
});


authRoutes.get('/github', async (c) => {
  const redirectUri = c.req.query('redirect_uri'); // Not strictly used by GitHub in the same way for all flows, but good to have context
  
  const clientId = c.env.GITHUB_CLIENT_ID;
  const url = `https://github.com/login/oauth/authorize?client_id=${clientId}&scope=user:email`;
  
  return c.redirect(url);
});

authRoutes.post('/github/exchange', async (c) => {
    const { code } = await c.req.json();
    
    try {
        const githubUser: any = await getGithubUser(code, c.env.GITHUB_CLIENT_ID, c.env.GITHUB_CLIENT_SECRET);
        
        const email = githubUser.email;
        const githubId = String(githubUser.id);
        const login = githubUser.login;
        const avatarUrl = githubUser.avatar_url;
        
        if (!email) return c.json({ error: 'No public email found on GitHub account' }, 400);

        let user: any = await c.env.DB.prepare('SELECT * FROM users WHERE email = ?').bind(email).first();
        
        if (!user) {
             const id = crypto.randomUUID();
             // Check username uniqueness
             let username = login;
             const existing = await c.env.DB.prepare('SELECT 1 FROM users WHERE username = ?').bind(username).first();
             if (existing) username = `${username}_${id.substring(0, 4)}`;
             
             await c.env.DB.prepare(
                'INSERT INTO users (id, username, email, avatar_url, is_email_verified) VALUES (?, ?, ?, ?, 1)'
             ).bind(id, username, email, avatarUrl).run();
             
             await c.env.DB.prepare(
                'INSERT INTO Account (id, user_id, provider, provider_account_id, created_at, updated_at) VALUES (?, ?, ?, ?, datetime("now"), datetime("now"))'
             ).bind(crypto.randomUUID(), id, 'github', githubId).run();
             
             user = { id, username, email };
        } else {
             const account = await c.env.DB.prepare('SELECT * FROM Account WHERE provider = ? AND provider_account_id = ?').bind('github', githubId).first();
             if (!account) {
                 await c.env.DB.prepare(
                    'INSERT INTO Account (id, user_id, provider, provider_account_id, created_at, updated_at) VALUES (?, ?, ?, ?, datetime("now"), datetime("now"))'
                 ).bind(crypto.randomUUID(), user.id, 'github', githubId).run();
             }
        }
        
        const secret = new TextEncoder().encode(c.env.JWT_SECRET || 'fallback_secret');
        const token = await new SignJWT({ sub: user.id, username: user.username })
          .setProtectedHeader({ alg: JWT_ALGO })
          .setIssuedAt()
          .setExpirationTime('24h')
          .sign(secret);
          
        return c.json({ token, user: { id: user.id, username: user.username, email: user.email } });

    } catch (e: any) {
        return c.json({ error: e.message }, 500);
    }
});


authRoutes.post('/register', async (c) => {
  const { username, email, password } = await c.req.json();

  if (!username || !password) {
    return c.json({ error: 'Missing required fields' }, 400);
  }

  try {
    // Check if user exists
    const existingUser = await c.env.DB.prepare(
      'SELECT id FROM users WHERE username = ?'
    ).bind(username).first();

    if (existingUser) {
      return c.json({ error: 'User already exists' }, 409);
    }

    const id = crypto.randomUUID();
    const passwordHash = await bcrypt.hash(password, 10);
    // Use email if provided, otherwise use a placeholder
    const userEmail = email || `${username}@magna-coders.local`;

    await c.env.DB.prepare(
      'INSERT INTO users (id, username, email, password_hash) VALUES (?, ?, ?, ?)'
    ).bind(id, username, userEmail, passwordHash).run();

    // Generate JWT token
    const secret = new TextEncoder().encode(c.env.JWT_SECRET || 'fallback_secret');
    const token = await new SignJWT({ sub: id, username: username })
      .setProtectedHeader({ alg: JWT_ALGO })
      .setIssuedAt()
      .setExpirationTime('24h')
      .sign(secret);

    return c.json({
      token,
      user: { id, username, email: userEmail }
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
        avatar_url: user.avatar_url,
        cover_photo_url: user.cover_photo_url
      }
    });

  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
