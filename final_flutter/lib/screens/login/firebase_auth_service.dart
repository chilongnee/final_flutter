import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmailAndPassWord({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<User?> createUserWithEmailAndPassWord({
    required BuildContext context, // Add BuildContext parameter
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      if(e.toString() == '[firebase_auth/email-already-in-use] The email address is already in use by another account.'){
      // Show snackbar using provided context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email đã tồn tại vui lòng nhập email khác'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      }
      
      print(e);
    }
    return null;
  }

  Future<User?> signOut() async {
    await _auth.signOut();
    return null;
  }
}
