import 'user_role.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String role; // 'resident' | 'freelancer' | 'admin'
  final String? photoUrl;
  final bool notificationsEnabled;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.city = '',
    this.role = 'resident',
    this.photoUrl,
    this.notificationsEnabled = true,
    this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name']?? map['fullName']?? '',
      email: map['email']?? '',
      phone: map['phone']?? map['mobileNumber']?? '',
      address: map['address']?? '',
      city: map['city']?? '',
      role: _normalizeRole(
        map['role']?? map['accountType']?? map['userRole']?? 'resident',
      ),
      photoUrl: map['photoUrl'],
      notificationsEnabled: map['notificationsEnabled']?? true,
      createdAt: map['createdAt']!= null
         ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  static String _normalizeRole(Object? value) {
    final role = userRoleFromValue(value);
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.freelancer:
        return 'freelancer';
      case UserRole.resident:
        return 'resident';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'role': role,
      'photoUrl': photoUrl,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? role,
    String? photoUrl,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      uid: uid,
      name: name?? this.name,
      email: email?? this.email,
      phone: phone?? this.phone,
      address: address?? this.address,
      city: city?? this.city,
      role: role?? this.role,
      photoUrl: photoUrl?? this.photoUrl,
      notificationsEnabled: notificationsEnabled?? this.notificationsEnabled,
      createdAt: createdAt,
    );
  }
}