import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/project.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/models/work_task.dart';
import 'package:istakibim/services/firestore_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _firestore = FirestoreService();
  List<Project> _projects = [];
  List<AppUser> _workers = [];
  List<WorkTask> _tasks = [];
  bool _searched = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    final results = await Future.wait([
      _firestore.searchProjects(query),
      _firestore.searchWorkers(query),
      _firestore.searchTasks(query),
    ]);
    setState(() {
      _projects = results[0] as List<Project>;
      _workers = results[1] as List<AppUser>;
      _tasks = results[2] as List<WorkTask>;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    _searched = false;
                    _projects = [];
                    _workers = [];
                    _tasks = [];
                  });
                },
              ),
            ),
            onSubmitted: _search,
          ),
          const SizedBox(height: 16),
          if (_searched) Expanded(
            child: ListView(
              children: [
                if (_projects.isNotEmpty) ...[
                  Text(l10n.projects, style: Theme.of(context).textTheme.titleMedium),
                  ..._projects.map((p) => ListTile(title: Text(p.name), subtitle: Text(p.city))),
                ],
                if (_workers.isNotEmpty) ...[
                  Text(l10n.workers, style: Theme.of(context).textTheme.titleMedium),
                  ..._workers.map((w) => ListTile(title: Text(w.name), subtitle: Text(w.email))),
                ],
                if (_tasks.isNotEmpty) ...[
                  Text(l10n.tasks, style: Theme.of(context).textTheme.titleMedium),
                  ..._tasks.map((t) => ListTile(title: Text(t.title))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
