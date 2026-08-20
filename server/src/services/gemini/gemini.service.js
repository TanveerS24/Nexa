const { GoogleGenerativeAI } = require('@google/generative-ai');
const geminiConfig = require('./gemini.config');
const logger = require('../../utils/logger');

class GeminiService {
  constructor() {
    this.apiKey = geminiConfig.apiKey;
    this.defaultModel = geminiConfig.defaultModel;
    this.client = this.apiKey ? new GoogleGenerativeAI(this.apiKey) : null;
  }

  isConfigured() {
    return Boolean(this.apiKey && this.apiKey.trim().length > 0);
  }

  /**
   * Generate content using Gemini API
   * @param {string} prompt - Prompt text to generate from
   * @param {Object} options - Optional generation parameters
   * @returns {Promise<string>} Generated text
   */
  async generateContent(prompt, options = {}) {
    if (!this.isConfigured()) {
      throw new Error('GEMINI_API_KEY is not configured on the server.');
    }

    try {
      const modelName = options.model || this.defaultModel;
      const model = this.client.getGenerativeModel({
        model: modelName,
        generationConfig: {
          ...geminiConfig.generationConfig,
          ...(options.generationConfig || {}),
        },
      });

      const result = await model.generateContent(prompt);
      const response = await result.response;
      return response.text();
    } catch (error) {
      logger.error('Failed to generate content from Gemini:', error.message);
      throw error;
    }
  }
}

module.exports = new GeminiService();
