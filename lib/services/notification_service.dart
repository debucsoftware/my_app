import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:istakibim/firebase_options.dart';
import 'package:istakibim/models/app_notification.dart';
import 'package:istakibim/services/auth_service.dart';
import 'package:istakibim/services/firestore_service.dart';

const _channelId = 'istakibim_tasks';
const _channelName = 'Görev Bildirimleri';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.showLocalNotification(message);
}

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    AuthService? authService,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _authService = authService ?? AuthService(),
        _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin();

  static final NotificationService instance = NotificationService();

  final FirebaseMessaging _messaging;
  final AuthService _authService;
  final FlutterLocalNotificationsPlugin _localNotifications;
  bool _initialized = false;
  String? _userId;
  StreamSubscription<List<AppNotification>>? _notificationSub;
  final Set<String> _seenNotificationIds = {};
  bool _notificationsPrimed = false;

  static Future<void> setup() => instance._setup();

  Future<void> _setup() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
    );

    if (!kIsWeb) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(showLocalNotification);

    _initialized = true;
  }

  Future<void> initialize(String userId) async {
    _userId = userId;
    await _setup();

    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await _messaging.getToken();
    if (token != null) {
      await _authService.updateFcmToken(userId, token);
    }

    _messaging.onTokenRefresh.listen((token) async {
      final currentUserId = _userId;
      if (currentUserId != null) {
        await _authService.updateFcmToken(currentUserId, token);
      }
    });

    _listenForFirestoreNotifications(userId);
  }

  void _listenForFirestoreNotifications(String userId) {
    _notificationSub?.cancel();
    _notificationsPrimed = false;
    _seenNotificationIds.clear();

    _notificationSub = FirestoreService().watchUserNotifications(userId).listen(
      (notifications) {
        if (!_notificationsPrimed) {
          _seenNotificationIds.addAll(notifications.map((n) => n.id));
          _notificationsPrimed = true;
          return;
        }

        for (final notification in notifications) {
          if (_seenNotificationIds.contains(notification.id)) continue;
          _seenNotificationIds.add(notification.id);
          showLocalAppNotification(notification);
        }
      },
    );
  }

  static Future<void> showLocalAppNotification(AppNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    await instance._localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(android: androidDetails),
    );
  }

  void dispose() {
    _notificationSub?.cancel();
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    await instance._localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(android: androidDetails),
    );
  }
}
