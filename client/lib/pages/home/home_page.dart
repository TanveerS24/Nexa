import 'package:flutter/material.dart';
import '../../components/carousel/horizontal_carousel.dart';
import '../../components/layout/ambient_background.dart';
import '../../components/layout/header.dart';
import '../../components/profile/profile_dialog.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/module_item.dart';
import '../../modules/gym/gym_config.dart';
import '../../modules/todo/todo_config.dart';
import '../../services/supabase/auth_service.dart';
import '../../services/supabase/gym_supabase_service.dart';
import '../../services/supabase/todo_supabase_service.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onSignOut;

  const HomePage({super.key, this.onSignOut});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _activeTodoCount = 0;
  int _workoutCount = 0;
  bool _isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _fetchRealCounts();
  }

  Future<void> _fetchRealCounts() async {
    try {
      final todos = await TodoSupabaseService.getTodos();
      final activeTodos = todos.where((t) => !t.isCompleted).length;

      final workouts = await GymSupabaseService.getWorkouts();

      if (mounted) {
        setState(() {
          _activeTodoCount = activeTodos;
          _workoutCount = workouts.length;
          _isLoadingCounts = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCounts = false);
      }
    }
  }

  void _onModuleTap(ModuleItem item) async {
    await Navigator.of(context).pushNamed(item.route);
    // Refresh real counts on return
    _fetchRealCounts();
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ProfileDialog(
        onSignOut: () {
          widget.onSignOut?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.getUserDisplayName();

    // Dynamically generated module items with real counts from Supabase
    final dynamicModules = [
      ModuleItem(
        id: todoModuleConfig.id,
        title: todoModuleConfig.title,
        subtitle: todoModuleConfig.subtitle,
        pillText: _isLoadingCounts
            ? 'Loading...'
            : _activeTodoCount > 0
                ? '$_activeTodoCount tasks today'
                : 'No tasks today',
        route: AppRoutes.todo,
        icon: todoModuleConfig.icon,
        iconBgColor: todoModuleConfig.iconBgColor,
        iconColor: todoModuleConfig.iconColor,
        titleColor: todoModuleConfig.titleColor,
        subtitleColor: todoModuleConfig.subtitleColor,
        pillBgColor: todoModuleConfig.pillBgColor,
        pillTextColor: todoModuleConfig.pillTextColor,
      ),
      ModuleItem(
        id: gymModuleConfig.id,
        title: gymModuleConfig.title,
        subtitle: gymModuleConfig.subtitle,
        pillText: _isLoadingCounts
            ? 'Loading...'
            : _workoutCount > 0
                ? '$_workoutCount logged'
                : 'Workout today',
        route: AppRoutes.gym,
        icon: gymModuleConfig.icon,
        iconBgColor: gymModuleConfig.iconBgColor,
        iconColor: gymModuleConfig.iconColor,
        titleColor: gymModuleConfig.titleColor,
        subtitleColor: gymModuleConfig.subtitleColor,
        pillBgColor: gymModuleConfig.pillBgColor,
        pillTextColor: gymModuleConfig.pillTextColor,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: AmbientBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile button on top-left, real name greeting, prompt
              Header(
                userName: userName,
                onProfileTap: _showProfileDialog,
              ),

              const SizedBox(height: 16),

              // Real data connected Horizontal Interactive Carousel
              HorizontalCarousel(
                items: dynamicModules,
                onItemSelected: _onModuleTap,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
