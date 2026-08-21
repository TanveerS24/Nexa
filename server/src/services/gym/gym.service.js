const logger = require('../../utils/logger');

class GymService {
  /**
   * Minimal Gym service placeholder for modular architecture
   */
  async getStatus(reqId = 'N/A') {
    logger.info(`[${reqId}] [GymService] getStatus invoked`);
    return {
      module: 'gym',
      status: 'ready',
      version: '1.0.0',
    };
  }
}

module.exports = new GymService();
