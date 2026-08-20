import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/supabase/auth_service.dart';

class Header extends StatelessWidget {
  final String userName;
  final String? customGreeting;
  final String? customTagline;
  final VoidCallback? onProfileTap;

  const Header({
    super.key,
    required this.userName,
    this.customGreeting,
    this.customTagline,
    this.onProfileTap,
  });

  String _getTimeGreeting(bool isBirthday) {
    if (isBirthday) {
      return '🎉 Happy Birthday,';
    }
    if (customGreeting != null) return customGreeting!;
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  String _getTagline(bool isBirthday) {
    if (isBirthday) {
      return 'Wishing you an amazing year ahead filled with growth & joy! 🎂✨';
    }
    return customTagline ?? 'Stay productive. Stay you.';
  }

  @override
  Widget build(BuildContext context) {
    final bool isBirthday = AuthService.isUserBirthdayToday();
    final greeting = _getTimeGreeting(isBirthday);
    final tagline = _getTagline(isBirthday);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Profile Button on Top-Left + Nexa Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top-Left: Profile Button & Brand Icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isBirthday ? const Color(0xFF5A3C28) : AppColors.navActivePill,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isBirthday
                              ? AppColors.ambientWarmGlow
                              : AppColors.navActiveIcon.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: isBirthday ? AppColors.ambientWarmGlow : AppColors.navActiveIcon,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Nexa',
                    style: AppTextStyles.brandTitle,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // User Greeting & Tagline
          Text(
            greeting,
            style: isBirthday
                ? AppTextStyles.greetingLabel.copyWith(
                    color: AppColors.ambientWarmGlow,
                    fontWeight: FontWeight.w600,
                  )
                : AppTextStyles.greetingLabel,
          ),
          const SizedBox(height: 2),
          Text(
            isBirthday ? '$userName 🎂' : '$userName ☀️',
            style: AppTextStyles.greetingName,
          ),
          const SizedBox(height: 4),
          Text(
            tagline,
            style: isBirthday
                ? AppTextStyles.greetingSubtitle.copyWith(
                    color: const Color(0xFFF3D5A5),
                    fontWeight: FontWeight.w500,
                  )
                : AppTextStyles.greetingSubtitle,
          ),

          const SizedBox(height: 24),

          // Prompt Headline
          Text(
            'What do you\nwant to do?',
            style: AppTextStyles.promptTitle,
          ),
        ],
      ),
    );
  }
}
