const logger = require('../utils/logger');

const getHealth = (req, res) => {
  const reqId = req.id || 'N/A';
  logger.info(`[${reqId}] [HealthController] Health check requested`);
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'nexa-backend',
  });
};

module.exports = {
  getHealth,
};
