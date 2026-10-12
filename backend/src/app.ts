import express, { Application } from 'express';
import cors from 'cors';
import morgan from 'morgan';
import { config } from './config/env.js';
import apiRouter from './routes/index.js';
import { notFoundHandler, errorHandler } from './middlewares/error.middleware.js';

export function createApp(): Application {
  const app = express();

  // Middlewares
  app.use(
    cors({
      origin: config.corsOrigin === '*' ? true : config.corsOrigin.split(','),
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
    })
  );

  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  if (config.nodeEnv !== 'test') {
    app.use(morgan('dev'));
  }

  // Welcome Route
  app.get('/', (req, res) => {
    res.json({
      name: 'GYMIO Fitness Marketplace API',
      version: '1.0.0',
      status: 'active',
      endpoints: {
        health: '/api/v1/health',
        auth: {
          signup: 'POST /api/v1/auth/signup',
          login: 'POST /api/v1/auth/login',
          refreshToken: 'POST /api/v1/auth/refresh-token',
          forgotPassword: 'POST /api/v1/auth/forgot-password',
          resetPassword: 'POST /api/v1/auth/reset-password',
          me: 'GET /api/v1/auth/me',
          profile: 'PUT /api/v1/auth/profile',
          changePassword: 'POST /api/v1/auth/change-password',
          logout: 'POST /api/v1/auth/logout',
        },
        gyms: {
          list: 'GET /api/v1/gyms',
          detail: 'GET /api/v1/gyms/:id',
          create: 'POST /api/v1/gyms',
        },
      },
    });
  });

  // Mount API Router under /api/v1
  app.use('/api/v1', apiRouter);

  // 404 & Error Handlers
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
