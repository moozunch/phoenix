import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
	const AppScaffold({
		super.key,
		required this.body,
		this.title,
		this.showBack = false,
		this.scrollable = true,
		this.headerHeight,
		this.background,
		this.onBack,
		this.bottomBar,
	});

	final Widget body;
	final String? title;
	final bool showBack;
	final bool scrollable;
	final double? headerHeight;
	final Widget? background;
	final VoidCallback? onBack;
	final Widget? bottomBar;

	EdgeInsets _horizontalPadding(BuildContext context) {
		final w = MediaQuery.of(context).size.width;
		final horizontal = (w * 0.08).clamp(16.0, 32.0);
		return EdgeInsets.symmetric(horizontal: horizontal);
	}

	@override
	Widget build(BuildContext context) {
		final content = Center(
			child: ConstrainedBox(
				constraints: const BoxConstraints(maxWidth: 560),
				child: Padding(
					padding: _horizontalPadding(context),
					child: body,
				),
			),
		);

		final bodyWidget = scrollable ? SingleChildScrollView(child: content) : content;

		return Scaffold(
			extendBodyBehindAppBar: true,
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				elevation: 0,
				leading: showBack
						? IconButton(
								icon: const Icon(Icons.arrow_back),
								onPressed: onBack ?? () {
									final nav = Navigator.of(context);
									if (nav.canPop()) {
										nav.pop();
									} else {
										// With go_router, use declarative navigation
										// ignore: use_build_context_synchronously
										context.go('/');
									}
								},
							)
						: null,
				title: title == null ? null : Text(title!, style: const TextStyle(fontWeight: FontWeight.w600)),
			),
			body: Stack(
				children: [
					Positioned.fill(
						child: Align(
							alignment: Alignment.topCenter,
						),
					),
					SafeArea(child: bodyWidget),
				],
			),
			bottomNavigationBar: bottomBar == null
					? null
					: SafeArea(
							minimum: const EdgeInsets.only(bottom: 16),
							child: Center(
								child: ConstrainedBox(
									constraints: const BoxConstraints(maxWidth: 560),
									child: Padding(
										padding: _horizontalPadding(context),
										child: bottomBar!,
									),
								),
							),
						),
		);
	}
}

