import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Ambient cozy background replicating the warm lighting and dark wood aesthetic
class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF18130E),
            Color(0xFF130F0C),
            Color(0xFF0F0C0A),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Warm Edison lamp ambient glow at top-right
          Positioned(
            top: 40,
            right: -40,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.ambientWarmGlow.withValues(alpha: 0.28),
                    AppColors.ambientWarmGlow.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          // Subtle warm glow near center cards
          Positioned(
            top: 240,
            left: 20,
            right: 20,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.9,
                  colors: [
                    AppColors.ambientWarmGlow.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Subtle wood shelf line accents in background
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.shelfWoodLight.withValues(alpha: 0.35),
                    AppColors.shelfWoodLight.withValues(alpha: 0.55),
                    AppColors.shelfWoodLight.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 490,
            left: 0,
            right: 0,
            child: Container(
              height: 2.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.shelfWoodDark.withValues(alpha: 0.6),
                    AppColors.shelfWoodLight.withValues(alpha: 0.5),
                    AppColors.shelfWoodDark.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            bottom: false,
            child: child,
          ),
        ],
      ),
    );
  }
}
