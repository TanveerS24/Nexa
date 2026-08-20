const express = require('express');
const healthRoutes = require('./health.routes');
const todoRoutes = require('./todo.routes');
const gymRoutes = require('./gym.routes');

const router = express.Router();

router.use('/health', healthRoutes);
router.use('/todo', todoRoutes);
router.use('/gym', gymRoutes);

module.exports = router;
