import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NetScopeApp());
}
class NetScopeApp extends StatelessWidget {
  const NetScopeApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'NetScope by Vexaryn', debugShowCheckedModeBanner: false,
    theme: AppTheme.dark, home: const AppShell(),
  );
}
