import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Login with email and password
  Future<UserCredential> login(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Handle all exceptions - works for both native and web
  String _handleException(dynamic e) {
    String errorCode = '';
    String errorMessage = '';

    // Handle FirebaseAuthException (native platforms)
    if (e is FirebaseAuthException) {
      errorCode = e.code;
      errorMessage = e.message ?? '';
    }
    // Handle generic exceptions and web errors
    else if (e is Exception) {
      errorMessage = e.toString();
      
      // Try to extract error code from message
      if (errorMessage.contains('weak-password')) {
        errorCode = 'weak-password';
      } else if (errorMessage.contains('email-already-in-use')) {
        errorCode = 'email-already-in-use';
      } else if (errorMessage.contains('invalid-email')) {
        errorCode = 'invalid-email';
      } else if (errorMessage.contains('user-not-found')) {
        errorCode = 'user-not-found';
      } else if (errorMessage.contains('wrong-password')) {
        errorCode = 'wrong-password';
      } else if (errorMessage.contains('user-disabled')) {
        errorCode = 'user-disabled';
      } else if (errorMessage.contains('too-many-requests')) {
        errorCode = 'too-many-requests';
      }
    } else {
      errorMessage = e.toString();
    }

    return _mapErrorMessage(errorCode, errorMessage);
  }

  String _mapErrorMessage(String code, String message) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        // If we have a message, use it; otherwise give a generic error
        if (message.isNotEmpty) {
          return message.replaceAll('Exception: ', '').replaceAll('[firebase_auth/channel-error]', '').trim();
        }
        return 'An authentication error occurred. Please try again.';
    }
  }
}
