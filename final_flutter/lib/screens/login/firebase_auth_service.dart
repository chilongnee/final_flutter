import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmailAndPassWord(
      {required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<User?> createUserWithEmailAndPassWord(
      {required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<User?> signOut() async {
    await _auth.signOut();
    return null;
  }
}
