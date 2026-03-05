import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const coinRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/coins/balance - Get current user balance
coinRoutes.get('/balance', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const wallet = await c.env.DB.prepare('SELECT balance FROM coin_wallets WHERE user_id = ?').bind(userId).first();
    if (!wallet) {
      // Create wallet if doesn't exist
      const id = crypto.randomUUID();
      await c.env.DB.prepare('INSERT INTO coin_wallets (id, user_id, balance) VALUES (?, ?, 0.00)').bind(id, userId).run();
      return c.json({ balance: 0.00 });
    }
    return c.json({ balance: (wallet as any).balance });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/coins/transactions - Get transaction history
coinRoutes.get('/transactions', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const transactions = await c.env.DB.prepare(`
      SELECT * FROM coin_transactions 
      WHERE user_id = ? 
      ORDER BY created_at DESC 
      LIMIT 50
    `).bind(userId).all();
    return c.json({ transactions: transactions.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/coins/transfer - Transfer coins (internal)
coinRoutes.post('/transfer', authMiddleware, async (c) => {
  const senderId = c.get('userId');
  const body = await c.req.json();
  const { receiverId, amount, description } = body;

  if (amount <= 0) return c.json({ error: 'Amount must be positive' }, 400);

  try {
    // Check sender balance
    const senderWallet: any = await c.env.DB.prepare('SELECT balance FROM coin_wallets WHERE user_id = ?').bind(senderId).first();
    if (!senderWallet || senderWallet.balance < amount) {
      return c.json({ error: 'Insufficient balance' }, 400);
    }

    // Atomic transaction logic for D1
    // We execute both updates in a single batch
    await c.env.DB.batch([
      c.env.DB.prepare('UPDATE coin_wallets SET balance = balance - ? WHERE user_id = ?').bind(amount, senderId),
      c.env.DB.prepare('UPDATE coin_wallets SET balance = balance + ? WHERE user_id = ?').bind(amount, receiverId),
      c.env.DB.prepare(`
        INSERT INTO coin_transactions (id, user_id, type, amount, direction, status, description)
        VALUES (?, ?, 'TRANSFER', ?, 'OUT', 'COMPLETED', ?)
      `).bind(crypto.randomUUID(), senderId, amount, description || 'Transfer to ' + receiverId),
      c.env.DB.prepare(`
        INSERT INTO coin_transactions (id, user_id, type, amount, direction, status, description)
        VALUES (?, ?, 'TRANSFER', ?, 'IN', 'COMPLETED', ?)
      `).bind(crypto.randomUUID(), receiverId, amount, description || 'Transfer from ' + senderId)
    ]);

    return c.json({ message: 'Transfer successful' });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
