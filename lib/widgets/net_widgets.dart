import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  const SectionHeader(this.title, {super.key, this.subtitle, this.action});
  @override Widget build(BuildContext context) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: const TextStyle(color: AppTheme.mutedText, fontSize: 12))],
    ])), if (action != null) action!,
  ]);
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const InfoCard({super.key, required this.label, required this.value, required this.icon});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 17, color: AppTheme.accent), const Spacer(), const Icon(Icons.circle, size: 6, color: AppTheme.success)]),
      const SizedBox(height: 16),
      Text(label, style: const TextStyle(color: AppTheme.mutedText, fontSize: 11)),
      const SizedBox(height: 5),
      Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
    ]),
  );
}

class NetPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const NetPanel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  @override Widget build(BuildContext context) => Container(
    width: double.infinity, padding: padding,
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
    child: child,
  );
}
