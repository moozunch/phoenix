import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class AppButton extends StatelessWidget {
	const AppButton({
		super.key,
		required this.label,
		this.onPressed,
		this.icon,
		this.minHeight,
		this.fullWidth = true,
	});

	final String label;
	final VoidCallback? onPressed;
	final Widget? icon;
	final double? minHeight;
	final bool fullWidth;

	@override
	Widget build(BuildContext context) {
		final width = MediaQuery.of(context).size.width;
		final h = minHeight ?? (width > 600 ? 56.0 : 48.0);

		final child = Row(
			mainAxisAlignment: MainAxisAlignment.center,
			mainAxisSize: MainAxisSize.min,
			children: [
				if (icon != null) ...[
					icon!,
					const SizedBox(width: 8),
				],
				Flexible(
					child: Text(
						label,
						overflow: TextOverflow.ellipsis,
					),
				),
			],
		);

		final button = ConstrainedBox(
			constraints: BoxConstraints(minHeight: h),
			child: FilledButton(
				onPressed: onPressed,
				style: FilledButton.styleFrom(
					backgroundColor: AppPalette.primary,
					foregroundColor: Colors.white,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(h / 2)),
				),
				child: child,
			),
		);

		return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
	}
}

