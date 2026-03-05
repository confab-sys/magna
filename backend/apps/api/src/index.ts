import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { Bindings, Variables } from './types';
import { authRoutes } from './routes/auth';
import { postRoutes } from './routes/posts';
import { projectRoutes } from './routes/projects';
import { jobRoutes } from './routes/jobs';
import { userRoutes } from './routes/users';
import { coinRoutes } from './routes/coins';
import { chatRoutes } from './routes/chat';
import { notificationRoutes } from './routes/notifications';
import { fileRoutes } from './routes/files';
import { schoolRoutes } from './routes/school';
import { podcastRoutes } from './routes/podcasts';
import { contractRoutes } from './routes/contracts';
import { aiRoutes } from './routes/ai';
import { commentRoutes } from './routes/comments';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// Middleware
app.use('*', cors());

// Routes
app.get('/', (c) => c.text('Magna API is running!'));
app.get('/health', (c) => c.json({ status: 'ok' }));

app.route('/api/auth', authRoutes);
app.route('/api/posts', postRoutes);
app.route('/api/projects', projectRoutes);
app.route('/api/jobs', jobRoutes);
app.route('/api/users', userRoutes);
app.route('/api/coins', coinRoutes);
app.route('/api/chat', chatRoutes);
app.route('/api/notifications', notificationRoutes);
app.route('/api/files', fileRoutes);
app.route('/api/courses', schoolRoutes);
app.route('/api/podcasts', podcastRoutes);
app.route('/api/contracts', contractRoutes);
app.route('/api/ai', aiRoutes);
app.route('/api/comments', commentRoutes);

export default app;
