import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_model.dart';
import '../models/category_model.dart';
import '../models/freelancer_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------- Users (clients) ----------
  Future<UserModel?> getUser(String uid, {Source source = Source.serverAndCache}) async {
    final doc = await _firestore.collection('users').doc(uid).get(
      GetOptions(source: source),
    );
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // ---------- Freelancers ----------
  Future<FreelancerModel?> getFreelancer(String uid, {String? email}) async {
    final direct = await _firestore.collection('freelancers').doc(uid).get();
    if (direct.exists && direct.data()!= null) {
      return FreelancerModel.fromMap(direct.id, direct.data()!);
    }

    for (final field in ['uid', 'userId', 'ownerId', 'authUid']) {
      final matches = await _firestore
         .collection('freelancers')
         .where(field, isEqualTo: uid)
         .limit(1)
         .get();
      if (matches.docs.isNotEmpty) {
        final doc = matches.docs.first;
        return FreelancerModel.fromMap(doc.id, doc.data());
      }
    }

    if (email!= null && email.trim().isNotEmpty) {
      final normalized = email.trim().toLowerCase();
      final trimmed = email.trim();

      var matches = await _firestore.collection('freelancers').where('email', isEqualTo: normalized).limit(1).get();
      if (matches.docs.isNotEmpty) return FreelancerModel.fromMap(matches.docs.first.id, matches.docs.first.data());

      matches = await _firestore.collection('freelancers').where('email', isEqualTo: trimmed).limit(1).get();
      if (matches.docs.isNotEmpty) return FreelancerModel.fromMap(matches.docs.first.id, matches.docs.first.data());

      matches = await _firestore.collection('freelancers').where('userEmail', isEqualTo: normalized).limit(1).get();
      if (matches.docs.isNotEmpty) return FreelancerModel.fromMap(matches.docs.first.id, matches.docs.first.data());

      matches = await _firestore.collection('freelancers').where('contactEmail', isEqualTo: normalized).limit(1).get();
      if (matches.docs.isNotEmpty) return FreelancerModel.fromMap(matches.docs.first.id, matches.docs.first.data());
    }
    return null;
  }

  Future<void> createFreelancerProfile(FreelancerModel freelancer) async {
    await _firestore.collection('freelancers').doc(freelancer.uid).set(freelancer.toMap());
  }

  Future<void> updateFreelancerProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('freelancers').doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<List<FreelancerModel>> getFreelancersByCategoryAndCity({
    required String category,
    required String city,
  }) {
    final requestedCategory = _normalizeCategory(category);
    Query<Map<String, dynamic>> query = _firestore.collection('freelancers');
    if (city.trim().isNotEmpty) {
      query = query.where('city', isEqualTo: city.trim());
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
         .where((doc) => _matchesCategory(doc.data(), requestedCategory))
         .where((doc) => doc.data()['isAvailable'] == null || doc.data()['isAvailable'] == true)
         .map((doc) => FreelancerModel.fromMap(doc.id, doc.data()))
         .toList(),
    );
  }

  bool _matchesCategory(Map<String, dynamic> data, String requestedCategory) {
    final values = [
      data['category'],
      data['serviceRole'],
      data['companyName'],
      data['name'],
    ].whereType<String>();
    return values.any(
      (value) => _normalizeCategory(value).contains(requestedCategory) || requestedCategory.contains(_normalizeCategory(value)),
    );
  }

  String _normalizeCategory(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    const aliases = {
      'plumbing': 'plumber',
      'electric': 'electrician',
      'electrical': 'electrician',
      'painting': 'painter',
      'masonry': 'mason',
      'carpentry': 'carpenter',
      'cleaning': 'housecleaner',
      'housecleaning': 'housecleaner',
      'hvac': 'hvacaircontechnician',
      'airconditioning': 'hvacaircontechnician',
    };
    if (normalized.contains('plumb')) return 'plumber';
    if (normalized.contains('electric')) return 'electrician';
    if (normalized.contains('paint')) return 'painter';
    if (normalized.contains('carpent')) return 'carpenter';
    return aliases[normalized]?? normalized;
  }

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.id, doc.data())).toList();
  }

  Future<Map<String, int>> getFreelancerCategoryCounts() async {
    final snapshot = await _firestore.collection('freelancers').get();
    final counts = <String, int>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['isAvailable'] == false) continue;
      final values = [data['category'], data['serviceRole'], data['companyName'], data['name']].whereType<String>();
      final category = values.map(_normalizeCategory).firstWhere((value) => value.isNotEmpty, orElse: () => '');
      if (category.isNotEmpty) {
        counts[category] = (counts[category]?? 0) + 1;
      }
    }
    return counts;
  }

  Future<String> createBooking(BookingModel booking) async {
    final reference = booking.id.isEmpty? _firestore.collection('bookings').doc() : _firestore.collection('bookings').doc(booking.id);
    await reference.set(booking.toMap());
    return reference.id;
  }

  Stream<List<BookingModel>> getPendingRequestsForFreelancer(String freelancerId) {
    return Stream.fromFuture(_freelancerIdsForUser(freelancerId)).asyncExpand(
      (freelancerIds) => _firestore.collection('bookings').snapshots().map(
            (snapshot) => snapshot.docs
               .where((doc) {
                  final data = doc.data();
                  final bookingFreelancerId = (data['freelancerId']?? '').toString().trim();
                  final status = (data['status']?? '').toString().trim().toLowerCase();
                  return freelancerIds.contains(bookingFreelancerId) && status == BookingStatus.pending.name;
                })
               .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
               .toList(),
          ),
    );
  }

  Stream<List<BookingModel>> getBookedDatesForFreelancer(String freelancerId) {
    return Stream.fromFuture(_freelancerMatchKeys(freelancerId)).asyncExpand(
      (matchKeys) => _firestore.collection('bookings').snapshots().map(
            (snapshot) => snapshot.docs
               .where((doc) {
                  final data = doc.data();
                  final bookingFreelancerId = (data['freelancerId']?? '').toString().trim();
                  final bookingFreelancerName = (data['freelancerName']?? data['name']?? '').toString().trim().toLowerCase();
                  final status = (data['status']?? '').toString().trim().toLowerCase();
                  return (matchKeys.contains(bookingFreelancerId.toLowerCase()) ||
                          (bookingFreelancerName.isNotEmpty && matchKeys.contains(bookingFreelancerName))) &&
                      (status == BookingStatus.accepted.name || status == 'confirmed');
                })
               .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
               .toList(),
          ),
    );
  }

  Stream<List<BookingModel>> getBookingsForClient(String clientId) {
    return _firestore.collection('bookings').snapshots().map(
          (snapshot) => snapshot.docs
             .where((doc) {
                final data = doc.data();
                return data['clientId'] == clientId || data['userId'] == clientId;
              })
             .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
             .toList(),
        );
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _firestore.collection('bookings').doc(bookingId).update({'status': status.name});
  }

  Future<Set<String>> _freelancerIdsForUser(String userId) async {
    final ids = <String>{userId};
    final direct = await _firestore.collection('freelancers').doc(userId).get();
    if (direct.exists) ids.add(direct.id);
    for (final field in ['uid', 'userId', 'ownerId', 'authUid']) {
      final matches = await _firestore.collection('freelancers').where(field, isEqualTo: userId).get();
      ids.addAll(matches.docs.map((doc) => doc.id));
    }
    return ids;
  }

  Future<Set<String>> _freelancerMatchKeys(String userId) async {
    final keys = <String>{userId.trim().toLowerCase()};
    final snapshot = await _firestore.collection('freelancers').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final values = [doc.id, data['uid'], data['userId'], data['ownerId'], data['authUid']].whereType<String>();
      final matchesUser = values.any((value) => value.trim().toLowerCase() == userId.trim().toLowerCase());
      if (!matchesUser) continue;
      keys.addAll(values.map((value) => value.trim().toLowerCase()));
      for (final field in ['companyName', 'name', 'contactPerson']) {
        final value = data[field];
        if (value is String && value.trim().isNotEmpty) {
          keys.add(value.trim().toLowerCase());
        }
      }
    }
    return keys;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserApplication(String userId) {
    return _firestore.collection('freelancer_applications').where('userId', isEqualTo: userId).snapshots();
  }

  Future<void> submitFreelancerApplication({
    required String userId,
    required String userName,
    required String userEmail,
    required String serviceName,
  }) async {
    await _firestore.collection('freelancer_applications').add({
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'requestedService': serviceName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveProviderProfile({
    required String userId,
    required String service,
    required double hourlyRate,
    required String city,
    required String imageUrl,
  }) async {
    await _firestore.collection('freelancers').doc(userId).set({
      'uid': userId,
      'category': service,
      'companyName': service,
      'ratePerHour': hourlyRate,
      'city': city,
      'photoUrl': imageUrl.isEmpty? null : imageUrl,
      'isAvailable': true,
    }, SetOptions(merge: true));
  }

  Future<void> updateApplicationStatus(String applicationId, String status) async {
    await _firestore.collection('freelancer_applications').doc(applicationId).update({'status': status});
  }
}