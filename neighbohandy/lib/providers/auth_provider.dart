import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/freelancer_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthProvider({AuthService? authService, FirestoreService? firestoreService})
    : _authService = authService ?? AuthService(),
      _firestoreService = firestoreService ?? FirestoreService() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  UserModel? currentUser;
  FreelancerModel?
  currentFreelancer; // populated only when role == 'freelancer'
  bool isLoading = true;
  String? errorMessage;
  int _sessionVersion = 0;

  bool get isLoggedIn => currentUser != null;
  bool get isFreelancer => currentUser?.role == 'freelancer';

  Future<void> _onAuthChanged(dynamic firebaseUser) async {
    final version = ++_sessionVersion;
    if (firebaseUser == null) {
      currentUser = null;
      currentFreelancer = null;
      isLoading = false;
      errorMessage = null;
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _loadProfile(
        firebaseUser.uid,
        firebaseUser: firebaseUser,
        sessionVersion: version,
      );
      if (version != _sessionVersion) return;
      isLoading = false;
      notifyListeners();
    } catch (error) {
      if (version != _sessionVersion) return;
      errorMessage = error.toString();
      currentUser = null;
      currentFreelancer = null;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfile(
    String uid, {
    User? firebaseUser,
    int? sessionVersion,
  }) async {
    final loadedUser = await _firestoreService.getUser(uid);
    if (sessionVersion != null && sessionVersion != _sessionVersion) return;
    currentUser = loadedUser;
    if (currentUser == null) {
      final freelancer = await _firestoreService.getFreelancer(
        uid,
        email: firebaseUser?.email,
      );
      if (sessionVersion != null && sessionVersion != _sessionVersion) return;
      if (freelancer == null) {
        throw StateError(
          'Your Firebase Authentication account has no matching Firestore users profile.',
        );
      }
      currentUser = UserModel(
        uid: uid,
        name: freelancer.contactPerson.isNotEmpty
            ? freelancer.contactPerson
            : freelancer.companyName,
        email: firebaseUser?.email ?? '',
        phone: freelancer.phone,
        address: freelancer.address,
        city: freelancer.city,
        role: 'freelancer',
      );
      await _firestoreService.createUser(currentUser!);
    }
    if (firebaseUser != null &&
        (currentUser!.name.isEmpty || currentUser!.email.isEmpty)) {
      final name = currentUser!.name.isEmpty
          ? firebaseUser.displayName
          : currentUser!.name;
      final email = currentUser!.email.isEmpty
          ? firebaseUser.email
          : currentUser!.email;
      currentUser = currentUser!.copyWith(name: name, email: email);
      await _firestoreService.updateUser(uid, {
        if (name != null && name.isNotEmpty) 'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
      });
    }
    if (currentUser?.role == 'freelancer') {
      currentFreelancer = await _firestoreService.getFreelancer(
        uid,
        email: firebaseUser?.email,
      );
      if (currentFreelancer == null) {
        throw StateError(
          'Your account is marked as a freelancer, but no matching freelancer profile was found in Firebase.',
        );
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    return _run(() async {
      // Clear the previous account before starting a new profile load. This
      // prevents the old user's data from being shown while Firebase switches
      // accounts.
      ++_sessionVersion;
      currentUser = null;
      currentFreelancer = null;
      await _authService.signIn(email: email, password: password);
    });
  }

  /// [role] is 'client' or 'freelancer' — chosen on the role-select screen.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    return _run(() async {
      final user = await _authService.signUp(email: email, password: password);
      if (user == null) return;
      await user.updateDisplayName(name);
      final newUser = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        phone: phone,
        role: role == 'client' ? 'resident' : role,
        createdAt: DateTime.now(),
      );
      await _firestoreService.createUser(newUser);
      currentUser = newUser;
    });
  }

  /// Existing client applies to also become a freelancer.
  Future<bool> applyAsFreelancer(FreelancerModel profile) async {
    return _run(() async {
      await _firestoreService.createFreelancerProfile(profile);
      await _firestoreService.updateUser(profile.uid, {'role': 'freelancer'});
      currentUser = currentUser?.copyWith(role: 'freelancer');
      currentFreelancer = profile;
    });
  }

  Future<void> updateClientProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    await _firestoreService.updateUser(currentUser!.uid, data);
    await _loadProfile(currentUser!.uid);
  }

  Future<void> updateFreelancerProfile(Map<String, dynamic> data) async {
    if (currentFreelancer == null) return;
    await _firestoreService.updateFreelancerProfile(
      currentFreelancer!.uid,
      data,
    );
    await _loadProfile(currentFreelancer!.uid);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (currentUser == null) return;
    await _firestoreService.updateUser(currentUser!.uid, {
      'notificationsEnabled': enabled,
    });
    currentUser = currentUser!.copyWith(notificationsEnabled: enabled);
    if (isFreelancer && currentFreelancer != null) {
      await _firestoreService.updateFreelancerProfile(currentFreelancer!.uid, {
        'notificationsEnabled': enabled,
      });
    }
    notifyListeners();
  }

  Future<void> logout() async {
    ++_sessionVersion;
    currentUser = null;
    currentFreelancer = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
    await _authService.signOut();
  }

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      // Firebase may have accepted the credentials while the auth-state
      // listener is still loading the new user's Firestore profile.
      isLoading = _authService.currentUser != null && currentUser == null;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is FirebaseAuthException &&
          (e.code == 'email-already-in-use' ||
              e.code == 'user-not-found' ||
              e.code == 'wrong-password' ||
              e.code == 'invalid-credential' ||
              e.code == 'user-disabled')) {
        ++_sessionVersion;
        currentUser = null;
        currentFreelancer = null;
        await _authService.signOut();
      }
      isLoading = false;
      errorMessage = _readableAuthError(e);
      notifyListeners();
      return false;
    }
  }

  String _readableAuthError(Object error) {
    if (error is! FirebaseAuthException) return error.toString();

    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email or password is incorrect.';
      case 'user-disabled':
        return 'This Firebase account has been disabled.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'network-request-failed':
        return 'Unable to connect to Firebase. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'email-already-in-use':
        return 'That email already has a Firebase account. Log in instead.';
      default:
        return '${error.code}: ${error.message ?? 'Authentication failed.'}';
    }
  }
}
