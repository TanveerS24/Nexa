import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/module_item.dart';

class CarouselCard extends StatefulWidget {
  final ModuleItem item;
  final VoidCallback onTap;
  final double width;
  final double height;

  const CarouselCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width = 168.0,
    this.height = 248.0,
  });

  @override
  State<CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.cardCreamBase,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.cardCreamHighlight,
                AppColors.cardCreamBase,
                Color(0xFFE5DDD0),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              // Outer drop shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              // Subtle ambient warmth
              BoxShadow(
                color: AppColors.ambientWarmGlow.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Icon Badge Container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.item.iconBgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.item.iconColor.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  widget.item.icon,
                  color: widget.item.iconColor,
                  size: 28,
                ),
              ),

              // Title & Subtitle Block
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.item.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardTitle(widget.item.titleColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.item.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardSubtitle(widget.item.subtitleColor),
                  ),
                ],
              ),

              // Bottom Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: widget.item.pillBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.item.pillText,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cardPill(widget.item.pillTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
