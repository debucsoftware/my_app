import 'package:flutter/material.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/models/work_task.dart';
import 'package:istakibim/services/firestore_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _firestore = FirestoreService();
  String? _projectFilter;
  Map<String, dynamic>? _analytics;
  List<AppUser> _workers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final analytics = await _firestore.getWorkerAnalytics();
    final workers = await _firestore.watchWorkers().first;
    if (mounted) {
      setState(() {
        _analytics = analytics;
        _workers = workers;
      });
    }
  }

  String _workerName(String? id) {
    if (id == null) return '-';
    return _workers.where((w) => w.id == id).firstOrNull?.name ?? id;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<WorkTask>>(
      stream: _firestore.watchAllTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || _analytics == null) {
          return const Center(child: CircularProgressIndicator());
        }
        var tasks = snapshot.data!;
        if (_projectFilter != null) {
          tasks = tasks.where((t) => t.projectId == _projectFilter).toList();
        }
        final completed = tasks.where((t) => t.status == TaskStatus.completed || t.status == TaskStatus.approved).length;
        final overdue = tasks.where((t) => t.isOverdue).length;
        final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;

        return RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.analytics, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              StreamBuilder(
                stream: _firestore.watchProjects(),
                builder: (context, projectSnap) {
                  final projects = projectSnap.data ?? [];
                  return DropdownButtonFormField<String?>(
                    value: _projectFilter,
                    decoration: InputDecoration(labelText: l10n.filter),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.projects)),
                      ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                    ],
                    onChanged: (v) => setState(() => _projectFilter = v),
                  );
                },
              ),
              const SizedBox(height: 16),
              _ReportTile(title: l10n.completedTasks, value: '$completed'),
              _ReportTile(title: l10n.overdueTasks, value: '$overdue'),
              _ReportTile(title: l10n.inProgress, value: '$inProgress'),
              _ReportTile(title: l10n.ongoingProjects, value: '${tasks.map((t) => t.projectId).toSet().length}'),
              _ReportTile(title: l10n.fastestWorker, value: _workerName(_analytics!['fastestWorkerId'] as String?)),
              _ReportTile(title: l10n.mostDelayed, value: _workerName(_analytics!['mostDelayedWorkerId'] as String?)),
            ],
          ),
        );
      },
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
