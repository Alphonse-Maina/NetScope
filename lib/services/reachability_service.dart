import 'package:flutter/services.dart';

class ReachabilityService {
  static const MethodChannel _channel = MethodChannel(
    'ke.co.vexaryn.netscope/network',
  );

  Future<bool> isReachable(String ip) async {
    try {
      final reachable = await _channel.invokeMethod<bool>('isHostReachable', {
        'ip': ip,
        'timeout': 700,
      });

      return reachable ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
