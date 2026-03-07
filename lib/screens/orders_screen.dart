import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Future<List<LaundryOrder>> _loadOrders() {
    return ApiService.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<LaundryOrder>>(
        future: _loadOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load orders: ${snapshot.error}'),
            );
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders yet.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderTile(order: order);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: orders.length,
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final LaundryOrder order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(order.serviceName),
        subtitle: Text(
          'Placed on ${order.createdAt.toLocal().toString().split(".").first}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '£${order.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: order.statusColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: order.statusColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
