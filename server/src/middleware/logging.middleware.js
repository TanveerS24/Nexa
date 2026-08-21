const crypto = require('crypto');
const logger = require('../utils/logger');

/**
 * Middleware for end-to-end HTTP request and response logging
 */
const requestLogger = (req, res, next) => {
  // Generate a unique Request ID for tracing
  req.id = crypto.randomUUID ? crypto.randomUUID() : `req-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`;
  res.setHeader('X-Request-Id', req.id);

  const startTime = Date.now();
  const clientIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress || req.ip;
  const userAgent = req.headers['user-agent'] || 'Unknown-Agent';

  // Log incoming request details
  const hasBody = req.body && Object.keys(req.body).length > 0;
  const hasQuery = req.query && Object.keys(req.query).length > 0;
  const hasAuth = Boolean(req.headers.authorization);

  let reqLog = `--> [${req.id}] ${req.method} ${req.originalUrl || req.url} | IP: ${clientIp} | Auth: ${hasAuth ? 'Bearer ***' : 'None'}`;
  if (hasQuery) {
    reqLog += ` | Query: ${JSON.stringify(req.query)}`;
  }
  if (hasBody) {
    reqLog += ` | Body: ${JSON.stringify(logger.sanitize(req.body))}`;
  }

  logger.http(reqLog);

  // Hook into response finish event
  res.on('finish', () => {
    const durationMs = Date.now() - startTime;
    const statusCode = res.statusCode;
    const resLog = `<-- [${req.id}] ${req.method} ${req.originalUrl || req.url} ${statusCode} in ${durationMs}ms (User-Agent: ${userAgent})`;

    if (statusCode >= 500) {
      logger.error(resLog);
    } else if (statusCode >= 400) {
      logger.warn(resLog);
    } else {
      logger.http(resLog);
    }
  });

  next();
};

module.exports = {
  requestLogger,
};
