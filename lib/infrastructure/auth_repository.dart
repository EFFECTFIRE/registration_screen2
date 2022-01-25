import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_firebase_login/infrastructure/cache.dart';
import 'package:flutter_firebase_login/user.dart';

class SignUpWithEmailAndPasswordFailure implements Exception {
  const SignUpWithEmailAndPasswordFailure(
      [this.message = 'An unknown exception occured.']);

  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case "invalid-email":
        return const SignUpWithEmailAndPasswordFailure(
            "Email is not valid or badly formatted.");
      case "user-disabled":
        return const SignUpWithEmailAndPasswordFailure(
            "This user has been disabled.");
      case "email-already-in-use":
        return const SignUpWithEmailAndPasswordFailure("Account already exist");
      case "operation-not-allowed":
        return const SignUpWithEmailAndPasswordFailure(
            "Operation is not allowed.");
      case "weak-password":
        return const SignUpWithEmailAndPasswordFailure(
            "Please enter a stronger password");

      default:
        return const SignUpWithEmailAndPasswordFailure();
    }
  }
  final String message;
}

class LogInWithEmailAndPasswordFailure implements Exception {
  const LogInWithEmailAndPasswordFailure(
      [this.message = "An unknown exception occured."]);
  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case "invalid-email":
        return const LogInWithEmailAndPasswordFailure(
            "Email is not valid or badly formatted.");
      case "user-not-found":
        return const LogInWithEmailAndPasswordFailure("Email is not found");
      case "wrong-password":
        return const LogInWithEmailAndPasswordFailure("Incorrect password");

      default:
        return const LogInWithEmailAndPasswordFailure();
    }
  }
  final String message;
}

class LogOutFailure implements Exception {}

class AuthenticationRepository {
  AuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
  })  : _cache = cache ?? CacheClient(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  bool isWeb = kIsWeb;

  static const userCacheKey = "user_cahce_key";

  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }

  Future<void> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  Future<void> logInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      throw LogOutFailure();
    }
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(id: uid, email: email, name: displayName);
  }
}
