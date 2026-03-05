import 'package:flutter/material.dart';

class LaundryService {
  final String id;
  final String title;
  final String description;
  final String price;
  final double ratePerItem; // Base rate per item (e.g. 3.49)
  final IconData icon;
  final Color iconColor;

  const LaundryService({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.ratePerItem,
    required this.icon,
    required this.iconColor,
  });
}
