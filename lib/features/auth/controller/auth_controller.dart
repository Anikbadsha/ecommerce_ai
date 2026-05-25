import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '294519627026-6l29549dladr1c96ro8bnubhqg0gd8li.apps.googleusercontent.com',
  );

  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthController() {
    // Listen to Firebase auth state — fires reliably after Google sign-in completes
    _auth.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  Future<String?> register({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final u = _auth.currentUser;
      if (u != null) {
        await _db.collection('users').doc(u.uid).set({
          'name': '', 'email': u.email, 'image': '', 'uid': u.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        return 'Google Sign-In failed: no ID token. Ensure Google is enabled in Firebase Console.';
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final u = result.user;
      if (u != null) {
        await _db.collection('users').doc(u.uid).set({
          'name': u.displayName, 'email': u.email,
          'image': u.photoURL, 'uid': u.uid,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      // authStateChanges listener handles notifyListeners automatically
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Auth error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}