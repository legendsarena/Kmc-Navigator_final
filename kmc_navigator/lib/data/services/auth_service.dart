import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Authentication for the app.
///
/// V1 only needs admin login (email/password) — there are no end-user
/// accounts, so this service intentionally has no sign-up flow.
/// Raw [FirebaseAuthException]s are allowed to propagate up; callers
/// (repositories) are responsible for mapping them to [AppFailure].
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  /// Currently signed-in admin's Firebase user, if any.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of raw Firebase auth state changes. The repository layer
  /// maps this to `Admin?` (confirming the user is a real admin via the
  /// `admins` collection) before it reaches the UI.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Signs in with the admin's email/password.
  ///
  /// Throws [FirebaseAuthException] on failure (wrong password, no such
  /// user, disabled account, etc) — left un-caught here on purpose so
  /// the repository can translate it into a friendly [AppFailure].
  Future<User> signInAdmin({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: 'Sign-in did not return a user.');
    }
    return user;
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
