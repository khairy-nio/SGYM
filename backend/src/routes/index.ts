import { Router } from 'express';
import authRoutes from './auth.routes.js';
import gymRoutes from './gym.routes.js';
import { sendSuccess } from '../utils/response.js';

const apiRouter = Router();

// Health Check
apiRouter.get('/health', (req, res) => {
  sendSuccess(res, {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'GYMIO Marketplace Backend API',
    version: '1.0.0',
    uptime: process.uptime(),
  }, 'API Service is up and running');
});

// API Routes
apiRouter.use('/auth', authRoutes);
apiRouter.use('/gyms', gymRoutes);

export default apiRouter;
