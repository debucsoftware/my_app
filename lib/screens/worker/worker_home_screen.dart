import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/models/project.dart';
import 'package:istakibim/models/unit.dart';
import 'package:istakibim/models/work_task.dart';
import 'package:istakibim/screens/worker/task_detail_screen.dart';
import 'package:istakibim/services/auth_service.dart';
import 'package:istakibim/services/firestore_service.dart';
import 'package:istakibim/widgets/language_selector.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

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
          if (!taskSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final todayTasks = taskSnap.data!.where((t) {
            if (t.dueDate == null) return true;
            final d = t.dueDate!;
            return !d.isBefore(todayStart) &&
                d.isBefore(todayStart.add(const Duration(days: 1)));
          }).toList();

          if (todayTasks.isEmpty) {
            return Center(child: Text(l10n.noTasksToday));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: todayTasks.length,
            itemBuilder: (context, index) {
              final task = todayTasks[index];
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
                  Text(l10n.todayTasks, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${l10n.projectLabel}: ${project?.name ?? '-'}'),
                  Text('${l10n.houseLabel}: ${unit?.houseNumber ?? '-'}'),
                  const Divider(),
                  Text(l10n.workItems, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...task.checklist.map((item) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.title),
                        value: item.completed,
                        onChanged: null,
                      )),
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
