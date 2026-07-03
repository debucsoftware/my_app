import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/core/utils/email_key.dart';
import 'package:istakibim/models/worker_invite.dart';
import 'package:istakibim/models/app_user.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String _normalizeEmail(String email) => email.trim().toLowerCase();

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
    final normalized = _normalizeEmail(email);
    final credential = await _auth.signInWithEmailAndPassword(
      email: normalized,
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

  static String emailDocId(String email) => emailToDocId(email);

  Future<WorkerInvite?> getWorkerInvite(String email) async {
    final doc = await _firestore
        .collection('worker_invites')
        .doc(emailDocId(_normalizeEmail(email)))
        .get();
    if (!doc.exists) return null;
    return WorkerInvite.fromMap(doc.id, doc.data()!);
  }

  Future<void> inviteWorker({
    required String email,
    required String name,
    String? teamId,
  }) async {
    final normalized = _normalizeEmail(email);
    final existing = await _firestore
        .collection('users')
        .where('email', isEqualTo: normalized)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Bu e-posta zaten kayıtlı.',
      );
    }
    final inviteDoc = await _firestore
        .collection('worker_invites')
        .doc(emailDocId(normalized))
        .get();
    if (inviteDoc.exists) {
      throw FirebaseAuthException(
        code: 'invite-exists',
        message: 'Bu e-posta için davet zaten var.',
      );
    }
    await _firestore.collection('worker_invites').doc(emailDocId(normalized)).set({
      'email': normalized,
      'name': name,
      if (teamId != null) 'teamId': teamId,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser> completeWorkerRegistration({
    required String email,
    required String password,
  }) async {
    final normalized = _normalizeEmail(email);
    final invite = await getWorkerInvite(normalized);
    if (invite == null) {
      throw FirebaseAuthException(
        code: 'invite-not-found',
        message: 'Bu e-posta için davet bulunamadı. Zaten kayıtlıysanız giriş yapın.',
      );
    }
    if (!invite.active) {
      throw FirebaseAuthException(
        code: 'invite-disabled',
        message: 'Hesabınız pasif durumda.',
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: invite.email,
      password: password,
    );

    final uid = credential.user!.uid;
    final userData = <String, dynamic>{
      'email': invite.email,
      'name': invite.name,
      'role': UserRole.worker.name,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      if (invite.teamId != null) 'teamId': invite.teamId,
    };
    try {
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      await credential.user?.delete();
      await _auth.signOut();
      rethrow;
    }

    try {
      await _firestore
          .collection('worker_invites')
          .doc(emailDocId(invite.email))
          .delete();
    } catch (_) {
      // Profil oluştu, davet silinemese de giriş devam etsin.
    }

    return AppUser(
      id: uid,
      email: invite.email,
      name: invite.name,
      role: UserRole.worker,
      teamId: invite.teamId,
    );
  }

  Future<void> deleteWorkerInvite(String email) {
    return _firestore
        .collection('worker_invites')
        .doc(emailDocId(_normalizeEmail(email)))
        .delete();
  }

  Future<void> updateFcmToken(String userId, String token) {
    return _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }
}

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'user-not-found' => 'Kullanıcı bulunamadı.',
      'wrong-password' => 'Şifre hatalı.',
      'email-already-in-use' => 'Bu e-posta zaten kullanılıyor. Giriş yapın.',
      'invalid-email' => 'Geçersiz e-posta adresi.',
      'weak-password' => 'Şifre en az 6 karakter olmalı.',
      'invite-not-found' => error.message ?? 'Davet bulunamadı. Giriş yapmayı deneyin.',
      'unauthorized-domain' => 'Bu site Firebase için yetkili değil. debucsoftware.github.io eklenmeli.',
      _ => error.message ?? error.code,
    };
  }
  return error.toString();
}
