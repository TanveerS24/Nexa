import 'package:flutter/material.dart';

/// Data model representing a notification item
class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;
  final Color iconBgColor;
  final Color dotColor;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
    required this.iconBgColor,
    required this.dotColor,
  });
}
