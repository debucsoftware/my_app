import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/services/auth_service.dart';
import 'package:istakibim/services/firestore_service.dart';

class WorkersScreen extends StatelessWidget {
  const WorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateWorkerDialog(context),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.createWorker),
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: firestore.watchWorkers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final workers = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final w = workers[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(w.name.isNotEmpty ? w.name[0] : '?')),
                  title: Text(w.name),
                  subtitle: Text(w.email),
                  trailing: Switch(
                    value: w.active,
                    onChanged: (v) => firestore.updateUser(w.copyWith(active: v)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateWorkerDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final auth = AuthService();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.createWorker),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l10n.workerName)),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: l10n.email)),
            TextField(controller: passCtrl, decoration: InputDecoration(labelText: l10n.password), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              await auth.createWorkerAccount(
                email: emailCtrl.text,
                password: passCtrl.text,
                name: nameCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
