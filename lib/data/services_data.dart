import 'package:flutter/material.dart';
import '../models/service.dart';

class ServicesData {
  static final List<LaundryService> services = [
    const LaundryService(
      id: 'wash',
      title: 'Wash',
      description: 'For everyday laundry, bedsheets and towels.',
      price: '£3.49',
      ratePerItem: 3.49,
      icon: Icons.water_drop,
      iconColor: Color(0xFF2196F3),
    ),
    const LaundryService(
      id: 'wash_iron',
      title: 'Wash & Iron',
      description: 'For everyday laundry that requires ironing.',
      price: '£1.95',
      ratePerItem: 1.95,
      icon: Icons.iron,
      iconColor: Color(0xFFE91E63),
    ),
    const LaundryService(
      id: 'dry_cleaning',
      title: 'Dry Cleaning',
      description: 'For delicate items and fabrics.',
      price: '£1.95',
      ratePerItem: 1.95,
      icon: Icons.ac_unit,
      iconColor: Color(0xFF009688),
    ),
    const LaundryService(
      id: 'ironing_only',
      title: 'Ironing only',
      description: 'For items that are already clean.',
      price: '£1.45',
      ratePerItem: 1.45,
      icon: Icons.iron,
      iconColor: Color(0xFFFFC107),
    ),
    const LaundryService(
      id: 'duvets_bulky',
      title: 'Duvets & Bulky Items',
      description: 'For larger items that require extra care.',
      price: '£11.95',
      ratePerItem: 11.95,
      icon: Icons.bed,
      iconColor: Color(0xFF03A9F4),
    ),
  ];
}
