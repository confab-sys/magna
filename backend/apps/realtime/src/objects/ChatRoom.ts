export class ChatRoom {
  state: DurableObjectState;
  env: any;
  sessions: Map<WebSocket, { userId: string }>;

  constructor(state: DurableObjectState, env: any) {
    this.state = state;
    this.env = env;
    this.sessions = new Map();
  }

  async fetch(request: Request) {
    const upgradeHeader = request.headers.get('Upgrade');
    if (!upgradeHeader || upgradeHeader !== 'websocket') {
      return new Response('Expected Upgrade: websocket', { status: 426 });
    }

    const [client, server] = Object.values(new WebSocketPair());

    await this.handleSession(server);

    return new Response(null, {
      status: 101,
      webSocket: client,
    });
  }

  async handleSession(ws: WebSocket) {
    ws.accept();

    ws.addEventListener('message', async (msg) => {
      try {
        const data = JSON.parse(msg.data as string);
        
        if (data.type === 'chat') {
          // Broadcast to all connected clients
          this.broadcast({
            type: 'message',
            userId: data.userId,
            content: data.content,
            timestamp: new Date().toISOString()
          });

          // Persist to D1
          await this.env.DB.prepare(
            'INSERT INTO messages (id, content, sender_id, conversation_id) VALUES (?, ?, ?, ?)'
          ).bind(crypto.randomUUID(), data.content, data.userId, data.conversationId).run();
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
}
