class Booking {
  final String id;
  final String providerName;
  final String serviceName;
  final String clientAddress;
  final String city;
  final DateTime scheduledTime;
  final double totalCost;
  final String paymentMethod;
  String status; // 'pending', 'accepted', 'declined', 'completed'

  Booking({
    required this.id,
    required this.providerName,
    required this.serviceName,
    required this.clientAddress,
    required this.city,
    required this.scheduledTime,
    required this.totalCost,
    required this.paymentMethod,
    this.status = 'pending',
  });
}