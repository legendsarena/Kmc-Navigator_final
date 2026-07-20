/// Represents an authenticated admin user.
///
/// V1 has no end-user accounts; the only authenticated identity in the
/// app is the hospital admin who manages locations and announcements.
/// The Firestore `admins` collection stores admin profile documents
/// keyed by their Firebase Auth `uid` — this is used to confirm a signed
/// -in Firebase user is actually an authorized admin (rather than
/// trusting Firebase Auth sign-in alone), which is what the security
/// rules will check against for write access.
class Admin {
  const Admin({
    required this.uid,
    required this.email,
    this.displayName,
  });

  final String uid;
  final String email;
  final String? displayName;

  /// [id] is the Firestore document id, which is expected to equal the
  /// Firebase Auth [uid] by convention.
  factory Admin.fromFirestore(Map<String, dynamic> data, String id) {
    return Admin(
      uid: id,
      email: (data['email'] as String?) ?? '',
      displayName: data['displayName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
    };
  }

  Admin copyWith({
    String? uid,
    String? email,
    String? displayName,
  }) {
    return Admin(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }
}
