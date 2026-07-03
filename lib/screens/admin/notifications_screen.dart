import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_notification.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/services/firestore_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: StreamBuilder<List<AppNotification>>(
        stream: firestore.watchUserNotifications(user.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(child: Text(l10n.notifications));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final n = items[index];
              return Card(
                color: n.read ? null : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: ListTile(
                  leading: Icon(_iconForType(n.type)),
                  title: Text(n.title),
                  subtitle: Text(n.body),
                  trailing: Text(
                    n.createdAt?.toString().split(' ').first ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'new_task' => Icons.assignment,
      'task_completed' => Icons.check_circle,
      'task_overdue' => Icons.warning,
      _ => Icons.notifications,
    };
  }
}
