export class NotificationHub {
  state: any;
  env: any;
  sessions: Map<any, { userId: string | null }>;
  userId: string | null;

  constructor(state: any, env: any) {
    this.state = state;
    this.env = env;
    this.sessions = new Map();
    this.userId = null;
  }

  async fetch(request: Request) {
    const upgradeHeader = request.headers.get('Upgrade');
    const url = new URL(request.url);

    const match = url.pathname.match(/^\/notifications\/([^/]+)$/);
    this.userId = match ? match[1] : this.userId;

    // Internal broadcast call (no websocket upgrade)
    if (!upgradeHeader || upgradeHeader !== 'websocket') {
      const internalKey = request.headers.get('X-Internal-Key') ?? '';
      if (!internalKey || internalKey !== this.env.INTERNAL_KEY) {
        return new Response('Unauthorized', { status: 401 });
      }

      let body: any = null;
      try {
        body = await request.json();
      } catch {
        body = null;
      }

      this.broadcast({
        type: body?.type ?? 'notification.created',
        payload: body?.payload ?? null,
        timestamp: new Date().toISOString(),
      });

      return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // WebSocketPair exists in the Cloudflare Workers runtime.
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const pair: any = new (globalThis as any).WebSocketPair();
    const [client, server] = Object.values(pair);

    const token = url.searchParams.get('token');
    const userIdFromToken = await this.verifyJwtAndGetUserId(token);

    if (!userIdFromToken || !this.userId || userIdFromToken !== this.userId) {
      return new Response('Unauthorized', { status: 401 });
    }

    await this.handleSession(server, userIdFromToken);

    return new Response(null, {
      status: 101,
      webSocket: client,
    } as any);
  }

  async handleSession(ws: any, userId: string | null) {
    ws.accept();
    this.sessions.set(ws, { userId });

    ws.addEventListener('message', async (msg: any) => {
      try {
        const data = JSON.parse(msg.data as string);
        if (data.type === 'ping') {
          ws.send(JSON.stringify({ type: 'pong', timestamp: new Date().toISOString() }));
        }
      } catch (e) {
        console.error('NotificationHub WebSocket error:', e);
      }
    });

    ws.addEventListener('close', () => {
      this.sessions.delete(ws);
    });
  }

  broadcast(message: any) {
    const data = JSON.stringify(message);
    this.sessions.forEach((_, ws) => {
      try {
        ws.send(data);
      } catch (e) {
        this.sessions.delete(ws);
      }
    });
  }

  private async verifyJwtAndGetUserId(token: string | null): Promise<string | null> {
    if (!token) return null;
    try {
      const parts = token.split('.');
      if (parts.length !== 3) return null;

      const [headerB64, payloadB64, sigB64] = parts;
      const data = new TextEncoder().encode(`${headerB64}.${payloadB64}`);
      const sig = this.base64UrlToBytes(sigB64);

      const secret = new TextEncoder().encode(this.env.JWT_SECRET ?? '');
      const key = await crypto.subtle.importKey(
        'raw',
        secret,
        { name: 'HMAC', hash: 'SHA-256' },
        false,
        ['verify'],
      );

      const ok = await crypto.subtle.verify('HMAC', key, sig as any, data as any);
      if (!ok) return null;

      const payloadJson = new TextDecoder().decode(this.base64UrlToBytes(payloadB64));
      const payload = JSON.parse(payloadJson);
      const sub = typeof payload?.sub === 'string' ? payload.sub : null;
      return sub;
    } catch {
      return null;
    }
  }

  private base64UrlToBytes(input: string): Uint8Array {
    const base64 = input
      .replace(/-/g, '+')
      .replace(/_/g, '/')
      .padEnd(Math.ceil(input.length / 4) * 4, '=');
    const raw = atob(base64);
    const bytes = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i);
    return bytes;
  }
}

