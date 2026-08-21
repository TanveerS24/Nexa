const { supabase, supabaseAdmin } = require('../../config/supabase');
const emailService = require('../email/email.service');
const logger = require('../../utils/logger');

class AuthService {
  /**
   * Calculate age based on Date of Birth
   * @param {string|Date} dobInput
   * @returns {number|null}
   */
  calculateAge(dobInput) {
    if (!dobInput) return null;
    const dob = new Date(dobInput);
    if (isNaN(dob.getTime())) {
      logger.warn(`[AuthService] Invalid date provided for age calculation: "${dobInput}"`);
      return null;
    }

    const today = new Date();
    let age = today.getFullYear() - dob.getFullYear();
    const monthDiff = today.getMonth() - dob.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dob.getDate())) {
      age--;
    }
    const resultAge = age >= 0 ? age : 0;
    logger.debug(`[AuthService] Calculated age ${resultAge} for DOB: "${dobInput}"`);
    return resultAge;
  }

  /**
   * Format Date to YYYY-MM-DD string
   * @param {string|Date} dobInput
   * @returns {string|null}
   */
  formatDob(dobInput) {
    if (!dobInput) return null;
    const dob = new Date(dobInput);
    if (isNaN(dob.getTime())) return null;
    const year = dob.getFullYear().toString().padStart(4, '0');
    const month = (dob.getMonth() + 1).toString().padStart(2, '0');
    const day = dob.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * Register a new user with Supabase and store profile
   */
  async register({ email, password, displayName, dob, height, weight, sendOtp = false, reqId = 'N/A' }) {
    logger.info(`[${reqId}] [AuthService] Starting user registration for: ${email}`);

    if (!supabase) {
      logger.error(`[${reqId}] [AuthService] Registration aborted: Supabase client is not initialized.`);
      throw new Error('Supabase client is not initialized on server.');
    }

    const calculatedAge = this.calculateAge(dob);
    const dobString = this.formatDob(dob);

    const userMetadata = {
      ...(displayName && { display_name: displayName }),
      ...(dobString && { dob: dobString }),
      ...(calculatedAge !== null && { age: calculatedAge }),
      ...(height !== undefined && height !== null && { height: Number(height) }),
      ...(weight !== undefined && weight !== null && { weight: Number(weight) }),
    };

    logger.debug(`[${reqId}] [AuthService] Registering with Supabase Auth... Metadata:`, userMetadata);

    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: userMetadata,
      },
    });

    if (authError) {
      logger.error(`[${reqId}] [AuthService] Supabase signUp failed for ${email}: ${authError.message} (Status: ${authError.status || 'N/A'})`);
      throw authError;
    }

    logger.info(`[${reqId}] [AuthService] Supabase signUp successful. User ID: ${authData.user?.id || 'N/A'}`);

    let profile = null;
    if (authData.user) {
      logger.debug(`[${reqId}] [AuthService] Saving user profile to database...`);
      profile = await this.saveProfileData({
        userId: authData.user.id,
        displayName,
        dobString,
        calculatedAge,
        height: height !== undefined && height !== null ? Number(height) : null,
        weight: weight !== undefined && weight !== null ? Number(weight) : null,
        reqId,
      });

      // Send OTP or Welcome Email via EmailJS
      if (sendOtp) {
        logger.info(`[${reqId}] [AuthService] Triggering OTP email dispatch to: ${email}`);
        await emailService.sendOtpEmail({
          toEmail: email,
          userName: displayName || 'User',
          reqId,
        });
      } else {
        logger.info(`[${reqId}] [AuthService] Triggering Welcome email dispatch to: ${email}`);
        await emailService.sendWelcomeEmail({
          toEmail: email,
          userName: displayName || 'User',
          reqId,
        });
      }
    }

    logger.info(`[${reqId}] [AuthService] Registration completed successfully for: ${email}`);
    return {
      user: authData.user,
      session: authData.session,
      profile,
      message: 'User registered successfully',
    };
  }

  /**
   * Login user with email & password
   */
  async login({ email, password, reqId = 'N/A' }) {
    logger.info(`[${reqId}] [AuthService] Attempting Supabase signInWithPassword for: ${email}`);

    if (!supabase) {
      logger.error(`[${reqId}] [AuthService] Login aborted: Supabase client is not initialized.`);
      throw new Error('Supabase client is not initialized on server.');
    }

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      logger.warn(`[${reqId}] [AuthService] Supabase login failed for ${email}: ${error.message}`);
      throw error;
    }

    logger.info(`[${reqId}] [AuthService] Supabase login successful for user ID: ${data.user?.id || 'N/A'}`);

    let profile = null;
    if (data.user) {
      logger.debug(`[${reqId}] [AuthService] Fetching profile for logged-in user...`);
      profile = await this.getProfileByUserId(data.user.id, reqId);
    }

    return {
      user: data.user,
      session: data.session,
      profile,
    };
  }

  /**
   * Send OTP code to user's email via EmailJS
   */
  async sendOtp({ email, userName, reqId = 'N/A' }) {
    logger.info(`[${reqId}] [AuthService] Sending OTP code to: ${email}`);
    return await emailService.sendOtpEmail({
      toEmail: email,
      userName: userName || 'User',
      reqId,
    });
  }

  /**
   * Verify an entered OTP code
   */
  async verifyOtp({ email, otp, reqId = 'N/A' }) {
    logger.info(`[${reqId}] [AuthService] Verifying OTP for: ${email}`);
    const isValid = await emailService.verifyOtp(email, otp, reqId);
    logger.info(`[${reqId}] [AuthService] OTP verification result for ${email}: ${isValid ? 'VALID' : 'INVALID'}`);
    return isValid;
  }

  /**
   * Save or update profile in public.profiles table
   */
  async saveProfileData({ userId, displayName, dobString, calculatedAge, height, weight, reqId = 'N/A' }) {
    const dbClient = supabaseAdmin || supabase;
    if (!dbClient) {
      logger.warn(`[${reqId}] [AuthService] Cannot save profile: No Supabase database client configured.`);
      return null;
    }

    try {
      const payload = {
        id: userId,
        updated_at: new Date().toISOString(),
      };
      if (displayName !== undefined && displayName !== null) payload.display_name = displayName;
      if (dobString !== undefined && dobString !== null) payload.dob = dobString;
      if (calculatedAge !== undefined && calculatedAge !== null) payload.age = calculatedAge;
      if (height !== undefined && height !== null) payload.height = height;
      if (weight !== undefined && weight !== null) payload.weight = weight;

      logger.debug(`[${reqId}] [AuthService] Upserting profile into public.profiles:`, payload);

      const { data, error } = await dbClient
        .from('profiles')
        .upsert(payload)
        .select()
        .single();

      if (error) {
        logger.warn(`[${reqId}] [AuthService] Profile upsert warning from Supabase: ${error.message} (Code: ${error.code || 'N/A'})`);
        return payload;
      }
      logger.info(`[${reqId}] [AuthService] Profile saved/updated successfully for user ID: ${userId}`);
      return data;
    } catch (err) {
      logger.error(`[${reqId}] [AuthService] Profile upsert exception for user ID ${userId}:`, err);
      return null;
    }
  }

  /**
   * Fetch profile by user ID
   */
  async getProfileByUserId(userId, reqId = 'N/A') {
    const dbClient = supabaseAdmin || supabase;
    if (!dbClient) {
      logger.warn(`[${reqId}] [AuthService] Cannot fetch profile: No Supabase database client configured.`);
      return null;
    }

    try {
      logger.debug(`[${reqId}] [AuthService] Querying public.profiles for user ID: ${userId}`);
      const { data, error } = await dbClient
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .maybeSingle();

      if (error) {
        logger.warn(`[${reqId}] [AuthService] Profile query error for ${userId}: ${error.message}`);
        return null;
      }
      logger.debug(`[${reqId}] [AuthService] Profile query returned: ${data ? 'Found' : 'Not found'}`);
      return data;
    } catch (err) {
      logger.error(`[${reqId}] [AuthService] Profile fetch exception for user ID ${userId}:`, err);
      return null;
    }
  }

  /**
   * Update profile and user metadata
   */
  async updateProfile(userId, { displayName, dob, height, weight }, reqId = 'N/A') {
    logger.info(`[${reqId}] [AuthService] Updating profile for user ID: ${userId}`);
    const calculatedAge = dob ? this.calculateAge(dob) : undefined;
    const dobString = dob ? this.formatDob(dob) : undefined;

    const profile = await this.saveProfileData({
      userId,
      displayName,
      dobString,
      calculatedAge,
      height: height !== undefined && height !== null ? Number(height) : undefined,
      weight: weight !== undefined && weight !== null ? Number(weight) : undefined,
      reqId,
    });

    return profile;
  }
}

module.exports = new AuthService();
