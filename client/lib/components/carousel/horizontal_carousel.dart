import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/module_item.dart';
import 'carousel_card.dart';

/// Reusable horizontal scrolling carousel with touch, mouse drag, and snapping support
class HorizontalCarousel extends StatelessWidget {
  final List<ModuleItem> items;
  final ValueChanged<ModuleItem> onItemSelected;
  final double cardWidth;
  final double cardHeight;
  final double itemSpacing;
  final EdgeInsets padding;

  const HorizontalCarousel({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.cardWidth = 168.0,
    this.cardHeight = 248.0,
    this.itemSpacing = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight + 20, // Allowance for shadows and margins
      child: ScrollConfiguration(
        behavior: const _AppCustomScrollBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: padding.copyWith(top: 8, bottom: 12),
          itemCount: items.length,
          separatorBuilder: (context, index) => SizedBox(width: itemSpacing),
          itemBuilder: (context, index) {
            final item = items[index];
            return CarouselCard(
              item: item,
              width: cardWidth,
              height: cardHeight,
              onTap: () => onItemSelected(item),
            );
          },
        ),
      ),
    );
  }
}

/// Custom scroll behavior enabling drag across mobile touch, mouse, and trackpad
class _AppCustomScrollBehavior extends MaterialScrollBehavior {
  const _AppCustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
