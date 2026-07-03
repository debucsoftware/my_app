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

  static String emailDocId(String email) => emailToDocId(email);

  Future<WorkerInvite?> getWorkerInvite(String email) async {
    final doc = await _firestore
        .collection('worker_invites')
        .doc(emailDocId(email))
        .get();
    if (!doc.exists) return null;
    return WorkerInvite.fromMap(doc.id, doc.data()!);
  }

  Future<void> inviteWorker({
    required String email,
    required String name,
    String? teamId,
  }) async {
    final normalized = email.trim().toLowerCase();
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
      'teamId': teamId,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser> completeWorkerRegistration({
    required String email,
    required String password,
  }) async {
    final invite = await getWorkerInvite(email);
    if (invite == null) {
      throw FirebaseAuthException(
        code: 'invite-not-found',
        message: 'Bu e-posta için davet bulunamadı.',
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
    final appUser = AppUser(
      id: credential.user!.uid,
      email: invite.email,
      name: invite.name,
      role: UserRole.worker,
      teamId: invite.teamId,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(appUser.id).set({
      ...appUser.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _firestore
        .collection('worker_invites')
        .doc(emailDocId(invite.email))
        .delete();
    return appUser;
  }

  Future<void> deleteWorkerInvite(String email) {
    return _firestore
        .collection('worker_invites')
        .doc(emailDocId(email))
        .delete();
  }

  Future<void> updateFcmToken(String userId, String token) {
    return _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }
}
