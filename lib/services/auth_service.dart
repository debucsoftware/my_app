import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/firebase_options.dart';
import 'package:istakibim/models/app_user.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Stream<AppUser?> watchCurrentAppUser() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        return AppUser.fromMap(doc.id, doc.data()!);
      });
    });
  }

  Future<AppUser> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final doc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();
    if (!doc.exists) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Kullanıcı profili bulunamadı.',
      );
    }
    final appUser = AppUser.fromMap(doc.id, doc.data()!);
    if (!appUser.active) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'user-disabled',
        message: 'Hesap pasif durumda.',
      );
    }
    return appUser;
  }

  Future<void> signOut() => _auth.signOut();

  Future<AppUser> createWorkerAccount({
    required String email,
    required String password,
    required String name,
    String? teamId,
  }) async {
    final secondaryApp = await Firebase.initializeApp(
      name: 'WorkerCreator',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    try {
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final appUser = AppUser(
        id: credential.user!.uid,
        email: email.trim(),
        name: name,
        role: UserRole.worker,
        teamId: teamId,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(appUser.id).set({
        ...appUser.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await secondaryAuth.signOut();
      return appUser;
    } finally {
      await secondaryApp.delete();
    }
  }

  Future<void> updateFcmToken(String userId, String token) {
    return _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }
}
