import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth. Business data (name, role, city, etc.)
/// lives in Firestore via FirestoreService, keyed by the uid this returns.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<User?> signUp({required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
