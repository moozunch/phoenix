import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class BoardingHeader extends StatelessWidget {
  const BoardingHeader({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = (height ?? size.height * 0.36).clamp(200.0, 380.0);
    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        children: [
          // Orange header with concave bottom notch
          Positioned.fill(
            child: CustomPaint(
              painter: _OrangeHeaderPainter(color: AppPalette.primary),
            ),
          ),
          // Black corner decoration (top-left)
          Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              size: const Size(86, 86),
              painter: _BlackCornerPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrangeHeaderPainter extends CustomPainter {
  _OrangeHeaderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    // Top edge
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    // Right side down
    path.lineTo(size.width, size.height * 0.48);
    // Bottom concave notch (right -> center)
    path.quadraticBezierTo(
      size.width * 0.88, size.height * 0.48,
      size.width * 0.78, size.height * 0.60,
    );
    path.quadraticBezierTo(
      size.width * 0.62, size.height * 0.84,
      size.width * 0.50, size.height * 0.84,
    );
    // Center -> left
    path.quadraticBezierTo(
      size.width * 0.38, size.height * 0.84,
      size.width * 0.22, size.height * 0.60,
    );
    path.quadraticBezierTo(
      size.width * 0.12, size.height * 0.48,
      0, size.height * 0.48,
    );
    // Left edge up
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlackCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    final path = Path();
    // A rounded triangular wedge on top-left
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.85, 0);
    path.quadraticBezierTo(
      size.width * 0.65, size.height * 0.30,
      size.width * 0.30, size.height * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.12, size.height * 0.82,
      0, size.height * 0.60,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
