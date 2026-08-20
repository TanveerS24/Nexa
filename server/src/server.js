const app = require('./app');
const env = require('./config/env');
const logger = require('./utils/logger');

const PORT = env.PORT || 5000;

const server = app.listen(PORT, () => {
  logger.info(`Nexa server running on port ${PORT} in ${env.NODE_ENV} mode`);
});

// Graceful shutdown handling
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    logger.info('Process terminated.');
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received. Shutting down gracefully...');
  server.close(() => {
    logger.info('Process terminated.');
  });
});

module.exports = server;
