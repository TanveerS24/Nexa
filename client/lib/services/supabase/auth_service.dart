import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  static SupabaseClient get _client =>
      SupabaseService.client ?? Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// Calculate exact age based on date of birth
  static int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age >= 0 ? age : 0;
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
    DateTime? dob,
    double? height,
    double? weight,
  }) async {
    final int? calculatedAge = dob != null ? calculateAge(dob) : null;
    final String? dobString = dob != null
        ? "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}"
        : null;

    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        ?'display_name': displayName,
        ?'dob': dobString,
        ?'age': calculatedAge,
        ?'height': height,
        ?'weight': weight,
      },
    );

    // Save profile to database table if user registered immediately
    if (response.user != null) {
      await _saveProfileData(
        userId: response.user!.id,
        displayName: displayName,
        dobString: dobString,
        calculatedAge: calculatedAge,
        height: height,
        weight: weight,
      );
    }

    return response;
  }

  static Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    OtpType type = OtpType.signup,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: type,
    );

    // If verified, save profile to DB if needed
    if (response.user != null) {
      final meta = response.user!.userMetadata;
      final dobStr = meta?['dob'] as String?;
      final age = meta?['age'] as int?;
      final height = meta?['height'] != null
          ? double.tryParse(meta!['height'].toString())
          : null;
      final weight = meta?['weight'] != null
          ? double.tryParse(meta!['weight'].toString())
          : null;

      await _saveProfileData(
        userId: response.user!.id,
        displayName: meta?['display_name'] as String?,
        dobString: dobStr,
        calculatedAge: age,
        height: height,
        weight: weight,
      );
    }

    return response;
  }

  static Future<void> resendOtp({
    required String email,
    OtpType type = OtpType.signup,
  }) async {
    await _client.auth.resend(
      email: email,
      type: type,
    );
  }

  static Future<void> signInWithOtp({required String email}) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;
    try {
      // Clean up user records from database
      await _client.from('profiles').delete().eq('id', user.id);
      await _client.from('todos').delete().eq('user_id', user.id);
      await _client.from('gym_workouts').delete().eq('user_id', user.id);
    } catch (e) {
      if (kDebugMode) print('[AuthService] Error deleting user profile data: $e');
    }
    // Sign out from local session
    await _client.auth.signOut();
  }

  static Future<void> updateProfile({
    String? displayName,
    DateTime? dob,
    double? height,
    double? weight,
  }) async {
    final user = currentUser;
    if (user == null) return;

    final int? calculatedAge = dob != null ? calculateAge(dob) : getUserAge();
    final String? dobString = dob != null
        ? "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}"
        : user.userMetadata?['dob'] as String?;

    // Update user metadata
    final updatedMeta = {
      ...user.userMetadata ?? {},
      ?'display_name': displayName,
      ?'dob': dobString,
      ?'age': calculatedAge,
      ?'height': height,
      ?'weight': weight,
    };

    await _client.auth.updateUser(UserAttributes(data: updatedMeta));

    // Update profiles table
    await _saveProfileData(
      userId: user.id,
      displayName: displayName ?? getUserDisplayName(),
      dobString: dobString,
      calculatedAge: calculatedAge,
      height: height ?? getUserHeight(),
      weight: weight ?? getUserWeight(),
    );
  }

  static Future<void> _saveProfileData({
    required String userId,
    String? displayName,
    String? dobString,
    int? calculatedAge,
    double? height,
    double? weight,
  }) async {
    try {
      await _client.from('profiles').upsert({
        'id': userId,
        ?'display_name': displayName,
        ?'dob': dobString,
        ?'age': calculatedAge,
        ?'height': height,
        ?'weight': weight,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] Profile upsert error: $e');
      }
    }
  }

  static String getUserDisplayName() {
    final user = currentUser;
    if (user == null) return 'Guest';
    final rawName = user.userMetadata?['display_name'] as String?;
    if (rawName != null && rawName.trim().isNotEmpty) {
      return rawName;
    }
    if (user.email != null && user.email!.contains('@')) {
      final prefix = user.email!.split('@').first;
      if (prefix.isNotEmpty) {
        return prefix[0].toUpperCase() + prefix.substring(1);
      }
    }
    return 'Tanveer';
  }

  static DateTime? getUserDob() {
    final user = currentUser;
    if (user == null) return null;
    final dobStr = user.userMetadata?['dob'] as String?;
    if (dobStr != null && dobStr.isNotEmpty) {
      try {
        return DateTime.parse(dobStr);
      } catch (_) {}
    }
    return null;
  }

  static int? getUserAge() {
    final user = currentUser;
    if (user == null) return null;
    final rawAge = user.userMetadata?['age'];
    if (rawAge is int) return rawAge;
    if (rawAge is String) return int.tryParse(rawAge);

    final dob = getUserDob();
    if (dob != null) {
      return calculateAge(dob);
    }
    return null;
  }

  static double? getUserHeight() {
    final user = currentUser;
    if (user == null) return null;
    final raw = user.userMetadata?['height'];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  static double? getUserWeight() {
    final user = currentUser;
    if (user == null) return null;
    final raw = user.userMetadata?['weight'];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  /// Checks if today matches the user's birthday (Month and Day)
  static bool isUserBirthdayToday() {
    final dob = getUserDob();
    if (dob == null) return false;
    final today = DateTime.now();
    return today.month == dob.month && today.day == dob.day;
  }
}
