import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'home_screen.dart';
import 'devices_screen.dart';
import 'tools_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override State<AppShell> createState() => _AppShellState();
}
class _AppShellState extends State<AppShell> {
  int index = 0;
  final screens = const [HomeScreen(), DevicesScreen(), ToolsScreen(), SettingsScreen()];
  @override Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: index, children: screens),
    bottomNavigationBar: NavigationBarTheme(
      data: NavigationBarThemeData(backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.accent.withValues(alpha: .14), height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: states.contains(WidgetState.selected) ? AppTheme.accent : AppTheme.mutedText))),
      child: NavigationBar(selectedIndex: index, onDestinationSelected: (i) => setState(() => index = i), destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: AppTheme.accent), label: 'Overview'),
        NavigationDestination(icon: Icon(Icons.devices_outlined), selectedIcon: Icon(Icons.devices, color: AppTheme.accent), label: 'Devices'),
        NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune, color: AppTheme.accent), label: 'Tools'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings, color: AppTheme.accent), label: 'Settings'),
      ]),
    ),
  );
}
