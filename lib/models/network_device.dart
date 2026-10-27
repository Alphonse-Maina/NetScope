class NetworkDevice {
  final String ip;
  final List<int> openPorts;
  final bool isGateway;
  final bool reachableByProbe;

  const NetworkDevice({
    required this.ip,
    required this.openPorts,
    this.isGateway = false,
    this.reachableByProbe = false,
  });

  String get name => isGateway ? 'Gateway / Router' : 'Network Device';

  String get services => openPorts.isEmpty
      ? 'No tested TCP ports open'
      : 'TCP ${openPorts.join(", ")}';

  String get detectionMethod {
    if (reachableByProbe && openPorts.isNotEmpty) {
      return 'Reachability + TCP';
    }
    if (reachableByProbe) {
      return 'Reachability probe';
    }
    return 'TCP connection';
  }
}
