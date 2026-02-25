import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get Firebase ID token for backend authentication
  Future<String?> getIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  // Email/Password Sign In
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      if (kDebugMode) {
        print('🔐 Signing in with email: $email');
      }
      
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        print('✅ Firebase sign in successful');
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase sign in failed: ${e.code} - ${e.message}');
      }
      throw _handleFirebaseAuthException(e);
    }
  }

  // Email/Password Sign Up
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      if (kDebugMode) {
        print('📝 Creating Firebase account for: $email');
      }
      
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        print('✅ Firebase account created successfully');
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase sign up failed: ${e.code} - ${e.message}');
      }
      throw _handleFirebaseAuthException(e);
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('🔵 Starting Google Sign-In...');
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      if (kDebugMode) {
        print('✅ Google user selected: ${googleUser.email}');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) {
        print('🔑 Google credentials obtained, signing in to Firebase...');
      }

      // Sign in to Firebase with Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (kDebugMode) {
        print('✅ Google Sign-In successful: ${userCredential.user?.email}');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Google Sign-In failed: ${e.code} - ${e.message}');
      }
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Google Sign-In error: $e');
      }
      rethrow;
    }
  }

  // Apple Sign In
  Future<UserCredential> signInWithApple() async {
    try {
      if (kDebugMode) {
        print('🍎 Starting Apple Sign-In...');
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (kDebugMode) {
        print('✅ Apple credential obtained');
      }

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      if (kDebugMode) {
        print('🔑 Signing in to Firebase with Apple credential...');
      }

      // Sign in to Firebase with Apple credential
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

      if (kDebugMode) {
        print('✅ Apple Sign-In successful: ${userCredential.user?.email}');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Apple Sign-In failed: ${e.code} - ${e.message}');
      }
      throw _handleFirebaseAuthException(e);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (kDebugMode) {
        print('❌ Apple authorization failed: ${e.code} - ${e.message}');
      }
      throw Exception('Apple Sign-In cancelled or failed');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Apple Sign-In error: $e');
      }
      rethrow;
    }
  }

  // Phone Authentication - send verification code
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
  }) async {
    try {
      if (kDebugMode) {
        print('📱 Starting phone verification for: $phoneNumber');
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('✅ Phone auto-verification completed');
          }
          verificationCompleted(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('❌ Phone verification failed: ${e.code} - ${e.message}');
          }
          verificationFailed(_handleFirebaseAuthException(e).toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          if (kDebugMode) {
            print('📨 Verification code sent');
          }
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            print('⏱️ Code auto-retrieval timeout');
          }
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Phone verification error: $e');
      }
      rethrow;
    }
  }

  // Phone Authentication - verify code and sign in
  Future<UserCredential> signInWithPhoneCredential(
    String verificationId,
    String smsCode,
  ) async {
    try {
      if (kDebugMode) {
        print('🔑 Verifying SMS code...');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (kDebugMode) {
        print('✅ Phone sign-in successful');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Phone sign-in failed: ${e.code} - ${e.message}');
      }
      throw _handleFirebaseAuthException(e);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      if (kDebugMode) {
        print('📧 Email verification sent to ${user.email}');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print('🚪 Signing out from Firebase...');
      }

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        if (kDebugMode) {
          print('✅ Signed out from Google');
        }
      }

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      if (kDebugMode) {
        print('✅ Signed out from Firebase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out error: $e');
      }
      rethrow;
    }
  }

  // Check if Apple Sign In is available
  Future<bool> isAppleSignInAvailable() async {
    return Platform.isIOS || Platform.isMacOS;
  }

  // Handle Firebase Auth exceptions
  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('An account already exists with this email');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later');
      case 'operation-not-allowed':
        return Exception('This sign-in method is not enabled');
      case 'account-exists-with-different-credential':
        return Exception('An account exists with the same email but different sign-in method');
      case 'invalid-credential':
        return Exception('Invalid credentials');
      case 'invalid-verification-code':
        return Exception('Invalid verification code');
      case 'invalid-verification-id':
        return Exception('Invalid verification ID');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}
