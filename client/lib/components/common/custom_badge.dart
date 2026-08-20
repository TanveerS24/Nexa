import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomBadge extends StatelessWidget {
  final int count;
  final double size;

  const CustomBadge({
    super.key,
    required this.count,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.badgeRed,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.6,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}
