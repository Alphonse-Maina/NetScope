import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/network_service.dart';
import '../widgets/net_widgets.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});
  @override State<ToolsScreen> createState() => _ToolsScreenState();
}
class _ToolsScreenState extends State<ToolsScreen> {
  final service = NetworkService();
  final host = TextEditingController(text: '1.1.1.1');
  final port = TextEditingController(text: '443');
  TcpTestResult? result;
  bool testing = false;
  @override void dispose() { host.dispose(); port.dispose(); super.dispose(); }
  Future<void> run() async {
    if (testing) return;
    final p = int.tryParse(port.text.trim());
    if (p == null || p < 1 || p > 65535) {
      setState(() => result = const TcpTestResult(successful: false, message: 'Enter a port between 1 and 65535.'));
      return;
    }
    setState(() { testing = true; result = null; });
    try {
      final r = await service.testTcp(host.text.trim(), p);
      if (mounted) setState(() => result = r);
    } catch (e) {
      if (mounted) setState(() => result = TcpTestResult(successful: false, message: '$e'));
    } finally {
      if (mounted) setState(() => testing = false);
    }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Diagnostics', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40))),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('NETWORK TOOLKIT', style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
      const SizedBox(height: 8),
      const Text('Test a connection.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      const Text('TCP checks whether a service accepts connections. This is not an ICMP ping.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
      const SizedBox(height: 24),
      NetPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.cable, color: AppTheme.accent), SizedBox(width: 10), Text('TCP Connectivity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 22),
        TextField(controller: host, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'IP or hostname', prefixIcon: Icon(Icons.language))),
        const SizedBox(height: 12),
        TextField(controller: port, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'TCP port', prefixIcon: Icon(Icons.numbers))),
        const SizedBox(height: 16),
        Row(children: [for (final p in [22, 80, 443, 8080]) ...[
          Expanded(child: Padding(padding: const EdgeInsets.only(right: 6), child: OutlinedButton(
            onPressed: testing ? null : () => setState(() => port.text = '$p'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 3), side: const BorderSide(color: AppTheme.border)),
            child: Text('$p', style: const TextStyle(fontSize: 12))))),
        ]]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: testing ? null : run,
          icon: testing ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.play_arrow_rounded),
          label: Text(testing ? 'Testing...' : 'Run TCP test'))),
      ])),
      if (result != null) ...[
        const SizedBox(height: 18),
        NetPanel(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(result!.successful ? Icons.check_circle : Icons.error_outline,
            color: result!.successful ? AppTheme.success : AppTheme.warning, size: 28),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(result!.successful ? 'Connection established' : 'Connection unsuccessful', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 5), Text(result!.message, style: const TextStyle(color: AppTheme.mutedText)),
            if (result!.latencyMs != null) ...[
              const SizedBox(height: 12), Text('${result!.latencyMs} ms', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppTheme.accent)),
              const Text('TCP connection setup time', style: TextStyle(fontSize: 11, color: AppTheme.mutedText)),
            ]
          ])),
        ])),
      ],
      const SizedBox(height: 26),
      const SectionHeader('Understanding results'),
      const SizedBox(height: 12),
      const NetPanel(child: Text('A successful TCP test confirms the selected service accepted a connection. A failed test does not prove that the device is offline.',
        style: TextStyle(color: AppTheme.mutedText, height: 1.5))),
    ]),
  );
}
