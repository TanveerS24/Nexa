const bcrypt = require('bcryptjs');
const env = require('../../config/env');
const logger = require('../../utils/logger');
const { supabase, supabaseAdmin } = require('../../config/supabase');

class EmailService {
  constructor() {
    this.serviceId = env.EMAILJS_SERVICE_ID;
    this.templateId = env.EMAILJS_TEMPLATE_ID;
    this.publicKey = env.EMAILJS_PUBLIC_KEY;
    this.privateKey = env.EMAILJS_PRIVATE_KEY;
    this.apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';
    
    // In-memory fallback OTP storage: email -> { hash, expiresAt }
    this.otpStore = new Map();
  }

  /**
   * Check if EmailJS keys are present and valid
   */
  isConfigured() {
    return Boolean(
      this.serviceId &&
      this.templateId &&
      this.publicKey &&
      !this.serviceId.includes('your_') &&
      !this.templateId.includes('your_') &&
      !this.publicKey.includes('your_')
    );
  }

  /**
   * Send an email using EmailJS REST API
   * @param {Object} params
   * @param {string} params.toEmail
   * @param {Object} params.templateParams
   * @param {string} [params.templateId]
   * @param {string} [params.reqId]
   * @returns {Promise<{ success: boolean, simulated?: boolean, message?: string }>}
   */
  async sendEmail({ toEmail, templateParams = {}, templateId = null, reqId = 'N/A' }) {
    const activeTemplateId = templateId || this.templateId;

    if (!this.isConfigured()) {
      logger.info(
        `[${reqId}] [EmailService] EmailJS not configured with real credentials. Simulating email delivery to: ${toEmail}. Params:`,
        templateParams
      );
      return {
        success: true,
        simulated: true,
        message: 'Email simulated (EmailJS credentials not configured)',
      };
    }

    try {
      logger.info(`[${reqId}] [EmailService] Sending email to "${toEmail}" using template "${activeTemplateId}" via EmailJS API...`);
      const payload = {
        service_id: this.serviceId,
        template_id: activeTemplateId,
        user_id: this.publicKey,
        template_params: {
          to_email: toEmail,
          email: toEmail,
          app_name: 'Nexa',
          ...templateParams,
        },
      };

      if (this.privateKey) {
        payload.accessToken = this.privateKey;
      }

      const startTime = Date.now();
      const response = await fetch(this.apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: JSON.stringify(payload),
      });
      const durationMs = Date.now() - startTime;

      if (response.ok) {
        logger.info(`[${reqId}] [EmailService] Email successfully delivered to ${toEmail} (took ${durationMs}ms)`);
        return { success: true };
      }

      const errorText = await response.text();
      logger.error(`[${reqId}] [EmailService] Failed to send email to ${toEmail}. Status: ${response.status}. Response: ${errorText}`);
      return {
        success: false,
        error: `EmailJS responded with status ${response.status}: ${errorText}`,
      };
    } catch (err) {
      logger.error(`[${reqId}] [EmailService] Exception while sending email to ${toEmail}:`, err);
      return {
        success: false,
        error: err.message,
      };
    }
  }

  /**
   * Generate a 6-digit OTP, hash with bcrypt, and store in DB (with in-memory fallback)
   * @param {string} email
   * @param {string} reqId
   * @returns {Promise<string>} 6-digit plain OTP
   */
  async generateAndSaveOtp(email, reqId = 'N/A') {
    const normalizedEmail = email.trim().toLowerCase();
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const saltRounds = 10;
    const otpHash = await bcrypt.hash(otp, saltRounds);
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes from now

    logger.debug(`[${reqId}] [EmailService] Generated 6-digit OTP for ${normalizedEmail}. Hashing with bcrypt...`);

    // Store in DB (Supabase public.otps table)
    const dbClient = supabaseAdmin || supabase;
    let storedInDb = false;

    if (dbClient) {
      try {
        // Clear any prior OTPs for this email
        await dbClient.from('otps').delete().eq('email', normalizedEmail);

        const { error: dbError } = await dbClient.from('otps').insert({
          email: normalizedEmail,
          otp_hash: otpHash,
          expires_at: expiresAt.toISOString(),
        });

        if (dbError) {
          logger.warn(`[${reqId}] [EmailService] Failed to insert OTP in DB: ${dbError.message}. Using in-memory fallback.`);
        } else {
          storedInDb = true;
          logger.info(`[${reqId}] [EmailService] Bcrypt-hashed OTP successfully saved to database for ${normalizedEmail}`);
        }
      } catch (dbEx) {
        logger.warn(`[${reqId}] [EmailService] Exception writing OTP to DB: ${dbEx.message}. Using in-memory fallback.`);
      }
    }

    // Always maintain in-memory fallback for resilient local development
    this.otpStore.set(normalizedEmail, {
      hash: otpHash,
      expiresAt: expiresAt.getTime(),
    });

    logger.debug(`[${reqId}] [EmailService] OTP store updated (DB: ${storedInDb ? 'Yes' : 'No'}, MemoryStoreSize: ${this.otpStore.size})`);
    return otp;
  }

  /**
   * Verify an OTP for a given email using bcrypt.compare
   * @param {string} email
   * @param {string} enteredOtp
   * @param {string} reqId
   * @returns {Promise<boolean>}
   */
  async verifyOtp(email, enteredOtp, reqId = 'N/A') {
    const normalizedEmail = email.trim().toLowerCase();
    const cleanOtp = (enteredOtp || '').toString().trim();
    const nowIso = new Date().toISOString();

    logger.info(`[${reqId}] [EmailService] Verifying OTP for ${normalizedEmail} against bcrypt hash...`);

    const dbClient = supabaseAdmin || supabase;
    let foundHash = null;
    let fromDb = false;

    // 1. Check Supabase DB first
    if (dbClient) {
      try {
        const { data, error } = await dbClient
          .from('otps')
          .select('*')
          .eq('email', normalizedEmail)
          .gt('expires_at', nowIso)
          .order('created_at', { ascending: false })
          .limit(1)
          .maybeSingle();

        if (error) {
          logger.warn(`[${reqId}] [EmailService] DB error querying OTP: ${error.message}`);
        } else if (data && data.otp_hash) {
          foundHash = data.otp_hash;
          fromDb = true;
          logger.debug(`[${reqId}] [EmailService] Retrieved active OTP record from DB for ${normalizedEmail}`);
        }
      } catch (err) {
        logger.warn(`[${reqId}] [EmailService] Exception querying DB for OTP: ${err.message}`);
      }
    }

    // 2. Fallback to in-memory store if not in DB
    if (!foundHash) {
      const memoryRecord = this.otpStore.get(normalizedEmail);
      if (memoryRecord) {
        if (Date.now() > memoryRecord.expiresAt) {
          logger.warn(`[${reqId}] [EmailService] In-memory OTP for ${normalizedEmail} has expired.`);
          this.otpStore.delete(normalizedEmail);
        } else {
          foundHash = memoryRecord.hash;
          logger.debug(`[${reqId}] [EmailService] Retrieved active OTP record from in-memory store for ${normalizedEmail}`);
        }
      }
    }

    if (!foundHash) {
      logger.warn(`[${reqId}] [EmailService] No active or unexpired OTP found for ${normalizedEmail}`);
      return false;
    }

    // 3. Compare using bcrypt
    const isMatch = await bcrypt.compare(cleanOtp, foundHash);

    if (isMatch) {
      logger.info(`[${reqId}] [EmailService] Bcrypt verification succeeded for ${normalizedEmail}. Cleaning up OTP...`);
      // Delete from DB to prevent replay
      if (dbClient && fromDb) {
        try {
          await dbClient.from('otps').delete().eq('email', normalizedEmail);
        } catch (delErr) {
          logger.warn(`[${reqId}] [EmailService] Failed to delete used OTP from DB: ${delErr.message}`);
        }
      }
      this.otpStore.delete(normalizedEmail);
      return true;
    }

    logger.warn(`[${reqId}] [EmailService] Bcrypt verification failed: Invalid OTP entered for ${normalizedEmail}`);
    return false;
  }

  /**
   * Generate and send OTP email to a user
   * @param {Object} params
   * @param {string} params.toEmail
   * @param {string} [params.userName]
   * @param {string} [params.reqId]
   * @returns {Promise<{ success: boolean, simulated?: boolean, otpCode?: string }>}
   */
  async sendOtpEmail({ toEmail, userName = 'User', reqId = 'N/A' }) {
    const otpCode = await this.generateAndSaveOtp(toEmail, reqId);

    const result = await this.sendEmail({
      toEmail,
      reqId,
      templateParams: {
        to_name: userName,
        otp_code: otpCode,
        passcode: otpCode,
        message: `Your Nexa verification code is: ${otpCode}. It expires in 10 minutes.`,
      },
    });

    return {
      ...result,
      otpCode: (process.env.NODE_ENV !== 'production' || result.simulated) ? otpCode : undefined,
    };
  }

  /**
   * Send a welcome email to a new user
   * @param {Object} params
   * @param {string} params.toEmail
   * @param {string} [params.userName]
   * @param {string} [params.reqId]
   * @returns {Promise<{ success: boolean }>}
   */
  async sendWelcomeEmail({ toEmail, userName = 'User', reqId = 'N/A' }) {
    return this.sendEmail({
      toEmail,
      reqId,
      templateParams: {
        to_name: userName,
        message: `Welcome to Nexa, ${userName}! Your account is now active.`,
      },
    });
  }
}

module.exports = new EmailService();
