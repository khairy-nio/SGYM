import { createApp } from './app.js';
import { config } from './config/env.js';

const app = createApp();

const server = app.listen(config.port, () => {
  console.log(`
  ======================================================
  🚀 GYMIO Marketplace API Server is Running!
  ------------------------------------------------------
  📡 Local:       http://localhost:${config.port}
  🩺 Health:      http://localhost:${config.port}/api/v1/health
  🔐 Auth Base:   http://localhost:${config.port}/api/v1/auth
  🏋️ Gyms Base:   http://localhost:${config.port}/api/v1/gyms
  🌍 Environment: ${config.nodeEnv}
  ======================================================
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});
