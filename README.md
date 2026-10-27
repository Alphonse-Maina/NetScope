# NetScope

**Network Intelligence, Simplified.**

NetScope is an Android network discovery and diagnostic application built with Flutter. It helps users understand their local network, discover reachable devices, test connections, and inspect network information through a clean, modern interface.

Developed by **Vexaryn**.

---

## Features

### Network Overview
- Display the current network connection type.
- View local IPv4 address, gateway, and subnet mask.
- Display Wi-Fi information where supported and permitted.
- Refresh network information instantly.

### Device Discovery
- Scan supported private IPv4 subnets for reachable devices.
- Discover hosts using TCP connectivity checks and Android reachability probes.
- Identify responding TCP ports and common services.
- Display device IP addresses and detection methods.
- Inspect individual devices through a details panel.
- Monitor scan progress and cancel ongoing scans.

### Network Diagnostics
- Test TCP connectivity to IP addresses and hostnames.
- Measure TCP connection setup time.
- Diagnose service availability on specific ports.
- Test common ports including SSH (22), HTTP (80), HTTPS (443), and alternative HTTP (8080).

### Modern User Interface
- Dark-themed interface with cyan accents.
- Four main sections: Overview, Devices, Tools, and Settings.
- Live network data and connection results.
- Responsive cards and intuitive navigation.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application framework |
| Dart | Application logic and UI |
| Kotlin | Android-native network reachability checks |
| network_info_plus | Wi-Fi and network information |
| connectivity_plus | Network connectivity information |
| permission_handler | Android permission management |
| Dart Socket API | TCP connectivity diagnostics |

NetScope is designed as a local-first application. Core network diagnostics do not require user registration or a cloud backend.

---

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK
- Android SDK
- Android device or emulator
- Android Studio or VS Code

### Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/netscope.git
cd netscope
```

Replace `YOUR_USERNAME` with the actual GitHub account or organization hosting the project.

### Install Dependencies

```bash
flutter pub get
```

### Run the Application

```bash
flutter devices
flutter run
```

For best results, use a physical Android device connected to Wi-Fi.

---

## Build an APK

Generate a release APK:

```bash
flutter build apk --release
```

The APK will be generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Install it using ADB:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Release APKs must be appropriately signed. Future public releases should use a stable release signing key.

---

## Project Structure

```text
lib/
├── main.dart
├── core/
│   └── theme/
├── models/
│   └── network_device.dart
├── services/
│   ├── network_service.dart
│   ├── discovery_service.dart
│   └── reachability_service.dart
├── screens/
│   ├── app_shell.dart
│   ├── home_screen.dart
│   ├── devices_screen.dart
│   ├── tools_screen.dart
│   └── settings_screen.dart
└── widgets/
    └── net_widgets.dart
```

---

## Known Limitations

NetScope is currently under active development.

- Device discovery does not guarantee detection of every connected Wi-Fi client.
- Some devices block ICMP and TCP probes.
- Wi-Fi SSID access may be restricted by Android permissions or device firmware.
- Larger subnets are not supported by the initial discovery engine.
- TCP setup time is not the same as ICMP ping latency.
- Initial development and testing focus on Android.

---

## Roadmap

- [x] Network overview dashboard
- [x] TCP connectivity diagnostics
- [x] Basic local network discovery
- [x] Android-native reachability probing
- [x] Unified four-tab interface
- [ ] Hostname resolution
- [ ] Custom device names
- [ ] Network topology visualization
- [ ] DNS lookup tools
- [ ] Expanded port inspection
- [ ] Scan history and saved networks
- [ ] Exportable network reports

---

## Security and Privacy

NetScope is intended for diagnosing networks owned by the user or networks where the user has explicit authorization.

Core network operations are performed locally. The application does not require an account or a remote backend.

Network discovery results may be incomplete. A host that does not respond to a probe is not necessarily offline.

---

## Contributing

Suggestions, bug reports, and contributions are welcome through GitHub Issues and Pull Requests.

## License

License not yet specified. A license file will be added when the distribution terms are finalized.

---

## About Vexaryn

**Vexaryn** is a technology brand focused on building practical applications, creative software, and engineering tools.

NetScope is part of the Vexaryn application collection.

Website: https://vexaryn.co.ke

**Built with Flutter. Engineered by Vexaryn.**
