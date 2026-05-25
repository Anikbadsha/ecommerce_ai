import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn =
      GoogleSignIn();

  // CURRENT USER
  User? get user => _auth.currentUser;

  // LOGIN STATUS
  bool get isLoggedIn => user != null;

  // REGISTER
  Future<String?> register({
    required String email,
    required String password,
  }) async {

    try {

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      notifyListeners();

      return null;

    } on FirebaseAuthException catch (e) {

      return e.message;

    } catch (e) {

      return e.toString();
    }
  }

  // LOGIN
  Future<String?> login({
    required String email,
    required String password,
  }) async {

    try {

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      notifyListeners();

      return null;

    } on FirebaseAuthException catch (e) {

      return e.message;

    } catch (e) {

      return e.toString();
    }
  }

  // GOOGLE SIGN IN
  Future<String?> signInWithGoogle() async {

    try {

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        return "Cancelled";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(
        credential,
      );

      notifyListeners();

      return null;

    } on FirebaseAuthException catch (e) {

      return e.message;

    } catch (e) {

      return e.toString();
    }
  }

  // LOGOUT
  Future<void> logout() async {

    await _googleSignIn.signOut();

    await _auth.signOut();

    notifyListeners();
  }
}