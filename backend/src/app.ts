import express, { Application } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import { env } from './config/env';
import { errorHandler, notFoundHandler } from './common/middlewares/errorHandler';
import { requestLogger, addRequestId } from './common/middlewares/requestLogger';
import { isDatabaseReady, getDatabaseInfo } from './config/database';
import { setupSwagger } from './config/swagger';

/**
 * Create and configure Express application
 */
export async function createApp(): Promise<Application> {
  const app = express();

  // Security middleware with Swagger UI exception
  app.use(helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"], // Required for Swagger UI
        scriptSrc: ["'self'", "'unsafe-inline'"], // Required for Swagger UI
        imgSrc: ["'self'", "data:", "https:"], // Required for Swagger UI
      },
    },
  }));

  // CORS configuration
  app.use(cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, Postman)
      if (!origin) return callback(null, true);
      
      if (env.CORS_ALLOWED_ORIGINS.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true, // Allow cookies
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }));

  // Body parsing middleware
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));
  app.use(cookieParser());

  // Request tracking
  app.use(addRequestId);
  app.use(requestLogger);

  // Swagger API Documentation (development only by default)
  setupSwagger(app);

  // Health check endpoints
  app.get('/health/live', (_req, res) => {
    res.status(200).json({
      success: true,
      data: {
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
      },
    });
  });

  app.get('/health/ready', (_req, res) => {
    const dbReady = isDatabaseReady();
    const dbInfo = getDatabaseInfo();

    if (!dbReady) {
      return res.status(503).json({
        success: false,
        error: {
          code: 'SERVICE_UNAVAILABLE',
          message: 'Database not ready',
        },
        data: {
          database: dbInfo,
        },
      });
    }

    return res.status(200).json({
      success: true,
      data: {
        status: 'ready',
        timestamp: new Date().toISOString(),
        database: {
          connected: dbInfo.connected,
          name: dbInfo.name,
        },
      },
    });
  });

  // API routes
  app.use('/api/v1/auth', (await import('./routes/auth.routes')).default);
  app.use('/api/v1/dictionary', (await import('./routes/dictionary.routes')).default);
  app.use('/api/v1/categories', (await import('./routes/category.routes')).default);
  app.use('/api/v1/favorites', (await import('./routes/favorites.routes')).default);
  app.use('/api/v1/history', (await import('./routes/history.routes')).default);
  app.use('/api/v1/users', (await import('./routes/user.routes')).default);
  app.use('/api/v1/staff', (await import('./routes/staff.routes')).default);
  app.use('/api/v1/admin', (await import('./routes/admin.routes')).default);

  // 404 handler
  app.use(notFoundHandler);

  // Global error handler (must be last)
  app.use(errorHandler);

  return app;
}
