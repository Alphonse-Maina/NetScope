import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/theme/app_theme.dart';
import '../widgets/net_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40))),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 12),
      Center(child: Container(width: 92, height: 92,
        decoration: BoxDecoration(color: AppTheme.surface, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.radar_rounded, size: 48, color: AppTheme.accent))),
      const SizedBox(height: 16),
      const Center(child: Text('NetScope', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 29))),
      const SizedBox(height: 5),
      const Center(child: Text('Network Intelligence by Vexaryn', style: TextStyle(color: AppTheme.mutedText))),
      const SizedBox(height: 30),
      const SectionHeader('Application'),
      const SizedBox(height: 12),
      NetPanel(padding: EdgeInsets.zero, child: Column(children: [
        ListTile(leading: const Icon(Icons.shield_outlined, color: AppTheme.accent),
          title: const Text('Permissions'), subtitle: const Text('Review Wi-Fi and location access'),
          trailing: const Icon(Icons.chevron_right), onTap: () async { await openAppSettings(); }),
        const Divider(height: 1, color: AppTheme.border),
        const ListTile(leading: Icon(Icons.info_outline, color: AppTheme.accent),
          title: Text('Build'), subtitle: Text('NetScope — UI refresh / development')),
      ])),
      const SizedBox(height: 24),
      const SectionHeader('Privacy & discovery'),
      const SizedBox(height: 12),
      const NetPanel(child: Text('Core network tests run on your device. Discovery probes only the connected private Wi-Fi subnet. Scan networks you own or are authorized to assess.',
        style: TextStyle(color: AppTheme.mutedText, height: 1.55))),
      const SizedBox(height: 40),
      const Center(child: Text('BUILT BY VEXARYN', style: TextStyle(color: AppTheme.accent, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900))),
    ]),
  );
}
