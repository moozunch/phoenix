import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phoenix/core/app_state.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User?> signUpEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;

    // Try send verification email
    try {
      await user?.sendEmailVerification();
    } catch (e) {
      print("Email verification failed: $e");
      // jangan throw error—biarkan signup tetap lanjut
    }

    // update AppState
    final state = await AppState.create();
    await state.setIsNewUser(true);
    await state.setHasOnboarded(true);

    return user;
  }



  Future<User?> signInEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<User?> signInGoogle() async {
    final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
    if (googleUser == null) return null; // user aborted
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return cred.user;
  }

  Future<void> signOut() async {
    try { await GoogleSignIn().signOut(); } catch (_) {}
    await _auth.signOut();
  }
}
