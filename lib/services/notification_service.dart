import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:istakibim/services/auth_service.dart';

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    AuthService? authService,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _authService = authService ?? AuthService();

  final FirebaseMessaging _messaging;
  final AuthService _authService;

  Future<void> initialize(String? userId) async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    if (userId != null && token != null) {
      await _authService.updateFcmToken(userId, token);
    }
    _messaging.onTokenRefresh.listen((token) async {
      if (userId != null) {
        await _authService.updateFcmToken(userId, token);
      }
    });
  }
}
