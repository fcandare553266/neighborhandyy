class FreelancerModel {
  final String uid;
  final String companyName;
  final String contactPerson;
  final String phone;
  final String address;
  final String city; // used to match against a client's saved city
  final String category;
  final String? photoUrl;
  final double ratePerHour;
  final String availability; // e.g. "Mon–Sat, 8AM–6PM"
  final double rating;
  final int jobsCompleted;
  final bool verified;
  final bool isAvailable;
  final bool notificationsEnabled;
  final String about;

  FreelancerModel({
    required this.uid,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    required this.address,
    required this.city,
    required this.category,
    this.photoUrl,
    this.ratePerHour = 0,
    this.availability = '',
    this.rating = 0,
    this.jobsCompleted = 0,
    this.verified = false,
    this.isAvailable = true,
    this.notificationsEnabled = true,
    this.about = '',
  });

  factory FreelancerModel.fromMap(String uid, Map<String, dynamic> map) {
    return FreelancerModel(
      uid: uid,
      companyName: map['companyName'] ?? map['name'] ?? '',
      contactPerson: map['contactPerson'] ?? map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? map['operatingCity'] ?? '',
      category: map['category'] ?? map['serviceRole'] ?? '',
      photoUrl: map['photoUrl'],
      ratePerHour: (map['ratePerHour'] ?? 0).toDouble(),
      availability: map['availability'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      jobsCompleted: map['jobsCompleted'] ?? 0,
      verified: map['verified'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      about: map['about'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'contactPerson': contactPerson,
      'phone': phone,
      'address': address,
      'city': city,
      'category': category,
      'photoUrl': photoUrl,
      'ratePerHour': ratePerHour,
      'availability': availability,
      'rating': rating,
      'jobsCompleted': jobsCompleted,
      'verified': verified,
      'isAvailable': isAvailable,
      'notificationsEnabled': notificationsEnabled,
      'about': about,
    };
  }

  FreelancerModel copyWith({
    String? companyName,
    String? contactPerson,
    String? phone,
    String? address,
    String? city,
    String? photoUrl,
    double? ratePerHour,
    String? availability,
    bool? isAvailable,
    bool? notificationsEnabled,
  }) {
    return FreelancerModel(
      uid: uid,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      category: category,
      photoUrl: photoUrl ?? this.photoUrl,
      ratePerHour: ratePerHour ?? this.ratePerHour,
      availability: availability ?? this.availability,
      rating: rating,
      jobsCompleted: jobsCompleted,
      verified: verified,
      isAvailable: isAvailable ?? this.isAvailable,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      about: about,
    );
  }
}
