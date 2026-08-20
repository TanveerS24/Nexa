import 'package:flutter/material.dart';
import '../../components/layout/ambient_background.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/gym_model.dart';
import '../../services/supabase/gym_supabase_service.dart';

class GymPage extends StatefulWidget {
  const GymPage({super.key});

  @override
  State<GymPage> createState() => _GymPageState();
}

class _GymPageState extends State<GymPage> {
  List<GymWorkoutModel> _workouts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final workouts = await GymSupabaseService.getWorkouts();
      if (mounted) {
        setState(() {
          _workouts = workouts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load workouts: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddWorkoutDialog() async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();

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
                'Log Workout',
                style: AppTextStyles.promptTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Workout Title (e.g. Chest & Triceps)',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Notes (sets, reps, weights)',
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
                      final title = titleController.text.trim();
                      final notes = notesController.text.trim();
                      if (title.isNotEmpty) {
                        Navigator.of(ctx).pop();
                        try {
                          final newWorkout = await GymSupabaseService.addWorkout(
                            title,
                            notes: notes.isNotEmpty ? notes : null,
                          );
                          if (newWorkout != null && mounted) {
                            setState(() {
                              _workouts.insert(0, newWorkout);
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to log workout: $e')),
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
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteWorkout(String id) async {
    final removed = _workouts.firstWhere((w) => w.id == id);
    setState(() {
      _workouts.removeWhere((w) => w.id == id);
    });

    try {
      await GymSupabaseService.deleteWorkout(id);
    } catch (e) {
      setState(() {
        _workouts.add(removed);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting workout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkoutDialog,
        backgroundColor: AppColors.ambientWarmGlow,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Workout', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onPressed: () => Navigator.of(context).pop(_workouts.length),
                  ),
                  const SizedBox(width: 8),
                  Text('Gym', style: AppTextStyles.brandTitle),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                    onPressed: _loadWorkouts,
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
                                  onPressed: _loadWorkouts,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _workouts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.gymIconBg.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.fitness_center_rounded,
                                        color: AppColors.gymIconBg, size: 32),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('No workouts logged',
                                      style: AppTextStyles.promptTitle.copyWith(fontSize: 22)),
                                  const SizedBox(height: 6),
                                  Text('Tap + to log your training session',
                                      style: AppTextStyles.greetingSubtitle),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _workouts.length,
                              itemBuilder: (context, index) {
                                final workout = _workouts[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundCard,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: AppColors.gymIconBg,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.fitness_center_rounded,
                                            color: AppColors.gymIcon, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              workout.title,
                                              style: AppTextStyles.notificationTitle,
                                            ),
                                            if (workout.notes != null &&
                                                workout.notes!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                workout.notes!,
                                                style: AppTextStyles.notificationSubtitle,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded,
                                            color: AppColors.textSubtle, size: 20),
                                        onPressed: () => _deleteWorkout(workout.id),
                                      ),
                                    ],
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
