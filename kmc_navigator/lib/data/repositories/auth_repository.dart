import 'dart:async';

import '../../core/errors/app_failure.dart';
import '../../domain/entities/admin.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Bridges Firebase Authentication with the `admins` Firestore
/// collection.
///
/// Being able to sign in to Firebase Auth is not, by itself, treated as
/// proof of adminship — this repository also requires an `admins/{uid}`
/// document to exist. That mirrors how the eventual Firestore Security
/// Rules will gate writes (`request.auth.uid in admins`), so the app's
/// notion of "is this person an admin" always matches what the backend
/// will actually allow.
class AuthRepository {
  AuthRepository(this._authService, this._firestoreService);

  final AuthService _authService;
  final FirestoreService _firestoreService;

  /// Live stream of the signed-in [Admin], or `null` when signed out —
  /// or when a Firebase user is signed in but has no matching `admins`
  /// document (treated as "not an admin", not an error).
  Stream<Admin?> watchAdminAuthState() {
    return _authService.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _firestoreService.admins.doc(user.uid).get();
        return doc.data();
      } catch (_) {
        // If the admin lookup itself fails (e.g. offline), fail closed:
        // treat the session as unauthenticated rather than granting
        // admin access on a hunch.
        return null;
      }
    });
  }

  /// Signs in with email/password and confirms the resulting Firebase
  /// user is a registered admin.
  ///
  /// If sign-in succeeds but no `admins/{uid}` document exists, the
  /// session is immediately signed back out and an [AppFailure] is
  /// thrown — a valid Firebase account that isn't provisioned as an
  /// admin should not be treated as logged in.
  Future<Admin> signInAdmin({required String email, required String password}) async {
    try {
      final user = await _authService.signInAdmin(email: email, password: password);
      final doc = await _firestoreService.admins.doc(user.uid).get();
      final admin = doc.data();
      if (admin == null) {
        await _authService.signOut();
        throw const AppFailure(
          type: AppFailureType.permissionDenied,
          title: "You don't have access",
          message: 'This account is not registered as a hospital admin.',
        );
      }
      return admin;
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> signOut() => _authService.signOut();
}
