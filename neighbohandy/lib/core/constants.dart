/// Firestore collection names & other app-wide constants.
class FirestoreCollections {
  FirestoreCollections._();
  static const users = 'users';
  static const freelancers = 'freelancers';
  static const bookings = 'bookings';
  static const categories = 'categories';
}

class UserRole {
  UserRole._();
  static const client = 'client';
  static const freelancer = 'freelancer';
  static const admin = 'admin';
}
