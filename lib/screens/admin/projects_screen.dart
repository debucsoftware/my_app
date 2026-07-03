import 'package:flutter/material.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/project.dart';
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
                  subtitle: Text('${p.companyName} • ${p.city} • ${p.buildingNumber}'),
                  trailing: Text('${p.progress.toStringAsFixed(0)}%'),
                  onTap: () => _showProjectDialog(context, project: p),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showProjectDialog(BuildContext context, {Project? project}) async {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();
    final nameCtrl = TextEditingController(text: project?.name);
    final companyCtrl = TextEditingController(text: project?.companyName);
    final addressCtrl = TextEditingController(text: project?.address);
    final cityCtrl = TextEditingController(text: project?.city);
    final buildingCtrl = TextEditingController(text: project?.buildingNumber);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
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
                status: project?.status ?? ProjectStatus.active,
                progress: project?.progress ?? 0,
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
