import 'package:firebase_auth/firebase_auth.dart';

/// Set to true by main() once Firebase initialised with a real config.
bool firebaseReady = false;

class AuthService {
  static FirebaseAuth get _a => FirebaseAuth.instance;

  static Stream<User?> get user =>
      firebaseReady ? _a.userChanges() : Stream<User?>.value(null);

  static Future<void> signIn(String email, String password) async {
    await _a.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signUp(String name, String email, String password) async {
    final cred = await _a.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName(name);
    await cred.user?.sendEmailVerification();
  }

  static Future<void> google() async {
    await _a.signInWithProvider(GoogleAuthProvider());
  }

  static Future<void> reset(String email) => _a.sendPasswordResetEmail(email: email);

  static Future<void> signOut() => _a.signOut();

  static String message(Object e) {
    final code = e is FirebaseAuthException ? e.code : '';
    const m = {
      'invalid-email': 'Enter a valid email address.',
      'missing-password': 'Enter your password.',
      'invalid-credential': 'Email or password is incorrect.',
      'user-not-found': 'No account found with this email.',
      'wrong-password': 'Email or password is incorrect.',
      'email-already-in-use': 'An account with this email already exists. Log in instead.',
      'weak-password': 'Password must be at least 6 characters.',
      'too-many-requests': 'Too many attempts. Try again in a few minutes.',
      'network-request-failed': 'Network error. Check your connection.',
      'canceled': 'Google sign-in was cancelled.',
      'web-context-canceled': 'Google sign-in was cancelled.',
      'operation-not-allowed': 'This sign-in method is not enabled in Firebase yet.',
      'configuration-not-found':
          'Firebase Authentication is not set up yet. Enable Email/Password and Google in the Firebase Console.',
    };
    return m[code] ??
        'Something went wrong (${code.isEmpty ? e.runtimeType : code}). Please try again.';
  }
}
