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

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

bool _isToday(DateTime value) => _dateOnly(value) == _dateOnly(DateTime.now());

bool _isBeforeToday(DateTime value) =>
    _dateOnly(value).isBefore(_dateOnly(DateTime.now()));

bool _isAfterToday(DateTime value) =>
    _dateOnly(value).isAfter(_dateOnly(DateTime.now()));

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
          final overdueTasks = openTasks
              .where((t) => t.dueDate != null && _isBeforeToday(t.dueDate!))
              .toList();
          final todayTasks = openTasks
              .where((t) => t.dueDate == null || _isToday(t.dueDate!))
              .toList();
          final upcomingTasks = openTasks
              .where((t) => t.dueDate != null && _isAfterToday(t.dueDate!))
              .toList();

          if (overdueTasks.isEmpty && todayTasks.isEmpty && upcomingTasks.isEmpty) {
            return Center(child: Text(l10n.noAssignedTasks));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (overdueTasks.isNotEmpty) ...[
                _SectionTitle(title: l10n.overdueTasks),
                ...overdueTasks.map(
                  (task) => _WorkerTaskCard(task: task, user: user, highlight: true),
                ),
                const SizedBox(height: 16),
              ],
              if (todayTasks.isNotEmpty) ...[
                _SectionTitle(title: l10n.todayTasks),
                ...todayTasks.map(
                  (task) => _WorkerTaskCard(task: task, user: user),
                ),
                const SizedBox(height: 16),
              ],
              if (upcomingTasks.isNotEmpty) ...[
                _SectionTitle(title: l10n.upcomingTasks),
                ...upcomingTasks.map(
                  (task) => _WorkerTaskCard(task: task, user: user),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _WorkerTaskCard extends StatelessWidget {
  const _WorkerTaskCard({
    required this.task,
    required this.user,
    this.highlight = false,
  });

  final WorkTask task;
  final AppUser user;
  final bool highlight;

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
          color: highlight ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.35) : null,
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
