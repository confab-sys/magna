// npm install node-fetch@2 ws
const fetch = require('node-fetch');
const WebSocket = require('ws');

const API_URL = 'https://magna-coders-api.magna-coders.workers.dev';
const REALTIME_URL = 'https://magna-coders-realtime.magna-coders.workers.dev';

// Alvin (or any test user) credentials
const EMAIL = 'alvin@magna.com';
const PASSWORD = 'password123';

async function login() {
  const res = await fetch(`${API_URL}/api/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: EMAIL, password: PASSWORD }),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Login failed: ${text}`);
  }

  const data = await res.json();
  if (!data.token || !data.user || !data.user.id) {
    throw new Error(`Unexpected login response: ${JSON.stringify(data)}`);
  }

  return { token: data.token, userId: data.user.id };
}

function connectNotificationsWs({ token, userId }) {
  const wsUrl = `${REALTIME_URL.replace('https', 'wss')}/notifications/${userId}?token=${encodeURIComponent(token)}`;
  console.log('Connecting to:', wsUrl);

  const ws = new WebSocket(wsUrl);

  ws.on('open', () => {
    console.log('✅ WebSocket connected');
    // Optional: send a ping message every 30s
    setInterval(() => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({ type: 'ping' }));
      }
    }, 30000);
  });

  ws.on('message', (data) => {
    try {
      const msg = JSON.parse(data.toString());
      console.log('📨 Notification event:', JSON.stringify(msg, null, 2));
    } catch (e) {
      console.log('📨 Raw message:', data.toString());
    }
  });

  ws.on('close', (code, reason) => {
    console.log(`⚠️ WebSocket closed: code=${code} reason=${reason}`);
  });

  ws.on('error', (err) => {
    console.error('❌ WebSocket error:', err.message);
  });
}

(async () => {
  try {
    console.log('Logging in...');
    const auth = await login();
    console.log('Got token & userId:', auth.userId);
    connectNotificationsWs(auth);
  } catch (e) {
    console.error('Setup failed:', e.message);
  }
})();