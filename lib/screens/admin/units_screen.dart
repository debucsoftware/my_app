import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/project.dart';
import 'package:istakibim/models/unit.dart';
import 'package:istakibim/services/firestore_service.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key, this.initialProjectId});

  final String? initialProjectId;

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  final _firestore = FirestoreService();
  String? _projectId;

  @override
  void initState() {
    super.initState();
    _projectId = widget.initialProjectId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.units)),
      floatingActionButton: _projectId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showUnitDialog(context),
              icon: const Icon(Icons.add_home),
              label: Text(l10n.add),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<List<Project>>(
              stream: _firestore.watchProjects(),
              builder: (context, snapshot) {
                final projects = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  value: _projectId,
                  decoration: InputDecoration(labelText: l10n.projectLabel),
                  items: projects
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _projectId = v),
                );
              },
            ),
          ),
          Expanded(
            child: _projectId == null
                ? Center(child: Text(l10n.projectLabel))
                : StreamBuilder<List<Unit>>(
                    stream: _firestore.watchUnits(_projectId!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final units = snapshot.data!;
                      if (units.isEmpty) {
                        return Center(child: Text(l10n.units));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: units.length,
                        itemBuilder: (context, index) {
                          final u = units[index];
                          return Card(
                            child: ListTile(
                              title: Text('${l10n.houseNumber}: ${u.houseNumber}'),
                              subtitle: Text(
                                '${l10n.apartmentNumber}: ${u.apartmentNumber} • '
                                '${l10n.floor}: ${u.floor ?? '-'} • '
                                '${l10n.block}: ${u.block ?? '-'}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _firestore.deleteUnit(u.id),
                              ),
                              onTap: () => _showUnitDialog(context, unit: u),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUnitDialog(BuildContext context, {Unit? unit}) async {
    final l10n = AppLocalizations.of(context)!;
    final houseCtrl = TextEditingController(text: unit?.houseNumber);
    final aptCtrl = TextEditingController(text: unit?.apartmentNumber);
    final floorCtrl = TextEditingController(text: unit?.floor);
    final blockCtrl = TextEditingController(text: unit?.block);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(unit == null ? l10n.add : l10n.edit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: houseCtrl, decoration: InputDecoration(labelText: l10n.houseNumber)),
            TextField(controller: aptCtrl, decoration: InputDecoration(labelText: l10n.apartmentNumber)),
            TextField(controller: floorCtrl, decoration: InputDecoration(labelText: l10n.floor)),
            TextField(controller: blockCtrl, decoration: InputDecoration(labelText: l10n.block)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              await _firestore.saveUnit(Unit(
                id: unit?.id ?? '',
                projectId: _projectId!,
                houseNumber: houseCtrl.text,
                apartmentNumber: aptCtrl.text,
                floor: floorCtrl.text.isEmpty ? null : floorCtrl.text,
                block: blockCtrl.text.isEmpty ? null : blockCtrl.text,
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
