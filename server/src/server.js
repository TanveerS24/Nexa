const app = require('./app');
const env = require('./config/env');
const logger = require('./utils/logger');
const { supabase, supabaseAdmin } = require('./config/supabase');
const emailService = require('./services/email/email.service');
const geminiService = require('./services/gemini/gemini.service');

const PORT = env.PORT || 5000;

// Catch unhandled rejections and exceptions
process.on('uncaughtException', (err) => {
  logger.error('CRITICAL: Uncaught Exception thrown:', err);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('CRITICAL: Unhandled Promise Rejection at:', promise, 'reason:', reason);
});

const server = app.listen(PORT, () => {
  logger.info('========================================');
  logger.info(` Nexa Backend Server Started`);
  logger.info(` Port: ${PORT}`);
  logger.info(` Environment: ${env.NODE_ENV}`);
  logger.info(` Supabase Client: ${supabase ? 'Initialized' : 'Not configured'}`);
  logger.info(` Supabase Admin: ${supabaseAdmin ? 'Initialized' : 'Not configured'}`);
  logger.info(` EmailJS: ${emailService.isConfigured() ? 'Configured' : 'Simulated (missing/placeholder keys)'}`);
  logger.info(` Gemini AI: ${geminiService.isConfigured() ? 'Configured' : 'Not configured'}`);
  logger.info('========================================');
});

// Graceful shutdown handling
process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received. Initiating graceful shutdown...');
  server.close(() => {
    logger.info('Server closed. Process terminated.');
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT signal received. Initiating graceful shutdown...');
  server.close(() => {
    logger.info('Server closed. Process terminated.');
  });
});

module.exports = server;
