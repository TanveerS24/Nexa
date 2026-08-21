const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const routes = require('./routes');
const { requestLogger } = require('./middleware/logging.middleware');
const { errorHandler, notFoundHandler } = require('./middleware/error.middleware');

const app = express();

// Security and utility middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Comprehensive request & response logger
app.use(requestLogger);

// API Routes
app.use('/api/v1', routes);

// 404 & Error Handlers
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
