import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EmailJsService {
  static String get serviceId => dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
  static String get templateId => dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
  static String get publicKey => dotenv.env['EMAILJS_PUBLIC_KEY'] ?? '';

  static bool get isConfigured =>
      serviceId.isNotEmpty &&
      templateId.isNotEmpty &&
      publicKey.isNotEmpty &&
      !serviceId.contains('your_') &&
      !templateId.contains('your_') &&
      !publicKey.contains('your_');

  /// Send 6-digit OTP email using EmailJS REST API
  static Future<bool> sendOtpEmail({
    required String toEmail,
    required String otpCode,
    String? userName,
  }) async {
    if (!isConfigured) {
      if (kDebugMode) {
        print(
            '[EmailJsService] EmailJS keys not configured. Simulating OTP send for $toEmail: CODE = $otpCode');
      }
      return true;
    }

    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_email': toEmail,
            'email': toEmail,
            'to_name': userName ?? 'User',
            'otp_code': otpCode,
            'passcode': otpCode,
            'app_name': 'Nexa',
          },
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[EmailJsService] OTP successfully sent to $toEmail via EmailJS.');
        }
        return true;
      } else {
        if (kDebugMode) {
          print(
              '[EmailJsService] Error sending email (${response.statusCode}): ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[EmailJsService] Exception sending email: $e');
      }
      return false;
    }
  }
}

/// Helper class to generate, cache, and verify 6-digit OTP codes
class OtpManager {
  static final Map<String, _OtpEntry> _otpCache = {};

  /// Generate a random 6-digit OTP code and send via EmailJS
  static Future<String> generateAndSendOtp({
    required String email,
    String? userName,
  }) async {
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();

    _otpCache[email.toLowerCase()] = _OtpEntry(
      code: otp,
      expiry: DateTime.now().add(const Duration(minutes: 10)),
    );

    await EmailJsService.sendOtpEmail(
      toEmail: email,
      otpCode: otp,
      userName: userName,
    );

    return otp;
  }

  /// Verify entered 6-digit code
  static bool verifyOtp(String email, String enteredOtp) {
    final entry = _otpCache[email.toLowerCase()];
    if (entry == null) return false;

    if (DateTime.now().isAfter(entry.expiry)) {
      _otpCache.remove(email.toLowerCase());
      return false;
    }

    final isValid = entry.code == enteredOtp.trim();
    if (isValid) {
      _otpCache.remove(email.toLowerCase());
    }
    return isValid;
  }
}

class _OtpEntry {
  final String code;
  final DateTime expiry;

  _OtpEntry({required this.code, required this.expiry});
}
