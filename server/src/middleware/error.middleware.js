const logger = require('../utils/logger');

const errorHandler = (err, req, res, next) => {
  const reqId = req.id || 'N/A';
  const statusCode = err.statusCode || err.status || 500;

  logger.error(`[${reqId}] [ErrorHandler] Status ${statusCode} on ${req.method} ${req.originalUrl || req.url}:`, {
    errorName: err.name || 'InternalServerError',
    message: err.message,
    stack: err.stack,
    body: logger.sanitize(req.body),
    params: req.params,
    query: req.query,
  });

  res.status(statusCode).json({
    error: err.name || 'InternalServerError',
    message: err.message || 'An unexpected error occurred',
    requestId: reqId,
    ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }),
  });
};

const notFoundHandler = (req, res) => {
  const reqId = req.id || 'N/A';
  logger.warn(`[${reqId}] [NotFoundHandler] 404 Not Found: Cannot ${req.method} ${req.originalUrl || req.url}`);

  res.status(404).json({
    error: 'NotFound',
    message: `Cannot ${req.method} ${req.originalUrl || req.url}`,
    requestId: reqId,
  });
};

module.exports = {
  errorHandler,
  notFoundHandler,
};
