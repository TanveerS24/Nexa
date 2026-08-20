import 'package:flutter/material.dart';

/// Data model representing a modular tile in the Nexa horizontal carousel
class ModuleItem {
  final String id;
  final String title;
  final String subtitle;
  final String pillText;
  final String route;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color pillBgColor;
  final Color pillTextColor;

  const ModuleItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pillText,
    required this.route,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.pillBgColor,
    required this.pillTextColor,
  });
}
