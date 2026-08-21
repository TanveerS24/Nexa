const gymService = require('../services/gym/gym.service');
const logger = require('../utils/logger');

const getGymStatus = async (req, res, next) => {
  const reqId = req.id || 'N/A';
  try {
    logger.info(`[${reqId}] [GymController] Gym status requested`);
    const status = await gymService.getStatus(reqId);
    res.status(200).json(status);
  } catch (error) {
    logger.error(`[${reqId}] [GymController] Error fetching gym status:`, error.message);
    next(error);
  }
};

module.exports = {
  getGymStatus,
};
