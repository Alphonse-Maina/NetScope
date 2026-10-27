import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/network_device.dart';
import '../services/discovery_service.dart';
import '../widgets/net_widgets.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final DiscoveryService discovery = DiscoveryService();
  final List<NetworkDevice> devices = [];

  bool scanning = false;
  bool stopping = false;

  int completed = 0;
  int total = 0;

  String subnet = 'Checking Wi-Fi...';
  String status = 'Ready to scan';
  String? error;

  @override
  void initState() {
    super.initState();
    loadNetwork();
  }

  @override
  void dispose() {
    discovery.cancel();
    super.dispose();
  }

  Future<void> loadNetwork() async {
    try {
      final network = await discovery.getScanTargets();

      if (!mounted) return;

      setState(() {
        subnet = network.subnet;
        total = network.hosts.length;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        subnet = 'Unavailable';
        error = e.toString();
      });
    }
  }

  int ipValue(String ip) {
    return ip
        .split('.')
        .fold<int>(0, (value, part) => (value << 8) | int.parse(part));
  }

  Future<void> startScan() async {
    if (scanning) return;

    setState(() {
      scanning = true;
      stopping = false;
      devices.clear();
      completed = 0;
      error = null;
      status = 'Scanning network...';
    });

    try {
      final network = await discovery.getScanTargets();

      if (!mounted) return;

      setState(() {
        subnet = network.subnet;
        total = network.hosts.length;
      });

      await discovery.scan(
        onDevice: (device) {
          if (!mounted) return;

          setState(() {
            if (!devices.any((item) => item.ip == device.ip)) {
              devices.add(device);
            }

            devices.sort((a, b) {
              if (a.isGateway != b.isGateway) {
                return a.isGateway ? -1 : 1;
              }

              return ipValue(a.ip).compareTo(ipValue(b.ip));
            });
          });
        },
        onProgress: (done, count) {
          if (!mounted) return;

          setState(() {
            completed = done;
            total = count;
          });
        },
      );

      if (!mounted) return;

      setState(() {
        status = stopping ? 'Scan stopped' : 'Scan complete';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        status = 'Scan failed';
      });
    } finally {
      if (mounted) {
        setState(() {
          scanning = false;
          stopping = false;
        });
      }
    }
  }

  void stopScan() {
    if (!scanning || stopping) return;

    discovery.cancel();

    setState(() {
      stopping = true;
      status = 'Stopping scan...';
    });
  }

  void showDetails(NetworkDevice device) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      device.isGateway ? Icons.router : Icons.devices_other,
                      size: 30,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _DetailRow('IPv4 Address', device.ip),
                _DetailRow('Services', device.services),
                _DetailRow('Detection', device.detectionMethod),
                const SizedBox(height: 12),
                const Text(
                  'Device identification is provisional. '
                  'Devices that block network probes may '
                  'not be detected.',
                  style: TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDeviceCard(NetworkDevice device) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NetPanel(
        padding: const EdgeInsets.all(10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          onTap: () => showDetails(device),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.surfaceLight,
            child: Icon(
              device.isGateway ? Icons.router_outlined : Icons.devices_other,
              color: AppTheme.accent,
            ),
          ),
          title: Text(
            device.name,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${device.ip}\n'
              '${device.services}\n'
              '${device.detectionMethod}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.mutedText,
                height: 1.5,
              ),
            ),
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right, color: AppTheme.accent),
        ),
      ),
    );
  }

  Widget buildScanPanel() {
    final double progress = total == 0
        ? 0.0
        : (completed / total).clamp(0.0, 1.0).toDouble();

    return NetPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT SUBNET',
            style: TextStyle(
              color: AppTheme.mutedText,
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subnet,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                scanning ? Icons.radar : Icons.circle_outlined,
                size: 16,
                color: scanning ? AppTheme.accent : AppTheme.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status,
                  style: const TextStyle(color: AppTheme.mutedText),
                ),
              ),
            ],
          ),
          if (scanning) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              color: AppTheme.accent,
              backgroundColor: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(
              '$completed of $total addresses checked',
              style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: scanning ? (stopping ? null : stopScan) : startScan,
              icon: Icon(scanning ? Icons.stop_circle_outlined : Icons.radar),
              label: Text(
                scanning
                    ? (stopping ? 'Stopping...' : 'Stop Scan')
                    : 'Scan Local Network',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Devices',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh subnet',
            onPressed: scanning ? null : loadNetwork,
            icon: const Icon(Icons.refresh, color: AppTheme.accent),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const Text(
            'NETWORK DISCOVERY',
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find what responds.',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
          ),
          const SizedBox(height: 22),

          buildScanPanel(),

          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: AppTheme.warning)),
          ],

          const SizedBox(height: 26),

          SectionHeader(
            'Discovered Devices',
            subtitle: 'Hosts that responded to network probes',
            action: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${devices.length} found',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          if (devices.isEmpty)
            NetPanel(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  children: [
                    const Icon(
                      Icons.devices_other,
                      size: 38,
                      color: AppTheme.mutedText,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      scanning ? 'Discovering devices...' : 'No results yet',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      scanning
                          ? 'Checking addresses on your network.'
                          : 'Tap Scan to discover local devices.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ...devices.map(buildDeviceCard),

          const SizedBox(height: 24),

          const Text(
            'Results are not a complete list of Wi-Fi '
            'clients. Some devices do not respond to '
            'reachability or TCP probes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.mutedText,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.mutedText),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
