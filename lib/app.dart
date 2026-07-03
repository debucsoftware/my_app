import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:istakibim/core/theme/app_theme.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/screens/admin/admin_shell.dart';
import 'package:istakibim/screens/auth/login_screen.dart';
import 'package:istakibim/screens/worker/worker_home_screen.dart';
import 'package:istakibim/services/auth_service.dart';
import 'package:istakibim/services/locale_service.dart';
import 'package:istakibim/services/notification_service.dart';
import 'package:provider/provider.dart';

class IstakibimApp extends StatelessWidget {
  const IstakibimApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = context.watch<LocaleService>();

    return MaterialApp(
      title: 'İş Takibim',
      theme: AppTheme.light,
      locale: localeService.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<AppUser?>(
      stream: authService.watchCurrentAppUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();

        NotificationService().initialize(user.id);

        if (user.isAdmin) {
          return AdminShell(user: user);
        }
        return WorkerHomeScreen(user: user);
      },
    );
  }
}
