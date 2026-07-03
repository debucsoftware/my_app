import 'package:flutter/material.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/project.dart';
import 'package:istakibim/screens/admin/units_screen.dart';
import 'package:istakibim/services/firestore_service.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProjectDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.add),
      ),
      body: StreamBuilder<List<Project>>(
        stream: firestore.watchProjects(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data!;
          if (projects.isEmpty) {
            return Center(child: Text(l10n.projects));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final p = projects[index];
              return Card(
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.companyName} • ${p.city} • ${p.buildingNumber}\n'
                    '${_statusLabel(l10n, p.status)} • ${p.progress.toStringAsFixed(0)}%',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'units') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UnitsScreen(initialProjectId: p.id),
                          ),
                        );
                      } else if (v == 'delete') {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.confirmDelete),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.no)),
                              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.yes)),
                            ],
                          ),
                        );
                        if (ok == true) await firestore.deleteProject(p.id);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'units', child: Text(l10n.units)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                    ],
                  ),
                  onTap: () => _showProjectDialog(context, project: p),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, ProjectStatus status) {
    return switch (status) {
      ProjectStatus.active => l10n.active,
      ProjectStatus.completed => l10n.completed,
      ProjectStatus.onHold => l10n.onHold,
    };
  }

  Future<void> _showProjectDialog(BuildContext context, {Project? project}) async {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();
    final nameCtrl = TextEditingController(text: project?.name);
    final companyCtrl = TextEditingController(text: project?.companyName);
    final addressCtrl = TextEditingController(text: project?.address);
    final cityCtrl = TextEditingController(text: project?.city);
    final buildingCtrl = TextEditingController(text: project?.buildingNumber);
    var status = project?.status ?? ProjectStatus.active;
    DateTime? startDate = project?.startDate;
    DateTime? endDate = project?.endDate;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(project == null ? l10n.add : l10n.edit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l10n.projects)),
                TextField(controller: companyCtrl, decoration: InputDecoration(labelText: l10n.companyName)),
                TextField(controller: addressCtrl, decoration: InputDecoration(labelText: l10n.address)),
                TextField(controller: cityCtrl, decoration: InputDecoration(labelText: l10n.city)),
                TextField(controller: buildingCtrl, decoration: InputDecoration(labelText: l10n.buildingNumber)),
                DropdownButtonFormField<ProjectStatus>(
                  value: status,
                  decoration: InputDecoration(labelText: l10n.projectStatus),
                  items: ProjectStatus.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(l10n, s))))
                      .toList(),
                  onChanged: (v) => setState(() => status = v ?? ProjectStatus.active),
                ),
                ListTile(
                  title: Text(startDate == null ? l10n.startDate : startDate!.toString().split(' ').first),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      initialDate: startDate ?? DateTime.now(),
                    );
                    if (d != null) setState(() => startDate = d);
                  },
                ),
                ListTile(
                  title: Text(endDate == null ? l10n.endDate : endDate!.toString().split(' ').first),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      initialDate: endDate ?? DateTime.now(),
                    );
                    if (d != null) setState(() => endDate = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () async {
                await firestore.saveProject(Project(
                  id: project?.id ?? '',
                  name: nameCtrl.text,
                  companyName: companyCtrl.text,
                  address: addressCtrl.text,
                  city: cityCtrl.text,
                  buildingNumber: buildingCtrl.text,
                  startDate: startDate,
                  endDate: endDate,
                  status: status,
                  progress: project?.progress ?? 0,
                ));
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
