import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/screens/admin/analytics_screen.dart';
import 'package:istakibim/screens/admin/archive_screen.dart';
import 'package:istakibim/screens/admin/dashboard_screen.dart';
import 'package:istakibim/screens/admin/projects_screen.dart';
import 'package:istakibim/screens/admin/search_screen.dart';
import 'package:istakibim/screens/admin/tasks_screen.dart';
import 'package:istakibim/screens/admin/workers_screen.dart';
import 'package:istakibim/services/auth_service.dart';
import 'package:istakibim/widgets/language_selector.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.user});

  final AppUser user;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final pages = [
      const DashboardScreen(),
      const ProjectsScreen(),
      const WorkersScreen(),
      const TasksScreen(),
      const AnalyticsScreen(),
      const ArchiveScreen(),
      const SearchScreen(),
    ];

    final destinations = [
      NavigationDestination(icon: const Icon(Icons.dashboard), label: l10n.dashboard),
      NavigationDestination(icon: const Icon(Icons.apartment), label: l10n.projects),
      NavigationDestination(icon: const Icon(Icons.people), label: l10n.workers),
      NavigationDestination(icon: const Icon(Icons.task_alt), label: l10n.tasks),
      NavigationDestination(icon: const Icon(Icons.analytics), label: l10n.analytics),
      NavigationDestination(icon: const Icon(Icons.archive), label: l10n.archive),
      NavigationDestination(icon: const Icon(Icons.search), label: l10n.search),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.welcomeAdmin),
        actions: [
          const LanguageSelector(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations
                      .map((d) => NavigationRailDestination(
                            icon: d.icon,
                            label: Text(d.label),
                          ))
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[_index]),
              ],
            )
          : pages[_index],
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: destinations,
            ),
    );
  }
}
