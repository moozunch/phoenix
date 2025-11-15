import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

/// - The larger star uses [primaryColor] (defaults to AppPalette.primary)
/// - The smaller star uses [secondaryColor] (defaults to black)
class OverlapStarsHeader extends StatelessWidget {
	const OverlapStarsHeader({
		super.key,
		this.height,
		this.primaryColor,
		this.secondaryColor,
		this.rotationPrimaryDeg = 80,
		this.rotationSecondaryDeg = -15,
		this.cornerRadius = 40,
	});

	final double? height;
	final Color? primaryColor;
	final Color? secondaryColor;
	final double rotationPrimaryDeg;
	final double rotationSecondaryDeg;
	final double cornerRadius;

	@override
	Widget build(BuildContext context) {
		final size = MediaQuery.of(context).size;
		final h = (height ?? size.height * 0.34).clamp(180.0, 420.0);

		return SizedBox(
			height: h,
			width: double.infinity,
			child: CustomPaint(
				painter: _OverlapStarsPainter(
					primaryColor: primaryColor ?? AppPalette.primary,
					secondaryColor: secondaryColor ?? Colors.black,
					rotationPrimaryRad: rotationPrimaryDeg * math.pi / 180,
					rotationSecondaryRad: rotationSecondaryDeg * math.pi / 180,
					cornerRadius: cornerRadius,
				),
			),
		);
	}
}

class _OverlapStarsPainter extends CustomPainter {
	_OverlapStarsPainter({
		required this.primaryColor,
		required this.secondaryColor,
		required this.rotationPrimaryRad,
		required this.rotationSecondaryRad,
		required this.cornerRadius,
	});

	final Color primaryColor;
	final Color secondaryColor;
	final double rotationPrimaryRad;
	final double rotationSecondaryRad;
	final double cornerRadius;

	@override
	void paint(Canvas canvas, Size size) {
		final paintPrimary = Paint()..color = primaryColor..style = PaintingStyle.fill;
		final paintSecondary = Paint()..color = secondaryColor..style = PaintingStyle.fill;

		final outerPrimary = size.width * 0.60; // large star spans width
		final innerPrimary = outerPrimary * 0.50;
		final outerSecondary = size.width * 0.60;
		final innerSecondary = outerSecondary * 0.50;

		// Shifted slightly further right (0.60 -> 0.66) per request
		final centerPrimary = Offset(size.width * 0.78, size.height * 0.13);
		final centerSecondary = Offset(size.width * 0.20, size.height * 0.10);

		final pathSecondary = _roundedStarPath(centerSecondary, outerSecondary, innerSecondary, 5, rotationSecondaryRad, cornerRadius * 0.8);
		canvas.drawPath(pathSecondary, paintSecondary);

		final pathPrimary = _roundedStarPath(centerPrimary, outerPrimary, innerPrimary, 5, rotationPrimaryRad, cornerRadius );
		canvas.drawPath(pathPrimary, paintPrimary);
	}

	List<Offset> _starPoints(Offset center, double outerR, double innerR, int points, double rot) {
		final result = <Offset>[];
		final step = math.pi / points; // 10 vertices alternating outer/inner -> 5 points
		double angle = -math.pi / 2 + rot; // start pointing up
		for (int i = 0; i < points * 2; i++) {
			final r = i.isEven ? outerR : innerR;
			final x = center.dx + r * math.cos(angle);
			final y = center.dy + r * math.sin(angle);
			result.add(Offset(x, y));
			angle += step;
		}
		return result;
	}

	Path _roundedPathFromPoints(List<Offset> pts, double radius) {
		final n = pts.length;
		if (n < 3) {
			final p = Path();
			if (n > 0) p.addPolygon(pts, true);
			return p;
		}
		final path = Path();
		for (int i = 0; i < n; i++) {
			final p0 = pts[(i - 1 + n) % n];
			final p1 = pts[i];
			final p2 = pts[(i + 1) % n];

			final v01 = (p1 - p0);
			final v12 = (p2 - p1);
			final len01 = v01.distance;
			final len12 = v12.distance;
			if (len01 == 0 || len12 == 0) continue;
			final dir01 = v01 / len01;
			final dir21 = -v12 / len12; // from p2 to p1

			final r = math.min(radius, math.min(len01, len12) * 0.45);
			final a = p1 - dir01 * r;
			final b = p1 - dir21 * r;

			if (i == 0) {
				path.moveTo(a.dx, a.dy);
			} else {
				path.lineTo(a.dx, a.dy);
			}
			path.quadraticBezierTo(p1.dx, p1.dy, b.dx, b.dy);
		}
		path.close();
		return path;
	}

	Path _roundedStarPath(Offset center, double outerR, double innerR, int points, double rot, double radius) {
		final pts = _starPoints(center, outerR, innerR, points, rot);
		return _roundedPathFromPoints(pts, radius);
	}

	@override
	bool shouldRepaint(covariant _OverlapStarsPainter oldDelegate) {
		return primaryColor != oldDelegate.primaryColor ||
				secondaryColor != oldDelegate.secondaryColor ||
				rotationPrimaryRad != oldDelegate.rotationPrimaryRad ||
				rotationSecondaryRad != oldDelegate.rotationSecondaryRad ||
				cornerRadius != oldDelegate.cornerRadius;
	}
}

