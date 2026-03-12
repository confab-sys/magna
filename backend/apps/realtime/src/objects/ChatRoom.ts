export class ChatRoom {
  state: any;
  env: any;
  sessions: Map<any, { userId: string | null }>;
  conversationId: string | null;

  constructor(state: any, env: any) {
    this.state = state;
    this.env = env;
    this.sessions = new Map();
    this.conversationId = null;
  }

  async fetch(request: Request) {
    const upgradeHeader = request.headers.get('Upgrade');
    const url = new URL(request.url);

    // Extract conversationId from either /ws/:id or /broadcast/:id
    const match =
      url.pathname.match(/^\/ws\/([^/]+)$/) || url.pathname.match(/^\/broadcast\/([^/]+)$/);
    this.conversationId = match ? match[1] : this.conversationId;

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
        type: body?.type ?? 'refresh',
        conversationId: this.conversationId,
        payload: body?.payload ?? null,
        timestamp: new Date().toISOString(),
      });

      return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // WebSocketPair exists in the Cloudflare Workers runtime.
    // TypeScript may not know it unless workers types are installed.
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const pair: any = new (globalThis as any).WebSocketPair();
    const [client, server] = Object.values(pair);

    const token = url.searchParams.get('token');
    const userId = await this.verifyJwtAndGetUserId(token);

    if (!userId) {
      return new Response('Unauthorized', { status: 401 });
    }

    if (!this.conversationId) {
      return new Response('Missing conversation', { status: 400 });
    }

    const isMember = await this.env.DB.prepare(
      'SELECT id FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
    )
      .bind(this.conversationId, userId)
      .first();

    if (!isMember) {
      return new Response('Forbidden', { status: 403 });
    }

    await this.handleSession(server, userId);

    return new Response(null, {
      status: 101,
      webSocket: client,
    } as any);
  }

  async handleSession(ws: any, userId: string | null) {
    ws.accept();
    this.sessions.set(ws, { userId });

    ws.addEventListener('message', async (msg) => {
      try {
        const data = JSON.parse(msg.data as string);
        
        if (data.type === 'join') {
          const nextUserId = String(data.userId ?? '').trim();
          if (nextUserId) {
            this.sessions.set(ws, { userId: nextUserId });
          }
        }
      } catch (e) {
        console.error('WebSocket error:', e);
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
    const base64 = input.replace(/-/g, '+').replace(/_/g, '/').padEnd(Math.ceil(input.length / 4) * 4, '=');
    const raw = atob(base64);
    const bytes = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i);
    return bytes;
  }
}
