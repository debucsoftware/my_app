import 'package:flutter/material.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/l10n/app_localizations.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (color, label) = switch (status) {
      TaskStatus.completed || TaskStatus.approved => (
          Colors.green,
          l10n.completed,
        ),
      TaskStatus.inProgress => (Colors.orange, l10n.inProgress),
      TaskStatus.overdue || TaskStatus.rejected => (Colors.red, l10n.overdue),
      TaskStatus.pending => (Colors.grey, l10n.pending),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
