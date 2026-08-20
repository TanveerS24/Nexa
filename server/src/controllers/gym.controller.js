const gymService = require('../services/gym/gym.service');

const getGymStatus = async (req, res, next) => {
  try {
    const status = await gymService.getStatus();
    res.status(200).json(status);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getGymStatus,
};
