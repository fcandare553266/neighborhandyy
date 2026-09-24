import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';

class BookingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  BookingProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Freelancer-side
  List<BookingModel> pendingRequests = [];
  List<BookingModel> bookedDates = [];
  // Client-side
  List<BookingModel> myBookings = [];

  bool isSubmitting = false;
  String? errorMessage;

  StreamSubscription? _pendingSub;
  StreamSubscription? _bookedSub;
  StreamSubscription? _myBookingsSub;

  void listenToFreelancerRequests(String freelancerId) {
    _pendingSub?.cancel();
    _pendingSub = _firestoreService
        .getPendingRequestsForFreelancer(freelancerId)
        .listen((list) {
      pendingRequests = list;
      notifyListeners();
    });
  }

  void listenToFreelancerBookedDates(String freelancerId) {
    _bookedSub?.cancel();
    bookedDates = [];
    errorMessage = null;
    notifyListeners();
    _bookedSub = _firestoreService.getBookedDatesForFreelancer(freelancerId).listen((list) {
      bookedDates = list;
      notifyListeners();
    }, onError: (Object error) {
      errorMessage = error.toString();
      notifyListeners();
    });
  }

  void listenToClientBookings(String clientId) {
    _myBookingsSub?.cancel();
    myBookings = [];
    errorMessage = null;
    notifyListeners();
    _myBookingsSub = _firestoreService.getBookingsForClient(clientId).listen(
      (list) {
        myBookings = list;
        notifyListeners();
      },
      onError: (Object error) {
        errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> createBooking(BookingModel booking) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _firestoreService.createBooking(booking);
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> acceptBooking(String bookingId) {
    return _firestoreService.updateBookingStatus(bookingId, BookingStatus.accepted);
  }

  Future<void> declineBooking(String bookingId) {
    return _firestoreService.updateBookingStatus(bookingId, BookingStatus.declined);
  }

  @override
  void dispose() {
    _pendingSub?.cancel();
    _bookedSub?.cancel();
    _myBookingsSub?.cancel();
    super.dispose();
  }
}
