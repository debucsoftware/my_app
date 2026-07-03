import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/models/worker_invite.dart';
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
        onPressed: () => _showInviteWorkerDialog(context),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.inviteWorker),
      ),
      body: StreamBuilder<List<WorkerInvite>>(
        stream: firestore.watchWorkerInvites(),
        builder: (context, inviteSnap) {
          return StreamBuilder<List<AppUser>>(
            stream: firestore.watchWorkers(),
            builder: (context, workerSnap) {
              if (!inviteSnap.hasData || !workerSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final invites = inviteSnap.data!;
              final workers = workerSnap.data!;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (invites.isNotEmpty) ...[
                    Text(l10n.pendingSetup, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...invites.map((inv) => Card(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: ListTile(
                            leading: const Icon(Icons.mail_outline),
                            title: Text(inv.name),
                            subtitle: Text(inv.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => AuthService().deleteWorkerInvite(inv.email),
                            ),
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],
                  Text(l10n.workers, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (workers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.workers),
                    ),
                  ...workers.map((w) => Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text(w.name.isNotEmpty ? w.name[0] : '?')),
                          title: Text(w.name),
                          subtitle: Text(w.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: w.active,
                                onChanged: (v) => firestore.updateUser(w.copyWith(active: v)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDelete(context, w),
                              ),
                            ],
                          ),
                          onTap: () => _showEditWorkerDialog(context, w),
                        ),
                      )),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppUser worker) async {
    final l10n = AppLocalizations.of(context)!;
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
    if (ok == true) {
      await FirestoreService().deleteUser(worker.id);
    }
  }

  Future<void> _showEditWorkerDialog(BuildContext context, AppUser worker) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: worker.name);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.edit),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(labelText: l10n.workerName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              await FirestoreService().updateUser(worker.copyWith(name: nameCtrl.text));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _showInviteWorkerDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final auth = AuthService();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.inviteWorker),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l10n.workerName)),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: l10n.email),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              try {
                await auth.inviteWorker(
                  email: emailCtrl.text,
                  name: nameCtrl.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
