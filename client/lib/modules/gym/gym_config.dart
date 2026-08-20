import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/module_item.dart';

final ModuleItem gymModuleConfig = ModuleItem(
  id: 'gym',
  title: 'Gym',
  subtitle: 'Track your\ntraining',
  pillText: 'Workout today',
  route: AppRoutes.gym,
  icon: Icons.fitness_center_rounded,
  iconBgColor: AppColors.gymIconBg,
  iconColor: AppColors.gymIcon,
  titleColor: AppColors.gymTitle,
  subtitleColor: AppColors.gymSubtitle,
  pillBgColor: AppColors.gymPillBg,
  pillTextColor: AppColors.gymPillText,
);
