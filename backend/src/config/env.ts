import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(process.cwd(), '.env') });

export const config = {
  port: parseInt(process.env.PORT || '5050', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  databaseUrl: process.env.DATABASE_URL || 'file:./dev.db',
  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET || 'gymio_super_secret_jwt_access_key_2026',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'gymio_super_secret_jwt_refresh_key_2026',
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '1d',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  },
  corsOrigin: process.env.CORS_ORIGIN || '*',
};
