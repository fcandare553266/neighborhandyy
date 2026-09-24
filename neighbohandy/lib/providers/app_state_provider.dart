import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/provider_profile.dart';
import '../models/user_role.dart';

class AppStateProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.resident;
  String _userName = '';
  String _phoneNumber = '';
  String _address = '';
  String _city = '';
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;
  ProviderProfile? _freelancerProfile;
  final List<Booking> _bookings = [];

  // Getters
  UserRole get currentRole => _currentRole;
  String get userName => _userName;
  String get phoneNumber => _phoneNumber;
  String get address => _address;
  String get activeAddress => _address;
  String get activeCity => _city;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isDarkMode => _isDarkMode;
  ProviderProfile? get freelancerProfile => _freelancerProfile;
  List<Booking> get bookings => List.unmodifiable(_bookings);

  void setAddress(String newAddress) {
    _address = newAddress;
    notifyListeners();
    final user = FirebaseAuth.instance.currentUser;
    if (user!= null) {
      FirebaseFirestore.instance
         .collection('users')
         .doc(user.uid)
         .set({'address': newAddress}, SetOptions(merge: true))
         .catchError((e) => debugPrint('Error updating address: $e'));
    }
  }

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void clearSession() {
    _currentRole = UserRole.resident;
    _userName = '';
    _phoneNumber = '';
    _address = '';
    _city = '';
    _freelancerProfile = null;
    _bookings.clear();
    _notificationsEnabled = true;
    _isDarkMode = false;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String address,
    required String city,
  }) async {
    _userName = name;
    _phoneNumber = phone;
    _address = address;
    _city = city;
    notifyListeners();
    final user = FirebaseAuth.instance.currentUser;
    if (user!= null) {
      await user.updateDisplayName(name);
      await FirebaseFirestore.instance
         .collection('users')
         .doc(user.uid)
         .set({
            'name': name,
            'phone': phone,
            'address': address,
            'city': city,
          }, SetOptions(merge: true));
    }
  }

  void completeFreelancerProfile(ProviderProfile profile) {
    _freelancerProfile = profile;
    _currentRole = UserRole.freelancer;
    notifyListeners();
  }

  // FIXED: Always reset role and handle all role strings
  Future<void> loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    debugPrint('loadUserData: no user');
    return;
  }

  debugPrint('=== Loading for UID: ${user.uid} Email: ${user.email} ===');
  _currentRole = UserRole.resident;

  try {
    // FORCE SERVER, not cache
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get(const GetOptions(source: Source.server));

    debugPrint('Doc exists: ${doc.exists}');
    debugPrint('Doc data: ${doc.data()}');

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final rawRole = data['role'];
      debugPrint('RAW role field: $rawRole');

      _currentRole = userRoleFromValue(rawRole);
      _userName = data['name'] ?? user.displayName ?? '';
      _phoneNumber = data['phone'] ?? '';
      _address = data['address'] ?? '';
      _city = data['city'] ?? data['operatingCity'] ?? '';
      
      debugPrint('PARSED role: $_currentRole');
    }
    notifyListeners();
  } catch (e) {
    debugPrint('Error: $e');
    // try cache as fallback
    try {
      final cached = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (cached.exists) {
        _currentRole = userRoleFromValue(cached.data()!['role']);
      }
    } catch (_) {}
    notifyListeners();
  }
}
  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }
}