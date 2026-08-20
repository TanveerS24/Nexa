const express = require('express');
const { getTodoStatus } = require('../controllers/todo.controller');

const router = express.Router();

router.get('/', getTodoStatus);

module.exports = router;
