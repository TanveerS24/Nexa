import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/todo_model.dart';
import 'supabase_service.dart';

class TodoSupabaseService {
  static SupabaseClient get _client =>
      SupabaseService.client ?? Supabase.instance.client;

  static const String tableName = 'todos';

  static Future<List<TodoModel>> getTodos() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from(tableName)
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => TodoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<TodoModel?> addTodo(String title) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from(tableName)
        .insert({
          'user_id': user.id,
          'title': title,
          'is_completed': false,
        })
        .select()
        .single();

    return TodoModel.fromJson(response);
  }

  static Future<void> toggleTodo(String id, bool isCompleted) async {
    await _client.from(tableName).update({
      'is_completed': isCompleted,
    }).eq('id', id);
  }

  static Future<void> deleteTodo(String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }
}
