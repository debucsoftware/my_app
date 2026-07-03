import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/screens/admin/analytics_screen.dart';
import 'package:istakibim/screens/admin/archive_screen.dart';
import 'package:istakibim/screens/admin/dashboard_screen.dart';
import 'package:istakibim/screens/admin/notifications_screen.dart';
import 'package:istakibim/screens/admin/projects_screen.dart';
import 'package:istakibim/screens/admin/search_screen.dart';
import 'package:istakibim/screens/admin/tasks_screen.dart';
import 'package:istakibim/screens/admin/teams_screen.dart';
import 'package:istakibim/screens/admin/units_screen.dart';
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
      const UnitsScreen(),
      const WorkersScreen(),
      const TeamsScreen(),
      const TasksScreen(),
      const AnalyticsScreen(),
      const ArchiveScreen(),
      const SearchScreen(),
    ];

    final destinations = [
      (Icons.dashboard, l10n.dashboard),
      (Icons.apartment, l10n.projects),
      (Icons.home_work, l10n.units),
      (Icons.people, l10n.workers),
      (Icons.groups, l10n.teams),
      (Icons.task_alt, l10n.tasks),
      (Icons.analytics, l10n.analytics),
      (Icons.archive, l10n.archive),
      (Icons.search, l10n.search),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.welcomeAdmin),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: l10n.notifications,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationsScreen(user: widget.user),
              ),
            ),
          ),
          const LanguageSelector(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      drawer: isWide
          ? null
          : Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    child: Text(l10n.welcomeAdmin, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  ...List.generate(destinations.length, (i) {
                    final (icon, label) = destinations[i];
                    return ListTile(
                      leading: Icon(icon),
                      title: Text(label),
                      selected: _index == i,
                      onTap: () {
                        setState(() => _index = i);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
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
                            icon: Icon(d.$1),
                            label: Text(d.$2),
                          ))
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[_index]),
              ],
            )
          : pages[_index],
    );
  }
}
