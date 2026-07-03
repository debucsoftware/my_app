import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:istakibim/core/theme/app_theme.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/screens/admin/admin_shell.dart';
import 'package:istakibim/screens/auth/login_screen.dart';
import 'package:istakibim/screens/common/app_locked_screen.dart';
import 'package:istakibim/screens/worker/worker_home_screen.dart';
import 'package:istakibim/services/auth_service.dart';
import 'package:istakibim/services/firestore_service.dart';
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
      home: const LicenseGate(),
    );
  }
}

class LicenseGate extends StatefulWidget {
  const LicenseGate({super.key});

  @override
  State<LicenseGate> createState() => _LicenseGateState();
}

class _LicenseGateState extends State<LicenseGate> {
  bool _signedOutForLock = false;

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return StreamBuilder<bool>(
      stream: firestore.watchAppLicenseEnabled(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }
        if (snapshot.hasError) {
          return const AppLockedScreen();
        }
        final enabled = snapshot.data;
        if (enabled != true) {
          if (!_signedOutForLock && FirebaseAuth.instance.currentUser != null) {
            _signedOutForLock = true;
            AuthService().signOut();
          }
          return const AppLockedScreen();
        }
        _signedOutForLock = false;
        return const AuthGate();
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }

        final firebaseUser = authSnapshot.data;
        if (firebaseUser == null) {
          return const LoginScreen();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .snapshots(),
          builder: (context, docSnapshot) {
            if (docSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScaffold(message: 'Profil yükleniyor...');
            }

            final doc = docSnapshot.data;
            if (doc == null || !doc.exists) {
              return _WaitingForProfileScreen(
                onSignOut: () => authService.signOut(),
              );
            }

            final user = AppUser.fromMap(doc.id, doc.data()!);
            if (!user.active) {
              return _InactiveAccountScreen(
                onSignOut: () => authService.signOut(),
              );
            }

            NotificationService().initialize(user.id);

            if (user.isAdmin) {
              return AdminShell(user: user);
            }
            return WorkerHomeScreen(user: user);
          },
        );
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!),
            ],
          ],
        ),
      ),
    );
  }
}

class _WaitingForProfileScreen extends StatefulWidget {
  const _WaitingForProfileScreen({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  State<_WaitingForProfileScreen> createState() => _WaitingForProfileScreenState();
}

class _WaitingForProfileScreenState extends State<_WaitingForProfileScreen> {
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _timedOut = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_timedOut) {
      return const _LoadingScaffold(message: 'Hesap oluşturuluyor...');
    }
    return _ProfileMissingScreen(onSignOut: widget.onSignOut);
  }
}

class _ProfileMissingScreen extends StatelessWidget {
  const _ProfileMissingScreen({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Profil bulunamadı. Lütfen yöneticinizle iletişime geçin.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onSignOut, child: const Text('Çıkış')),
            ],
          ),
        ),
      ),
    );
  }
}

class _InactiveAccountScreen extends StatelessWidget {
  const _InactiveAccountScreen({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Hesabınız pasif durumda.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onSignOut, child: const Text('Çıkış')),
            ],
          ),
        ),
      ),
    );
  }
}
