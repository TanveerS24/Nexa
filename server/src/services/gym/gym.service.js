const logger = require('../../utils/logger');

class GymService {
  /**
   * Minimal Gym service placeholder for modular architecture
   */
  async getStatus() {
    logger.info('GymService: getStatus invoked');
    return {
      module: 'gym',
      status: 'ready',
      version: '1.0.0',
    };
  }
}

module.exports = new GymService();
