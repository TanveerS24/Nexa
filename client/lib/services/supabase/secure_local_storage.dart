import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Secure storage implementation for Supabase Auth tokens using Keychain (iOS/macOS)
/// and Android KeyStore + EncryptedSharedPreferences (Android).
class SecureLocalStorage extends LocalStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _sessionKey = 'supabase_auth_session_token';

  const SecureLocalStorage();

  @override
  Future<void> initialize() async {
    // No initialization required for FlutterSecureStorage
  }

  @override
  Future<String?> accessToken() async {
    try {
      return await _storage.read(key: _sessionKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    try {
      return await _storage.containsKey(key: _sessionKey);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    try {
      await _storage.write(
        key: _sessionKey,
        value: persistSessionString,
      );
    } catch (_) {}
  }

  @override
  Future<void> removePersistedSession() async {
    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {}
  }
}
