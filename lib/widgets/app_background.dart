import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = height ?? (size.height * 0.22).clamp(120.0, 260.0);

    return SizedBox(
      height: h,
      width: double.infinity,
      child: ClipPath(
        clipper: _BottomCurveClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppPalette.primary,
                HSLColor.fromColor(AppPalette.primary)
                    .withLightness((HSLColor.fromColor(AppPalette.primary).lightness + 0.25).clamp(0.0, 1.0))
                    .toColor(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.5, size.height,
      size.width, size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}