import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phoenix/styles/app_palette.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size});
  final double? size;

  @override
  Widget build(BuildContext context) {
    final s = size ?? (MediaQuery.of(context).size.width * 0.24).clamp(48.0, 120.0);
    return SizedBox(
      width: s,
      height: s,
      child: Lottie.asset(
        'assets/json/phoenix.json',
        delegates: LottieDelegates(
          values: [
            // Apply a global color override; adjust keyPath for specific layers if needed
            ValueDelegate.color(['**'], value: AppPalette.primary),
          ],
        ),
        fit: BoxFit.contain,
      ),
    );
  }
}
