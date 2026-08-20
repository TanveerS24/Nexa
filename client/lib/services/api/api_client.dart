import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static String get baseUrl =>
      dotenv.env['VITE_API_BASE_URL'] ?? 'http://localhost:5000/api';

  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'statusCode': response.statusCode};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getModuleStatus(String moduleName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$moduleName'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'statusCode': response.statusCode};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
