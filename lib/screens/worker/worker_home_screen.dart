import 'package:flutter/material.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/models/project.dart';
import 'package:istakibim/models/unit.dart';
import 'package:istakibim/models/work_task.dart';
import 'package:istakibim/screens/worker/task_detail_screen.dart';
import 'package:istakibim/services/auth_service.dart';
import 'package:istakibim/services/firestore_service.dart';
import 'package:istakibim/widgets/language_selector.dart';

bool _isOpenTask(WorkTask task) {
  return task.status != TaskStatus.completed &&
      task.status != TaskStatus.approved &&
      task.status != TaskStatus.rejected;
}

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.welcomeWorker),
        actions: [
          const LanguageSelector(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<WorkTask>>(
        stream: firestore.watchWorkerTasks(user.id),
        builder: (context, taskSnap) {
          if (taskSnap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  taskSnap.error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          }
          if (!taskSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final openTasks = taskSnap.data!.where(_isOpenTask).toList();

          if (openTasks.isEmpty) {
            return Center(child: Text(l10n.noAssignedTasks));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: openTasks.length,
            itemBuilder: (context, index) {
              final task = openTasks[index];
              return _WorkerTaskCard(task: task, user: user);
            },
          );
        },
      ),
    );
  }
}

class _WorkerTaskCard extends StatelessWidget {
  const _WorkerTaskCard({required this.task, required this.user});

  final WorkTask task;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();

    return FutureBuilder<(Project?, Unit?)>(
      future: _loadMeta(firestore),
      builder: (context, snap) {
        final project = snap.data?.$1;
        final unit = snap.data?.$2;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(task: task, user: user),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.dueDate}: ${task.dueDate!.toString().split(' ').first}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text('${l10n.projectLabel}: ${project?.name ?? '-'}'),
                  Text('${l10n.houseLabel}: ${unit?.houseNumber ?? '-'}'),
                  if (task.checklist.isNotEmpty) ...[
                    const Divider(),
                    Text(l10n.workItems, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...task.checklist.map((item) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.title),
                          value: item.completed,
                          onChanged: null,
                        )),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<(Project?, Unit?)> _loadMeta(FirestoreService firestore) async {
    final projects = await firestore.watchProjects().first;
    final project = projects.where((p) => p.id == task.projectId).firstOrNull;
    final units = await firestore.watchUnits(task.projectId).first;
    final unit = units.where((u) => u.id == task.unitId).firstOrNull;
    return (project, unit);
  }
}
