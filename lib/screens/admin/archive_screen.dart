import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/work_task.dart';
import 'package:istakibim/services/firestore_service.dart';
import 'package:istakibim/widgets/base64_image.dart';

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
                  '${t.completedAt?.toString().split(' ').first ?? ''} • '
                  '${t.durationHours?.toStringAsFixed(1) ?? '-'} saat',
                ),
                trailing: Text('${t.photoUrls.length} foto'),
                onTap: () => _showDetail(context, t),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetail(BuildContext context, WorkTask task) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.workerNote != null) Text('${l10n.addNote}: ${task.workerNote}'),
              if (task.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...task.photoUrls.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Base64Image(base64: p, height: 160),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
        ],
      ),
    );
  }
}
