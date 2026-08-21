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
   * @param {string} [options.reqId]
   * @returns {Promise<string>} Generated text
   */
  async generateContent(prompt, options = {}) {
    const reqId = options.reqId || 'N/A';
    const modelName = options.model || this.defaultModel;

    logger.info(`[${reqId}] [GeminiService] Requesting AI completion with model "${modelName}" (Prompt length: ${prompt ? prompt.length : 0} chars)`);

    if (!this.isConfigured()) {
      logger.error(`[${reqId}] [GeminiService] Generation failed: GEMINI_API_KEY is not configured.`);
      throw new Error('GEMINI_API_KEY is not configured on the server.');
    }

    const startTime = Date.now();
    try {
      const model = this.client.getGenerativeModel({
        model: modelName,
        generationConfig: {
          ...geminiConfig.generationConfig,
          ...(options.generationConfig || {}),
        },
      });

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();
      const durationMs = Date.now() - startTime;

      logger.info(`[${reqId}] [GeminiService] Gemini generated response in ${durationMs}ms (Response length: ${text.length} chars)`);
      return text;
    } catch (error) {
      const durationMs = Date.now() - startTime;
      logger.error(`[${reqId}] [GeminiService] Gemini generation failed after ${durationMs}ms:`, error.message);
      throw error;
    }
  }
}

module.exports = new GeminiService();
