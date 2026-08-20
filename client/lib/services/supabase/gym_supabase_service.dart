import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/gym_model.dart';
import 'supabase_service.dart';

class GymSupabaseService {
  static SupabaseClient get _client =>
      SupabaseService.client ?? Supabase.instance.client;

  static const String tableName = 'gym_workouts';

  static Future<List<GymWorkoutModel>> getWorkouts() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from(tableName)
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => GymWorkoutModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<GymWorkoutModel?> addWorkout(String title, {String? notes}) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from(tableName)
        .insert({
          'user_id': user.id,
          'title': title,
          'notes': notes,
        })
        .select()
        .single();

    return GymWorkoutModel.fromJson(response);
  }

  static Future<void> deleteWorkout(String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }
}
