import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static String get baseUrl {
    final raw = dotenv.env['VITE_API_BASE_URL'] ?? 'http://192.168.0.101:5000/api/v1';
    if (raw.endsWith('/api')) {
      return '$raw/v1';
    }
    return raw;
  }

  static String _formatError(dynamic e) {
    if (e is SocketException || e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
      return 'Cannot reach backend server at $baseUrl. Ensure your device is on the same Wi-Fi and the backend server is running.';
    }
    if (e is http.ClientException) {
      return 'Network connection error: ${e.message}';
    }
    return e.toString().replaceAll('Exception:', '').trim();
  }

  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      if (kDebugMode) print('[ApiClient] GET $url');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'statusCode': response.statusCode};
    } catch (e) {
      if (kDebugMode) print('[ApiClient] Error in checkHealth: $e');
      return {'status': 'error', 'message': _formatError(e)};
    }
  }

  static Future<Map<String, dynamic>> getModuleStatus(String moduleName) async {
    try {
      final url = Uri.parse('$baseUrl/$moduleName');
      if (kDebugMode) print('[ApiClient] GET $url');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'statusCode': response.statusCode};
    } catch (e) {
      if (kDebugMode) print('[ApiClient] Error in getModuleStatus: $e');
      return {'status': 'error', 'message': _formatError(e)};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? displayName,
    DateTime? dob,
    double? height,
    double? weight,
    bool sendOtp = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      final payload = {
        'email': email,
        'password': password,
        ?'displayName': displayName,
        if (dob != null)
          'dob':
              "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
        ?'height': height,
        ?'weight': weight,
        'sendOtp': sendOtp,
      };

      if (kDebugMode) print('[ApiClient] POST $url -> payload: ${jsonEncode(payload)}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) print('[ApiClient] Response [${response.statusCode}] ${response.body}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        ...data,
        'statusCode': response.statusCode,
        'success': response.statusCode == 200 || response.statusCode == 201,
      };
    } catch (e) {
      if (kDebugMode) print('[ApiClient] Error in register: $e');
      return {'success': false, 'error': _formatError(e), 'message': _formatError(e)};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final payload = {
        'email': email,
        'password': password,
      };

      if (kDebugMode) print('[ApiClient] POST $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) print('[ApiClient] Response [${response.statusCode}] ${response.body}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        ...data,
        'statusCode': response.statusCode,
        'success': response.statusCode == 200,
      };
    } catch (e) {
      if (kDebugMode) print('[ApiClient] Error in login: $e');
      return {'success': false, 'error': _formatError(e), 'message': _formatError(e)};
    }
  }

  static Future<Map<String, dynamic>> sendOtp({
    required String email,
    String? userName,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/send-otp');
      final payload = {
        'email': email,
        ?'userName': userName,
      };

      if (kDebugMode) print('[ApiClient] POST $url -> payload: ${jsonEncode(payload)}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) print('[ApiClient] Response [${response.statusCode}] ${response.body}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        ...data,
        'statusCode': response.statusCode,
        'success': response.statusCode == 200,
      };
    } catch (e) {
      if (kDebugMode) print('[ApiClient] Error in sendOtp: $e');
      return {'success': false, 'error': _formatError(e), 'message': _formatError(e)};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/verify-otp');
      final payload = {
        'email': email,
        'otp': otp,
      };

      if (kDebugMode) print('[ApiClient] POST $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) print('[ApiClient] Response [${response.statusCode}] ${response.body}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        ...data,
        'statusCode': response.statusCode,
        'success': response.statusCode == 200,
      };
    } catch (e) {
      if (kDebugMode) print('[ApiClient] Error in verifyOtp: $e');
      return {'success': false, 'error': _formatError(e), 'message': _formatError(e)};
    }
  }
}
