const env = require('./env');

const geminiConfig = {
  apiKey: env.GEMINI_API_KEY,
  defaultModel: 'gemini-3.6-flash',
};

module.exports = geminiConfig;
