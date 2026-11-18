import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:firebase_storage/firebase_storage.dart';

import '../auth_service.dart';

class AdmissionService {
  /// Creates the account (if not signed in), uploads the CNIC / B-Form file to
  /// Storage and saves the application in Firestore at `admissions/{uid}`.
  /// The password is only used for Firebase Auth and is never stored.
  static Future<String> submit({
    required String email,
    required String password,
    required String fullName,
    required Map<String, dynamic> student,
    required Map<String, dynamic> parent,
    required Map<String, dynamic> education,
    required PlatformFile file,
  }) async {
    final auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if (user == null) {
      final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
      user = cred.user!;
      await user.updateDisplayName(fullName);
      await user.sendEmailVerification();
    }

    final ref = FirebaseFirestore.instance.collection('admissions').doc(user.uid);
    if ((await ref.get()).exists) throw StateError('already-submitted');

    final ext = (file.extension ?? 'jpg').toLowerCase();
    final path = 'admissions/${user.uid}/cnic.$ext';
    final upload = await FirebaseStorage.instance
        .ref(path)
        .putData(file.bytes!, SettableMetadata(contentType: _mime(ext)));
    final url = await upload.ref.getDownloadURL();

    await ref.set({
      'userId': user.uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'student': {
        ...student,
        'cnicFile': {'url': url, 'path': path, 'name': file.name, 'sizeBytes': file.size},
      },
      'parent': parent,
      'education': education,
    });
    return user.uid;
  }

  static String _mime(String ext) => switch (ext) {
        'png' => 'image/png',
        'pdf' => 'application/pdf',
        _ => 'image/jpeg',
      };

  static String message(Object e) {
    if (e is StateError && e.message == 'already-submitted') {
      return 'An application has already been submitted with this account.';
    }
    if (e is FirebaseAuthException) return AuthService.message(e);
    if (e is FirebaseException) {
      if (e.code == 'permission-denied' || e.code == 'unauthorized') {
        return 'Permission denied. Publish firestore.rules and storage.rules from the repo (see README).';
      }
      return 'Could not save the application (${e.code}). Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
