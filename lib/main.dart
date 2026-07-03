import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:istakibim/app.dart';
import 'package:istakibim/firebase_options.dart';
import 'package:istakibim/services/firestore_service.dart';
import 'package:istakibim/services/locale_service.dart';
import 'package:istakibim/services/notification_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.setup();

  final licenseEnabled = await FirestoreService().fetchLicenseFromServer();
  if (!licenseEnabled) {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }

  final localeService = LocaleService();
  await localeService.load();
  runApp(
    ChangeNotifierProvider.value(
      value: localeService,
      child: IstakibimApp(initialLicenseEnabled: licenseEnabled),
    ),
  );
}
