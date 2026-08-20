import 'package:flutter/material.dart';
import '../../components/layout/ambient_background.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/todo_model.dart';
import '../../services/supabase/todo_supabase_service.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<TodoModel> _todos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final todos = await TodoSupabaseService.getTodos();
      if (mounted) {
        setState(() {
          _todos = todos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load tasks: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddTodoDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Task',
                style: AppTextStyles.promptTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final title = controller.text.trim();
                      if (title.isNotEmpty) {
                        Navigator.of(ctx).pop();
                        try {
                          final newTodo = await TodoSupabaseService.addTodo(title);
                          if (newTodo != null && mounted) {
                            setState(() {
                              _todos.insert(0, newTodo);
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add task: $e')),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ambientWarmGlow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleTodo(TodoModel todo) async {
    final updatedStatus = !todo.isCompleted;
    setState(() {
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo.copyWith(isCompleted: updatedStatus);
      }
    });

    try {
      await TodoSupabaseService.toggleTodo(todo.id, updatedStatus);
    } catch (e) {
      // Revert on error
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = todo.copyWith(isCompleted: !updatedStatus);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  Future<void> _deleteTodo(String id) async {
    final removed = _todos.firstWhere((t) => t.id == id);
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });

    try {
      await TodoSupabaseService.deleteTodo(id);
    } catch (e) {
      setState(() {
        _todos.add(removed);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTodoDialog,
        backgroundColor: AppColors.ambientWarmGlow,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AmbientBackground(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textWhite),
                    onPressed: () => Navigator.of(context).pop(_todos.length),
                  ),
                  const SizedBox(width: 8),
                  Text('To-Do', style: AppTextStyles.brandTitle),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                    onPressed: _loadTodos,
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.ambientWarmGlow),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_errorMessage!,
                                    style: const TextStyle(color: Color(0xFFFF8B8B)),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadTodos,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _todos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.todoIconBg.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_circle_outline_rounded,
                                        color: AppColors.todoIconBg, size: 32),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('No tasks yet',
                                      style: AppTextStyles.promptTitle.copyWith(fontSize: 22)),
                                  const SizedBox(height: 6),
                                  Text('Tap + to create your first task',
                                      style: AppTextStyles.greetingSubtitle),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _todos.length,
                              itemBuilder: (context, index) {
                                final todo = _todos[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundCard,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: todo.isCompleted,
                                      activeColor: AppColors.todoIcon,
                                      checkColor: Colors.white,
                                      side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      onChanged: (_) => _toggleTodo(todo),
                                    ),
                                    title: Text(
                                      todo.title,
                                      style: TextStyle(
                                        color: todo.isCompleted
                                            ? AppColors.textMuted
                                            : AppColors.textWhite,
                                        decoration: todo.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        fontSize: 15,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded,
                                          color: AppColors.textSubtle, size: 20),
                                      onPressed: () => _deleteTodo(todo.id),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
