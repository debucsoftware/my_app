import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadTaskPhoto({
    required String taskId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref().child('tasks/$taskId/$fileName');
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }
}
