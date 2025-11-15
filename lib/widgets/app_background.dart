import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

///soft gradient background 
class Background extends StatelessWidget {
  final Alignment begin;
  final Alignment end;
  final bool enableBlur;

  const Background({
    super.key,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Base gradient
    final base = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: isDark
              ? [
                  // keep dark surfaces subtle
                  scheme.surface.withValues(alpha: 0.98),
                  scheme.surfaceContainerHighest.withValues(alpha: 0.94),
                ]
              : [
                  // white with a very subtle hint of brand primary
                  Colors.white,
                  AppPalette.primary.withValues(alpha: 0.04),
                ],
        ),
      ),
    );

    // Decorative blobs using radial gradients
    Widget blob({required Offset center, required List<Color> colors, double radius = 220}) {
      return Positioned(
        left: center.dx - radius,
        top: center.dy - radius,
        child: IgnorePointer(
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: colors,
              ),
            ),
          ),
        ),
      );
    }

    final blobs = Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(children: [
            // Smaller blobs placed higher for a lighter feel
            blob(
              center: Offset(w * 0.20, h * 0.06),
              colors: [
                AppPalette.primary.withValues(alpha: isDark ? 0.10 : 0.12),
                AppPalette.primary.withValues(alpha: 0.0),
              ],
              radius: 90,
            ),
            blob(
              center: Offset(w * 0.85, h * 0.05),
              colors: [
                AppPalette.primary.withValues(alpha: isDark ? 0.08 : 0.10),
                AppPalette.primary.withValues(alpha: 0.0),
              ],
              radius: 100,
            ),
            blob(
              center: Offset(w * 0.25, h * 0.85),
              colors: [
                AppPalette.primary.withValues(alpha: isDark ? 0.06 : 0.08),
                AppPalette.primary.withValues(alpha: 0.0),
              ],
              radius: 110,
            ),
          ]);
        },
      ),
    );

    final blurLayer = enableBlur
        ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
            child: Container(color: Colors.transparent),
          )
        : const SizedBox.shrink();

    return Positioned.fill(
      child: Stack(
        children: [base, blobs, blurLayer],
      ),
    );
  }
}