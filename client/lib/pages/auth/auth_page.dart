import 'dart:async';
import 'package:flutter/material.dart';
import '../../components/layout/ambient_background.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/api/api_client.dart';
import '../../services/emailjs/emailjs_service.dart';
import '../../services/supabase/auth_service.dart';

class AuthPage extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthPage({super.key, required this.onAuthenticated});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignUp = false;
  bool _isOtpVerificationStep = false;
  bool _isLoading = false;
  bool _isResending = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _infoMessage;

  int _resendCooldown = 0;
  Timer? _resendTimer;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _otpController = TextEditingController();

  DateTime? _selectedDob;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendCooldown = 30;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 1) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _resendCooldown = 0;
        });
      }
    });
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.ambientWarmGlow,
              onPrimary: Colors.black,
              surface: AppColors.backgroundCard,
              onSurface: AppColors.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isSignUp && _selectedDob == null) {
      setState(() {
        _errorMessage = 'Please select your Date of Birth';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();

      if (_isSignUp) {
        // Request 6-digit OTP from Backend API
        final result = await ApiClient.sendOtp(
          email: email,
          userName: name.isNotEmpty ? name : null,
        );

        if (result['success'] == true) {
          _startResendTimer();
          setState(() {
            _isOtpVerificationStep = true;
            _infoMessage = 'A 6-digit verification code has been sent to $email.';
          });
        } else {
          setState(() {
            _errorMessage = result['message']?.toString() ??
                result['error']?.toString() ??
                'Failed to send OTP. Please try again.';
          });
        }
      } else {
        // Direct Sign In via Backend API and Supabase
        final result = await ApiClient.login(
          email: email,
          password: password,
        );

        if (result['success'] == true) {
          try {
            await AuthService.signIn(email: email, password: password);
          } catch (_) {}
          widget.onAuthenticated();
        } else {
          setState(() {
            _errorMessage = result['message']?.toString() ??
                result['error']?.toString() ??
                'Invalid login credentials.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    final token = _otpController.text.trim();
    if (token.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    try {
      // 1. Verify OTP with Backend (validates bcrypt hash in database)
      final verifyRes = await ApiClient.verifyOtp(email: email, otp: token);

      if (verifyRes['success'] != true) {
        setState(() {
          _isLoading = false;
          _errorMessage = verifyRes['message']?.toString() ??
              verifyRes['error']?.toString() ??
              'Invalid or expired OTP code. Please try again.';
        });
        return;
      }

      // 2. Register user with Backend API
      final regRes = await ApiClient.register(
        email: email,
        password: password,
        displayName: name.isNotEmpty ? name : null,
        dob: _selectedDob,
        height: height,
        weight: weight,
      );

      if (regRes['success'] == true) {
        // Sign in on client Supabase instance to establish local session
        try {
          await AuthService.signIn(email: email, password: password);
        } catch (_) {}
        widget.onAuthenticated();
      } else {
        setState(() {
          _errorMessage = regRes['message']?.toString() ??
              regRes['error']?.toString() ??
              'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendOtp() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final name = _nameController.text.trim();

      final res = await ApiClient.sendOtp(
        email: email,
        userName: name.isNotEmpty ? name : null,
      );

      if (res['success'] == true) {
        _startResendTimer();
        if (mounted) {
          setState(() {
            _infoMessage = 'A new 6-digit verification code has been sent!';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = res['message']?.toString() ??
                res['error']?.toString() ??
                'Failed to resend code.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to resend code: ${e.toString().replaceAll('Exception:', '').trim()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isOtpVerificationStep) {
      return _buildOtpScreen();
    }

    int? calculatedAge;
    if (_selectedDob != null) {
      calculatedAge = AuthService.calculateAge(_selectedDob!);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: AmbientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Emblem
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ambientWarmGlow.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.dashboard_customize_outlined,
                      color: AppColors.textWhite,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text('Nexa', style: AppTextStyles.brandTitle.copyWith(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUp ? 'Create your personal space' : 'Welcome back',
                    style: AppTextStyles.greetingSubtitle,
                  ),

                  const SizedBox(height: 28),

                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFFF8B8B), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (_infoMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.ambientWarmGlow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.ambientWarmGlow.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _infoMessage!,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Name Field (Sign Up only)
                  if (_isSignUp) ...[
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Your Name',
                      icon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (_isSignUp && (val == null || val.trim().isEmpty)) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Date of Birth Field & Real-time Age Display
                    InkWell(
                      onTap: _pickDob,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedDob != null
                                ? AppColors.ambientWarmGlow.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cake_outlined,
                              color: AppColors.ambientWarmGlow,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDob != null
                                    ? "${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')} (Age: $calculatedAge)"
                                    : 'Select Date of Birth (DOB)',
                                style: TextStyle(
                                  color: _selectedDob != null
                                      ? AppColors.textWhite
                                      : AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Optional Height & Weight Fields
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heightController,
                            hintText: 'Height (cm) - opt',
                            icon: Icons.height_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _weightController,
                            hintText: 'Weight (kg) - opt',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || !val.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 26),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ambientWarmGlow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              _isSignUp ? 'Sign Up' : 'Sign In',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Toggle Sign Up / Sign In
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                        _errorMessage = null;
                        _infoMessage = null;
                      });
                    },
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign In'
                          : "Don't have an account? Sign Up",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpScreen() {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: AmbientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.ambientWarmGlow.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.ambientWarmGlow,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.ambientWarmGlow,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Enter Verification Code',
                  style: AppTextStyles.promptTitle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit OTP code sent to\n${_emailController.text.trim()}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.greetingSubtitle,
                ),

                const SizedBox(height: 24),

                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFFF8B8B), fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_infoMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.ambientWarmGlow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.ambientWarmGlow.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _infoMessage!,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 6-digit OTP Input
                TextField(
                  controller: _otpController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                      letterSpacing: 12,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.ambientWarmGlow),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.ambientWarmGlow, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ambientWarmGlow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Verify & Complete Registration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resend OTP Action with Cooldown Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    _isResending
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.ambientWarmGlow,
                            ),
                          )
                        : TextButton(
                            onPressed: _resendCooldown > 0 ? null : _handleResendOtp,
                            child: Text(
                              _resendCooldown > 0
                                  ? 'Resend in ${_resendCooldown}s'
                                  : 'Resend OTP',
                              style: TextStyle(
                                color: _resendCooldown > 0
                                    ? AppColors.textMuted
                                    : AppColors.ambientWarmGlow,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                  ],
                ),

                const SizedBox(height: 10),

                // Back Button
                TextButton(
                  onPressed: () {
                    _resendTimer?.cancel();
                    setState(() {
                      _isOtpVerificationStep = false;
                      _errorMessage = null;
                      _infoMessage = null;
                    });
                  },
                  child: const Text(
                    '← Back to Sign In',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.backgroundCard,
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.ambientWarmGlow, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
