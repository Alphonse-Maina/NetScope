import 'dart:io';
import 'dart:math';

import 'package:network_info_plus/network_info_plus.dart';
import 'reachability_service.dart';
import '../models/network_device.dart';

class DiscoveryService {
  final NetworkInfo _info = NetworkInfo();
  final ReachabilityService reachability = ReachabilityService();

  // Common services: SSH, HTTP, HTTPS, SMB and RDP.
  static const List<int> ports = [22, 80, 443, 445, 3389, 8080];

  // Limit concurrent connections to avoid flooding the network.
  static const int batchSize = 12;

  // Stop scanning after this number of hosts.
  static const int maxHosts = 254;

  bool _cancelled = false;

  void cancel() {
    _cancelled = true;
  }

  int? _ipv4ToInt(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return null;

    var result = 0;

    for (final part in parts) {
      final number = int.tryParse(part);
      if (number == null || number < 0 || number > 255) {
        return null;
      }
      result = (result << 8) | number;
    }

    return result;
  }

  String _intToIpv4(int ip) {
    return [
      (ip >> 24) & 255,
      (ip >> 16) & 255,
      (ip >> 8) & 255,
      ip & 255,
    ].join('.');
  }

  // Only RFC1918 private address space is eligible.
  bool _isPrivate(int ip) {
    final a = (ip >> 24) & 255;
    final b = (ip >> 16) & 255;

    return a == 10 ||
        (a == 172 && b >= 16 && b <= 31) ||
        (a == 192 && b == 168);
  }

  Future<({String subnet, List<String> hosts, String? gateway})>
  getScanTargets() async {
    final ipText = await _info.getWifiIP();
    final maskText = await _info.getWifiSubmask();
    final gatewayText = await _info.getWifiGatewayIP();

    if (ipText == null || maskText == null) {
      throw Exception('Connect to Wi-Fi before scanning.');
    }

    final ip = _ipv4ToInt(ipText);
    final mask = _ipv4ToInt(maskText);

    if (ip == null || mask == null || !_isPrivate(ip)) {
      throw Exception('A valid private Wi-Fi IPv4 address is required.');
    }

    final hostMask = (~mask) & 0xFFFFFFFF;

    // Validate a contiguous subnet mask.
    if ((hostMask & (hostMask + 1)) != 0) {
      throw Exception('Invalid Wi-Fi subnet mask.');
    }

    final network = ip & mask;
    final broadcast = network | hostMask;
    final hostCount = max(0, broadcast - network - 1);

    if (hostCount > maxHosts) {
      throw Exception(
        'This subnet has $hostCount hosts. '
        'v0.2 supports at most 254 hosts to keep scanning bounded.',
      );
    }

    final targets = <String>[];

    for (var address = network + 1; address < broadcast; address++) {
      if (address != ip) {
        targets.add(_intToIpv4(address));
      }
    }

    // Skip large networks for now rather than silently
    // scanning only part of them.
    final prefix = mask
        .toRadixString(2)
        .padLeft(32, '0')
        .split('')
        .where((digit) => digit == '1')
        .length;

    return (
      subnet: '${_intToIpv4(network)}/$prefix',
      hosts: targets,
      gateway: gatewayText,
    );
  }

  Future<List<int>> _checkHost(String ip) async {
    final openPorts = <int>[];

    for (final port in ports) {
      if (_cancelled) break;

      Socket? socket;
      try {
        socket = await Socket.connect(
          ip,
          port,
          timeout: const Duration(milliseconds: 450),
        );
        openPorts.add(port);
      } catch (_) {
        // A failed TCP connection does not prove the host is offline.
      } finally {
        socket?.destroy();
      }
    }

    return openPorts;
  }

  Future<void> scan({
    required void Function(NetworkDevice device) onDevice,
    required void Function(int completed, int total) onProgress,
  }) async {
    _cancelled = false;

    final network = await getScanTargets();
    final targets = network.hosts;

    var completed = 0;

    for (var i = 0; i < targets.length; i += batchSize) {
      if (_cancelled) break;

      final batch = targets.skip(i).take(batchSize).toList();

      await Future.wait(
        batch.map((ip) async {
          if (_cancelled) return;

          final isReachable = await reachability.isReachable(ip);

          if (_cancelled) return;

          final openPorts = await _checkHost(ip);

          if (_cancelled) return;

          final isGateway = ip == network.gateway;

          if (isReachable || openPorts.isNotEmpty) {
            onDevice(
              NetworkDevice(
                ip: ip,
                openPorts: openPorts,
                isGateway: isGateway,
                reachableByProbe: isReachable,
              ),
            );
          }

          completed++;
          onProgress(completed, targets.length);
        }),
      );
    }
  }
}
