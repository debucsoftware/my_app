import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/services/firestore_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestore = FirestoreService();
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _firestore.syncOverdueTasks();
    final stats = await _firestore.getDashboardStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final total = _stats['total'] ?? 1;
    final completed = _stats['completed'] ?? 0;
    final progress = total == 0 ? 0.0 : completed / total;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.dashboard, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(title: l10n.dailyTasks, value: '${_stats['daily'] ?? 0}', color: Colors.blue),
              _StatCard(title: l10n.weeklyTasks, value: '${_stats['weekly'] ?? 0}', color: Colors.indigo),
              _StatCard(title: l10n.completedTasks, value: '${_stats['completed'] ?? 0}', color: Colors.green),
              _StatCard(title: l10n.pendingTasks, value: '${_stats['pending'] ?? 0}', color: Colors.orange),
              _StatCard(title: l10n.overdueTasks, value: '${_stats['overdue'] ?? 0}', color: Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.projectProgress, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: completed.toDouble(),
                            color: Colors.green,
                            title: '${(progress * 100).toStringAsFixed(0)}%',
                            radius: 60,
                          ),
                          PieChartSectionData(
                            value: (total - completed).toDouble().clamp(1, double.infinity),
                            color: Colors.grey.shade300,
                            title: '',
                            radius: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.color});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
