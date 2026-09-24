import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, accepted, declined, completed, cancelled }

BookingStatus bookingStatusFromString(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'confirmed') return BookingStatus.accepted;
  if (normalized == 'denied') return BookingStatus.declined;
  return BookingStatus.values.firstWhere(
    (e) => e.name == normalized,
    orElse: () => BookingStatus.pending,
  );
}

class BookingModel {
  final String id;
  final String clientId;
  final String clientName;
  final String clientAddress;
  final String clientPhone;
  final String freelancerId;
  final String freelancerName;
  final String category;
  final DateTime date;
  final String time; // display string, e.g. "2:00 PM"
  final BookingStatus status;
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientAddress,
    required this.clientPhone,
    required this.freelancerId,
    required this.freelancerName,
    required this.category,
    required this.date,
    required this.time,
    this.status = BookingStatus.pending,
    this.createdAt,
  });

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['date'] ?? map['bookingDate'];
    final parsedDate = rawDate is Timestamp
        ? rawDate.toDate()
        : DateTime.tryParse(rawDate?.toString() ?? '');
    return BookingModel(
      id: id,
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientAddress: map['clientAddress'] ?? map['address'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      freelancerId: map['freelancerId'] ?? '',
      freelancerName: map['freelancerName'] ?? map['name'] ?? 'Freelancer',
      category: map['category'] ?? map['serviceType'] ?? '',
      date: parsedDate ?? DateTime.now(),
      time: map['time'] ?? map['bookingTime'] ?? '',
      status: bookingStatusFromString(
        (map['status'] ?? 'pending').toString().toLowerCase(),
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'clientAddress': clientAddress,
      'clientPhone': clientPhone,
      'freelancerId': freelancerId,
      'freelancerName': freelancerName,
      'category': category,
      'date': date.toIso8601String(),
      'time': time,
      'status': status.name,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }
}
