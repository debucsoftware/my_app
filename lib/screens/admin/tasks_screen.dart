import 'package:flutter/material.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_notification.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/models/checklist_item.dart';
import 'package:istakibim/models/project.dart';
import 'package:istakibim/models/unit.dart';
import 'package:istakibim/models/work_task.dart';
import 'package:istakibim/services/firestore_service.dart';
import 'package:istakibim/widgets/base64_image.dart';
import 'package:istakibim/widgets/status_badge.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(context),
        icon: const Icon(Icons.add_task),
        label: Text(l10n.newTask),
      ),
      body: StreamBuilder<List<WorkTask>>(
        stream: firestore.watchAllTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final status = task.isOverdue ? TaskStatus.overdue : task.status;
              return Card(
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description ?? ''),
                  trailing: StatusBadge(status: status),
                  onTap: () => _showApprovalDialog(context, task),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showApprovalDialog(BuildContext context, WorkTask task) async {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();
    if (task.status != TaskStatus.completed) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.workerNote != null) Text(task.workerNote!),
              if (task.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: task.photoUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => Base64Image(base64: task.photoUrls[i], width: 100),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await firestore.rejectTask(task.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.reject),
          ),
          FilledButton(
            onPressed: () async {
              await firestore.approveTask(task.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.approve),
          ),
        ],
      ),
    );
  }

  Future<void> _showTaskDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final checklistCtrl = TextEditingController();
    Project? selectedProject;
    Unit? selectedUnit;
    List<AppUser> workers = [];
    final selectedWorkers = <String>{};
    DateTime? dueDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final roomCtrl = TextEditingController();
    var priority = TaskPriority.medium;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.newTask),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<List<Project>>(
                    stream: firestore.watchProjects(),
                    builder: (c, s) {
                      if (s.hasError) {
                        return Text(
                          s.error.toString(),
                          style: TextStyle(color: Theme.of(c).colorScheme.error),
                        );
                      }
                      if (!s.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        );
                      }
                      final projects = s.data!;
                      if (projects.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Henüz proje yok. Önce ${l10n.projects} sekmesinden proje ekleyin.',
                            style: TextStyle(color: Theme.of(c).colorScheme.error),
                          ),
                        );
                      }
                      final validSelection = selectedProject != null &&
                          projects.any((p) => p.id == selectedProject!.id);
                      return DropdownButtonFormField<Project>(
                        value: validSelection ? selectedProject : null,
                        decoration: InputDecoration(labelText: l10n.projectLabel),
                        items: projects
                            .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                            .toList(),
                        onChanged: (p) => setDialogState(() {
                          selectedProject = p;
                          selectedUnit = null;
                        }),
                      );
                    },
                  ),
                  if (selectedProject != null)
                    StreamBuilder<List<Unit>>(
                      stream: firestore.watchUnits(selectedProject!.id),
                      builder: (c, s) {
                        if (!s.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(),
                          );
                        }
                        final units = s.data!;
                        if (units.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Bu projede ev/daire yok. Önce ${l10n.units} sekmesinden ekleyin.',
                              style: TextStyle(color: Theme.of(c).colorScheme.error),
                            ),
                          );
                        }
                        final validUnit = selectedUnit != null &&
                            units.any((u) => u.id == selectedUnit!.id);
                        return DropdownButtonFormField<Unit>(
                          value: validUnit ? selectedUnit : null,
                          decoration: InputDecoration(labelText: l10n.units),
                          items: units
                              .map((u) => DropdownMenuItem(value: u, child: Text(u.displayLabel)))
                              .toList(),
                          onChanged: (u) => setDialogState(() => selectedUnit = u),
                        );
                      },
                    ),
                  TextField(controller: titleCtrl, decoration: InputDecoration(labelText: l10n.tasks)),
                  TextField(controller: descCtrl, decoration: InputDecoration(labelText: l10n.description)),
                  TextField(controller: roomCtrl, decoration: InputDecoration(labelText: l10n.room)),
                  DropdownButtonFormField<TaskPriority>(
                    value: priority,
                    decoration: InputDecoration(labelText: l10n.priority),
                    items: TaskPriority.values.map((p) {
                      final label = switch (p) {
                        TaskPriority.low => l10n.low,
                        TaskPriority.medium => l10n.medium,
                        TaskPriority.high => l10n.high,
                      };
                      return DropdownMenuItem(value: p, child: Text(label));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => priority = v ?? TaskPriority.medium),
                  ),
                  TextField(
                    controller: checklistCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.addChecklistItem,
                      hintText: 'Alçı, Boya, Süpürgelik',
                    ),
                  ),
                  ListTile(
                    title: Text(dueDate == null ? l10n.dueDate : dueDate!.toString().split(' ').first),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: DateTime.now(),
                      );
                      if (d != null) setDialogState(() => dueDate = d);
                    },
                  ),
                  StreamBuilder<List<AppUser>>(
                    stream: firestore.watchWorkers(),
                    builder: (c, s) {
                      workers = s.data ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.assignWorkers),
                          ...workers.map((w) => CheckboxListTile(
                                title: Text(w.name),
                                value: selectedWorkers.contains(w.id),
                                onChanged: (v) {
                                  setDialogState(() {
                                    if (v == true) {
                                      selectedWorkers.add(w.id);
                                    } else {
                                      selectedWorkers.remove(w.id);
                                    }
                                  });
                                },
                              )),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () async {
                if (selectedProject == null || selectedUnit == null) return;
                if (selectedWorkers.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(l10n.assignWorkers)),
                  );
                  return;
                }
                final normalizedDueDate = dueDate == null
                    ? null
                    : DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
                final items = checklistCtrl.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .map((e) => ChecklistItem(title: e))
                    .toList();
                final task = WorkTask(
                  id: '',
                  projectId: selectedProject!.id,
                  unitId: selectedUnit!.id,
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  assignedWorkerIds: selectedWorkers.toList(),
                  dueDate: normalizedDueDate,
                  priority: priority,
                  room: roomCtrl.text.isEmpty ? null : roomCtrl.text,
                  checklist: items,
                );
                final taskId = await firestore.saveTask(task);
                for (final workerId in selectedWorkers) {
                  await firestore.sendNotification(AppNotification(
                    id: '',
                    userId: workerId,
                    title: l10n.newTask,
                    body: titleCtrl.text,
                    type: 'new_task',
                    taskId: taskId,
                  ));
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
