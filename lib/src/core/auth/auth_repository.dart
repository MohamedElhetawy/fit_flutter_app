import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_role.dart';
import 'app_user.dart';

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signInWithGoogleMobile() async {
    if (kIsWeb) {
      throw UnsupportedError(
          'Google Sign-In mobile flow is not available on web. Use signInWithGoogleWeb instead.');
    }
    final GoogleSignInAccount? account = await GoogleSignIn().signIn();
    if (account == null) {
      throw Exception('Google sign-in was cancelled');
    }
    final GoogleSignInAuthentication auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  /// Sign in with Google on Web using Popup
  Future<UserCredential> signInWithGoogleWeb() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    // Add scopes if needed
    googleProvider.addScope('email');
    googleProvider.addScope('profile');

    // Sign in with popup
    return await _auth.signInWithPopup(googleProvider);
  }

  Future<void> signOut() => _auth.signOut();

  Stream<AppRole?> watchRole(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      return AppRoleX.fromString(data?['role'] as String?);
    });
  }

  Stream<AppUser?> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return AppUser.fromMap(doc.id, data);
    });
  }

  Future<void> saveUserRole({
    required String uid,
    required AppRole role,
    String? email,
  }) {
    return _firestore.collection('users').doc(uid).set({
      'role': role.value,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
