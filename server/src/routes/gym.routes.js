const express = require('express');
const { getGymStatus } = require('../controllers/gym.controller');

const router = express.Router();

router.get('/', getGymStatus);

module.exports = router;
