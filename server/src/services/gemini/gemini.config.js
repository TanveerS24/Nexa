const config = require('../../config/gemini');

module.exports = {
  apiKey: config.apiKey,
  defaultModel: config.defaultModel,
  generationConfig: {
    temperature: 0.7,
    topK: 40,
    topP: 0.95,
    maxOutputTokens: 2048,
  },
};
