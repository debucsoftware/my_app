import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/team.dart';
import 'package:istakibim/services/firestore_service.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTeamDialog(context),
        icon: const Icon(Icons.group_add),
        label: Text(l10n.add),
      ),
      body: StreamBuilder<List<Team>>(
        stream: firestore.watchTeams(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final teams = snapshot.data!;
          if (teams.isEmpty) {
            return Center(child: Text(l10n.teams));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.groups),
                  title: Text(team.name),
                  subtitle: Text('${team.memberIds.length} üye'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => firestore.deleteTeam(team.id),
                  ),
                  onTap: () => _showTeamDialog(context, team: team),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showTeamDialog(BuildContext context, {Team? team}) async {
    final l10n = AppLocalizations.of(context)!;
    final firestore = FirestoreService();
    final nameCtrl = TextEditingController(text: team?.name);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(team == null ? l10n.add : l10n.edit),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(labelText: l10n.teams),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              await firestore.saveTeam(Team(
                id: team?.id ?? '',
                name: nameCtrl.text,
                memberIds: team?.memberIds ?? [],
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
