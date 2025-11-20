import 'package:firebase_auth/firebase_auth.dart';

enum AuthContext { signIn, signUp, google, passwordReset }

class AuthErrorMapper {
  static String map(FirebaseAuthException e, AuthContext ctx) {
    switch (ctx) {
      case AuthContext.signIn:
        return _signIn(e);
      case AuthContext.signUp:
        return _signUp(e);
      case AuthContext.google:
        return _google(e);
      case AuthContext.passwordReset:
        return _passwordReset(e);
    }
  }

  static String _signIn(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'Account is disabled.';
      case 'user-not-found':
        return 'Account not found.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Sign in failed (${e.code}).';
    }
  }

  static String _signUp(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      default:
        return 'Sign up failed (${e.code}).';
    }
  }

  static String _google(FirebaseAuthException e) {
    if (e.code == 'account-exists-with-different-credential') {
      return 'This email is already registered with another method.';
    }
    return 'Google Sign-In failed (${e.code}).';
  }

  static String _passwordReset(FirebaseAuthException e) {
    // We intentionally return a generic message to avoid account enumeration.
    return 'If an account exists, a reset link has been sent.';
  }
}
