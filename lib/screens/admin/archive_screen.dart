import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/work_task.dart';
import 'package:istakibim/services/firestore_service.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();

    return StreamBuilder<List<WorkTask>>(
      stream: firestore.watchArchivedTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final tasks = snapshot.data!;
        if (tasks.isEmpty) {
          return Center(child: Text(l10n.archive));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final t = tasks[index];
            return Card(
              child: ListTile(
                title: Text(t.title),
                subtitle: Text(
                  '${t.completedAt?.toString().split(' ').first ?? ''} • ${t.durationHours ?? '-'} saat',
                ),
                trailing: Text('${t.photoUrls.length} foto'),
              ),
            );
          },
        );
      },
    );
  }
}
