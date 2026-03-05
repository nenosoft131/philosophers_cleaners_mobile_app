import 'package:flutter/material.dart';

class LaundryOrder {
  final String id;
  final String serviceName;
  final String clientEmail;
  final String status;
  final double total;
  final DateTime createdAt;

  const LaundryOrder({
    required this.id,
    required this.serviceName,
    required this.clientEmail,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  factory LaundryOrder.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'];
    DateTime createdAt;
    if (created is String) {
      createdAt = DateTime.tryParse(created) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return LaundryOrder(
      id: (json['id'] ?? '').toString(),
      serviceName: (json['service_name'] ?? json['service'] ?? 'Service') as String,
      clientEmail: (json['client_email'] ?? json['email'] ?? 'Unknown') as String,
      status: (json['status'] ?? 'pending') as String,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: createdAt,
    );
  }

  Color statusColor(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

