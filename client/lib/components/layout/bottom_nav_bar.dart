import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../common/custom_badge.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final int notificationCount;

  const BottomNavBar({
    super.key,
    this.currentIndex = 0,
    required this.onIndexChanged,
    this.notificationCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.bottomNavBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: currentIndex == 0,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.grid_view_rounded,
            label: 'Modules',
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            badgeCount: notificationCount,
            isActive: currentIndex == 2,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            isActive: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    int badgeCount = 0,
  }) {
    if (isActive) {
      // Active pill container
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.navActivePill,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.navActiveIcon,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.navActive,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => onIndexChanged(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: AppColors.navInactive,
                  size: 22,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: CustomBadge(count: badgeCount, size: 14),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.navInactive,
            ),
          ],
        ),
      ),
    );
  }
}
