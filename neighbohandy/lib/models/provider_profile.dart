import 'package:flutter/material.dart';

class ProviderProfile {
  final String id;
  final String name;
  final String service;
  final double hourlyRate;
  final String city;
  final double rating;
  final String imageUrl;
  final bool isAvailable;

  const ProviderProfile({
    required this.id,
    required this.name,
    required this.service,
    required this.hourlyRate,
    required this.city,
    required this.rating,
    required this.imageUrl,
    this.isAvailable = true,
  });

  ProviderProfile copyWith({
    String? id,
    String? name,
    String? service,
    double? hourlyRate,
    String? city,
    double? rating,
    String? imageUrl,
    bool? isAvailable,
  }) {
    return ProviderProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      service: service ?? this.service,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  String get initials {
    if (name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String get price => '₱${hourlyRate.toStringAsFixed(0)}';

  Color get color {
    const palette = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return palette[name.hashCode.abs() % palette.length];
  }
}