const todoService = require('../services/todo/todo.service');
const logger = require('../utils/logger');

const getTodoStatus = async (req, res, next) => {
  const reqId = req.id || 'N/A';
  try {
    logger.info(`[${reqId}] [TodoController] Todo status requested`);
    const status = await todoService.getStatus(reqId);
    res.status(200).json(status);
  } catch (error) {
    logger.error(`[${reqId}] [TodoController] Error fetching todo status:`, error.message);
    next(error);
  }
};

module.exports = {
  getTodoStatus,
};
