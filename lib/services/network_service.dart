import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkSnapshot {
  final String connection;
  final String ip;
  final String gateway;
  final String subnet;
  final String broadcast;
  final String ssid;

  const NetworkSnapshot({
    required this.connection,
    required this.ip,
    required this.gateway,
    required this.subnet,
    required this.broadcast,
    required this.ssid,
  });
}

class TcpTestResult {
  final bool successful;
  final String message;
  final int? latencyMs;

  const TcpTestResult({
    required this.successful,
    required this.message,
    this.latencyMs,
  });
}

class NetworkService {
  final _info = NetworkInfo();
  final _connectivity = Connectivity();

  Future<NetworkSnapshot> getNetworkInfo() async {
    final connections = await _connectivity.checkConnectivity();

    String connection = 'Disconnected';

    if (connections.contains(ConnectivityResult.wifi)) {
      connection = 'Wi-Fi';
    } else if (connections.contains(ConnectivityResult.ethernet)) {
      connection = 'Ethernet';
    } else if (connections.contains(ConnectivityResult.mobile)) {
      connection = 'Mobile data';
    } else if (!connections.contains(ConnectivityResult.none)) {
      connection = 'Other network';
    }

    // Wi-Fi details can be unavailable on non-Wi-Fi connections.
    if (connection != 'Wi-Fi') {
      return NetworkSnapshot(
        connection: connection,
        ip: 'Unavailable',
        gateway: 'Unavailable',
        subnet: 'Unavailable',
        broadcast: 'Unavailable',
        ssid: 'Unavailable',
      );
    }

    Future<String> safeRead(Future<String?> Function() read) async {
      try {
        final value = await read();
        if (value == null || value.isEmpty) {
          return 'Unavailable';
        }
        return value.replaceAll('"', '');
      } catch (_) {
        return 'Unavailable';
      }
    }

    final results = await Future.wait([
      safeRead(_info.getWifiIP),
      safeRead(_info.getWifiGatewayIP),
      safeRead(_info.getWifiSubmask),
      safeRead(_info.getWifiBroadcast),
      () async {
        try {
          final name = await _info.getWifiName();
          print('NETSCOPE DEBUG: Wi-Fi SSID = $name');
          return name == null || name.isEmpty
              ? 'Unavailable'
              : name.replaceAll('"', '');
        } catch (e) {
          print('NETSCOPE DEBUG: SSID error = $e');
          return 'Unavailable';
        }
      }(),
    ]);

    return NetworkSnapshot(
      connection: connection,
      ip: results[0],
      gateway: results[1],
      subnet: results[2],
      broadcast: results[3],
      ssid: results[4],
    );
  }

  Future<TcpTestResult> testTcp(String host, int port) async {
    if (host.trim().isEmpty || port < 1 || port > 65535) {
      return const TcpTestResult(
        successful: false,
        message: 'Enter a valid host and port (1–65535).',
      );
    }

    final stopwatch = Stopwatch()..start();
    Socket? socket;

    try {
      socket = await Socket.connect(
        host.trim(),
        port,
        timeout: const Duration(seconds: 5),
      );

      stopwatch.stop();

      return TcpTestResult(
        successful: true,
        message: 'TCP connection established',
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } on TimeoutException {
      return const TcpTestResult(
        successful: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return TcpTestResult(
        successful: false,
        message: 'Connection failed: ${e.message}',
      );
    } catch (e) {
      return TcpTestResult(successful: false, message: 'Error: $e');
    } finally {
      socket?.destroy();
    }
  }
}
