import 'package:flutter/material.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/work_task.dart';
import 'package:istakibim/services/firestore_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();

    return StreamBuilder<List<WorkTask>>(
      stream: firestore.watchAllTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final tasks = snapshot.data!;
        final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
        final overdue = tasks.where((t) => t.isOverdue).length;
        final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.analytics, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _ReportTile(title: l10n.completedTasks, value: '$completed'),
            _ReportTile(title: l10n.overdueTasks, value: '$overdue'),
            _ReportTile(title: l10n.inProgress, value: '$inProgress'),
            _ReportTile(title: l10n.ongoingProjects, value: '${tasks.map((t) => t.projectId).toSet().length}'),
          ],
        );
      },
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
