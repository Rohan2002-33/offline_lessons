import 'package:flutter/material.dart';

class SyncStatusBanner extends StatelessWidget {
  final bool isOnline;
  final int pendingCount;
  const SyncStatusBanner({super.key, required this.isOnline, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    if (isOnline && pendingCount == 0) return const SizedBox.shrink();
    final color = isOnline ? Colors.orange : Colors.grey.shade700;
    final text = !isOnline
        ? 'Offline — changes will sync when reconnected'
        : 'Syncing $pendingCount pending change(s)...';
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Icon(isOnline ? Icons.sync : Icons.cloud_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}