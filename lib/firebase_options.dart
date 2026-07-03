import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Bu platform desteklenmiyor.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAQp2EXIu7nJXKtRt5qIGfeJFIL5JvYjLk',
    appId: '1:619653651663:web:22ec8a878f6fa49ff02bba',
    messagingSenderId: '619653651663',
    projectId: 'istakibim',
    authDomain: 'istakibim.firebaseapp.com',
    storageBucket: 'istakibim.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQn6fsp961xDvZdVTVd5i-qcs28Of9mCo',
    appId: '1:619653651663:android:dae97d0c1adb8b49f02bba',
    messagingSenderId: '619653651663',
    projectId: 'istakibim',
    storageBucket: 'istakibim.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALTl8_JByFurQJIS06Z75rBLJ2sMUkfuI',
    appId: '1:619653651663:ios:29b77431d5aa7e18f02bba',
    messagingSenderId: '619653651663',
    projectId: 'istakibim',
    storageBucket: 'istakibim.firebasestorage.app',
    iosBundleId: 'com.debuc.istakibim',
  );
}
