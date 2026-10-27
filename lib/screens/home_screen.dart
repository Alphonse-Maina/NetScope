import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/theme/app_theme.dart';
import '../services/network_service.dart';
import '../widgets/net_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final service = NetworkService();
  NetworkSnapshot? network;
  bool loading = false;
  String? error;
  @override void initState() { super.initState(); refresh(); }

  Future<void> refresh() async {
    if (loading) return;
    setState(() { loading = true; error = null; });
    try {
      final result = await service.getNetworkInfo();
      if (mounted) setState(() => network = result);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
  Future<void> allowWifiName() async {
    final status = await Permission.locationWhenInUse.request();
    if (!mounted) return;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else if (status.isGranted) {
      await refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Precise location permission is needed to read your Wi-Fi name.')));
    }
  }

  @override Widget build(BuildContext context) {
    final n = network;
    final connected = n != null && n.connection != 'Disconnected';
    final wifi = n?.connection == 'Wi-Fi';
    final hasSsid = wifi && n!.ssid != 'Unavailable' && n.ssid.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NETSCOPE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 40)),
        Text('BY VEXARYN', style: TextStyle(color: AppTheme.mutedText, fontSize: 15, letterSpacing: 2)),
      ]), actions: [IconButton(tooltip: 'Refresh', onPressed: loading ? null : refresh, icon: const Icon(Icons.refresh_rounded, color: AppTheme.accent)), const SizedBox(width: 6)]),
      body: RefreshIndicator(onRefresh: refresh, child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
        const Text('NETWORK INTELLIGENCE', style: TextStyle(color: AppTheme.accent, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 8),
        const Text('Your network,\nclearly understood.', style: TextStyle(fontSize: 29, height: 1.17, fontWeight: FontWeight.w900, letterSpacing: -.6)),
        const SizedBox(height: 22),
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF164A51), Color(0xFF14263A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF26757A))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .08), borderRadius: BorderRadius.circular(16)),
              child: Icon(wifi ? Icons.wifi_rounded : Icons.language_rounded, color: AppTheme.accent, size: 30)),
              const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(color: (connected ? AppTheme.success : AppTheme.warning).withValues(alpha: .13), borderRadius: BorderRadius.circular(30)),
                child: Text(loading ? 'CHECKING' : connected ? 'CONNECTED' : 'NOT CONNECTED', style: TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w900, color: connected ? AppTheme.success : AppTheme.warning))) ]),
            const SizedBox(height: 24),
            Text(loading ? 'Checking network...' : n?.connection ?? 'Not checked', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(hasSsid ? n!.ssid : wifi ? 'Wi-Fi connected • name unavailable' : 'Connection overview', style: const TextStyle(color: Color(0xFFC3D7DF), fontSize: 13)),
            if (wifi && !hasSsid) Align(alignment: Alignment.centerLeft, child: TextButton.icon(
              onPressed: allowWifiName, icon: const Icon(Icons.location_on_outlined, size: 17),
              label: const Text('Check Wi-Fi name permission'))),
          ]),
        ),
        if (loading) ...[const SizedBox(height: 12), const LinearProgressIndicator()],
        if (error != null) ...[const SizedBox(height: 12), Text(error!, style: const TextStyle(color: AppTheme.warning))],
        const SizedBox(height: 27),
        const SectionHeader('Network details', subtitle: 'Live information from this device'),
        const SizedBox(height: 14),
        GridView.count(crossAxisCount: 2, childAspectRatio: 1.42, crossAxisSpacing: 11, mainAxisSpacing: 11,
          physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, children: [
          InfoCard(label: 'Local IPv4', value: n?.ip ?? '—', icon: Icons.lan_outlined),
          InfoCard(label: 'Gateway', value: n?.gateway ?? '—', icon: Icons.router_outlined),
          InfoCard(label: 'Subnet mask', value: n?.subnet ?? '—', icon: Icons.account_tree_outlined),
          InfoCard(label: 'Broadcast', value: n?.broadcast ?? '—', icon: Icons.cell_tower_outlined),
        ]),
        const SizedBox(height: 26),
        const SectionHeader('Quick guide', subtitle: 'Explore the rest of NetScope'),
        const SizedBox(height: 12),
        const NetPanel(child: Column(children: [
          _GuideRow(icon: Icons.devices_other, title: 'Devices', body: 'Discover hosts responding on your local network'),
          Divider(height: 26, color: AppTheme.border),
          _GuideRow(icon: Icons.speed, title: 'Tools', body: 'Test IP addresses, hostnames and TCP ports'),
        ])),
      ])),
    );
  }
}

class _GuideRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _GuideRow({required this.icon, required this.title, required this.body});
  @override Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppTheme.accent, size: 24), const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 3), Text(body, style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
    ])),
  ]);
}
