const todoService = require('../services/todo/todo.service');

const getTodoStatus = async (req, res, next) => {
  try {
    const status = await todoService.getStatus();
    res.status(200).json(status);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getTodoStatus,
};
