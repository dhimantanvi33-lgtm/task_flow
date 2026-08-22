import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Container(
      decoration: BoxDecoration(color: colors.card, border: Border(top: BorderSide(color: colors.border))),
      child: SafeArea(
        top: false,
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: colors.primary.withValues(alpha: 0.14),
            labelTextStyle: WidgetStateProperty.all(TextStyle(fontSize: 12, color: colors.textSecondary)),
          ),
          child: NavigationBar(
            height: 64,
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder_rounded), label: 'Projects'),
              NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle_rounded), label: 'Tasks'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
