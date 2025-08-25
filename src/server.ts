/**
 * Import Dependencies
 */
import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import compression from 'compression';
import helmet from 'helmet';

/**
 * Import custom modules
 */
import config from '@/config';
import limiter from '@/lib/express_rate_limit';
import { connectToDatabase, disconnectFromDatabase } from '@/lib/mongoose';
import { logger } from '@/lib/winston';

/**
 * Router
 */
import v1Routes from '@/routes/v1';

/**
 * Types
 */
import type { CorsOptions } from 'cors';

/**
 * Initialise Express Application
 */
const app = express();

// Configure CORS options
const allowed = (process.env.ALLOWED_ORIGINS || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);
const corsOptions: CorsOptions = {
  origin(origin, cb) {
    if (!origin) return cb(null, true); // non-browser or same-origin
    if (config.NODE_ENV === 'development' || allowed.includes(origin))
      return cb(null, true);
    logger.warn(`CORS blocked: ${origin}`);
    cb(new Error(`CORS error: ${origin} not allowed`));
  },
  credentials: true,
};

// Apply CORS middleware
app.use(cors(corsOptions));

// Enable JSON request body parsing
app.use(express.json());

// Enable URL-encoded request body parsing with extended mode
// `extended: true` allows rich objects and arrays via querystring library
app.use(express.urlencoded({ extended: true }));

app.use(cookieParser());

// Enable response compression to reduce payload size and improve performance
app.use(
  compression({
    threshold: 1024, // Only compress responses larger than 1KB
  }),
);

// Use Helmet to enhance security by setting various HTTP headers
app.use(helmet());

// Apply rate limiting middleware to prevent excessive requests and enhance security
app.use(limiter);

// IIFE to start the server
(async () => {
  try {
    await connectToDatabase();

    app.use('/api/v1', v1Routes);

    const PORT = Number(process.env.PORT) || 8080;

    app.listen(PORT, '0.0.0.0', () => {
      logger.info(`API listening on http://0.0.0.0:${PORT}`);
    });
  } catch (error) {
    logger.error('Failed to start the server');
  }
})();

/**
 * Handle server shutdown gracefully by disconnecting from the database.
 *
 * - Attempts to disconnect from the database before shutting down the server.
 * - Logs a success message if the disconnection is successful.
 * - If an error occurs during disconnection, it is logged to the console.
 * - Exits the process with status code `0` (indicating a successful shutdown).
 */
const handleServerShutdown = async () => {
  try {
    await disconnectFromDatabase();

    console.log('Server SHUTDOWN');
    process.exit(0);
  } catch (err) {
    console.log('Error during server shutdown', err);
  }
};

/**
 * Listen for termination signals (`SIGTERM` and `SIGINT`).
 *
 * - `SIGTERM` is typically sent when stopping a process (e.g., `kill` command or container shutdown).
 * - `SIGINT` is triggered when the user interrupts the process (e.g., pressing `Ctrl + C`).
 * - When either signal is received, `handleServerShutdown` is executed to ensure proper cleanup.
 */
process.on('SIGTERM', handleServerShutdown);
process.on('SIGINT', handleServerShutdown);
