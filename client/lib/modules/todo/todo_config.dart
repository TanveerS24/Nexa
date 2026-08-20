import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/module_item.dart';

final ModuleItem todoModuleConfig = ModuleItem(
  id: 'todo',
  title: 'To-Do',
  subtitle: 'Stay on top of\nyour tasks',
  pillText: '3 tasks today',
  route: AppRoutes.todo,
  icon: Icons.check_circle_outline_rounded,
  iconBgColor: AppColors.todoIconBg,
  iconColor: AppColors.todoIcon,
  titleColor: AppColors.todoTitle,
  subtitleColor: AppColors.todoSubtitle,
  pillBgColor: AppColors.todoPillBg,
  pillTextColor: AppColors.todoPillText,
);
