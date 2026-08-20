import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String defaultUrl = 'https://yvstmiiytixlbwgzanez.supabase.co';
  static const String defaultPublishableKey = 'sb_publishable_NRgrWbjizVizJzoETpFvyg_fmyL0wqp';

  static SupabaseClient? _client;

  static SupabaseClient? get client => _client;

  static bool get isInitialized => _client != null;

  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
        dotenv.env['VITE_SUPABASE_URL'] ??
        defaultUrl;
    final supabasePublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
        dotenv.env['VITE_SUPABASE_ANON_KEY'] ??
        dotenv.env['SUPABASE_ANON_KEY'] ??
        defaultPublishableKey;

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabasePublishableKey, // ignore: deprecated_member_use
      );
      _client = Supabase.instance.client;
      if (kDebugMode) {
        print('[SupabaseService] Supabase initialized successfully with $supabaseUrl.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SupabaseService] Initialization error: $e');
      }
      try {
        _client = Supabase.instance.client;
      } catch (_) {}
    }
  }
}
