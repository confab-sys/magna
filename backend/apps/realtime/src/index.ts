import { ChatRoom } from './objects/ChatRoom';
import { ContractEscrow } from './objects/ContractEscrow';

export { ChatRoom, ContractEscrow };

export default {
  async fetch(request: Request, env: any) {
    const url = new URL(request.url);

    // WebSocket endpoint: /ws/:conversationId
    // Example: wss://<realtime-worker>/ws/<conversationId>?token=<jwt>
    const wsMatch = url.pathname.match(/^\/ws\/([^/]+)$/);
    if (wsMatch) {
      const conversationId = wsMatch[1];
      const id = env.CHAT_ROOM.idFromName(conversationId);
      const stub = env.CHAT_ROOM.get(id);
      return stub.fetch(request);
    }

    // Internal broadcast endpoint: /broadcast/:conversationId
    const broadcastMatch = url.pathname.match(/^\/broadcast\/([^/]+)$/);
    if (broadcastMatch) {
      const conversationId = broadcastMatch[1];
      const id = env.CHAT_ROOM.idFromName(conversationId);
      const stub = env.CHAT_ROOM.get(id);
      return stub.fetch(request);
    }

    return new Response('Not found', { status: 404 });
  },
};

