import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'package:phoenix/styles/app_palette.dart';

class TabScaffold extends StatelessWidget {
  const TabScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _handleTap(BuildContext context, int index) {
    if (index == 0) {
      navigationShell.goBranch(0, initialLocation: navigationShell.currentIndex == 0);
    } else if (index == 1) {
      // Middle button opens standalone upload page without shell
      context.push('/upload_reflection');
    } else if (index == 2) {
      navigationShell.goBranch(2, initialLocation: navigationShell.currentIndex == 2);
      // navigationShell.goBranch(1, initialLocation: navigationShell.currentIndex == 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final selectedIndex = navigationShell.currentIndex == 0 ? 0 : 2;
    final selectedIndex = navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WaterDropNavBar(
            backgroundColor: isDark
                ? Theme.of(context).scaffoldBackgroundColor
                : Colors.white,
            waterDropColor: isDark
                ? Colors.white
                : AppPalette.primary,
            selectedIndex: selectedIndex,
            onItemSelected: (i) => _handleTap(context, i),
            barItems: [
              BarItem(
                filledIcon: Icons.home_filled,
                outlinedIcon: Icons.home_outlined,
              ),
              BarItem(
                filledIcon: Icons.add,
                outlinedIcon: Icons.add,
              ),
              BarItem(
                filledIcon: Icons.person,
                outlinedIcon: Icons.person_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
