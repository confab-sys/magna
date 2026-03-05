import { Hono } from 'hono';
import { Bindings, Variables } from '../types';
import { authMiddleware } from '../middleware';

export const contractRoutes = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// GET /api/contracts - List user's contracts
contractRoutes.get('/', authMiddleware, async (c) => {
  const userId = c.get('userId');
  try {
    const contracts = await c.env.DB.prepare(`
      SELECT * FROM contracts 
      WHERE client_id = ? OR developer_id = ? 
      ORDER BY created_at DESC
    `).bind(userId, userId).all();
    return c.json({ contracts: contracts.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// GET /api/contracts/:id - Contract details and milestones
contractRoutes.get('/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const id = c.req.param('id');
  try {
    const contract = await c.env.DB.prepare(`
      SELECT * FROM contracts WHERE id = ? AND (client_id = ? OR developer_id = ?)
    `).bind(id, userId, userId).first();

    if (!contract) return c.json({ error: 'Contract not found' }, 404);

    const milestones = await c.env.DB.prepare(`
      SELECT * FROM milestones WHERE contract_id = ? ORDER BY order_index ASC
    `).bind(id).all();

    return c.json({ contract, milestones: milestones.results });
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});

// POST /api/contracts - Create a draft contract
contractRoutes.post('/', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const { title, description, developer_id, total_amount, milestones } = await c.req.json();

  if (!title || !total_amount) return c.json({ error: 'Title and amount required' }, 400);

  try {
    const contractId = crypto.randomUUID();
    const batch = [
      c.env.DB.prepare(`
        INSERT INTO contracts (id, title, description, client_id, developer_id, total_amount, status)
        VALUES (?, ?, ?, ?, ?, ?, 'DRAFT')
      `).bind(contractId, title, description, userId, developer_id || null, total_amount)
    ];

    if (milestones && Array.isArray(milestones)) {
      milestones.forEach((m, index) => {
        batch.push(
          c.env.DB.prepare(`
            INSERT INTO milestones (id, contract_id, title, amount, order_index, status)
            VALUES (?, ?, ?, ?, ?, 'NOT_STARTED')
          `).bind(crypto.randomUUID(), contractId, m.title, m.amount, index, 'NOT_STARTED')
        );
      });
    }

    await c.env.DB.batch(batch);

    return c.json({ message: 'Contract created', id: contractId }, 201);
  } catch (e: any) {
    return c.json({ error: e.message }, 500);
  }
});
