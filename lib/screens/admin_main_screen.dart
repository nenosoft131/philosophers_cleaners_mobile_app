import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  late Future<List<LaundryOrder>> _ordersFuture;
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService.fetchOrders();
  }

  Future<void> _logout() async {
    await StorageService.deleteToken();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _refresh() {
    setState(() {
      _ordersFuture = ApiService.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusFilterChip(
                    label: 'All',
                    value: 'all',
                    groupValue: _selectedStatusFilter,
                    onSelected: (v) {
                      if (v) {
                        setState(() => _selectedStatusFilter = 'all');
                      }
                    },
                  ),
                  _StatusFilterChip(
                    label: 'Pending',
                    value: 'pending',
                    groupValue: _selectedStatusFilter,
                    onSelected: (v) {
                      if (v) {
                        setState(() => _selectedStatusFilter = 'pending');
                      }
                    },
                  ),
                  _StatusFilterChip(
                    label: 'Processing',
                    value: 'processing',
                    groupValue: _selectedStatusFilter,
                    onSelected: (v) {
                      if (v) {
                        setState(() => _selectedStatusFilter = 'processing');
                      }
                    },
                  ),
                  _StatusFilterChip(
                    label: 'Completed',
                    value: 'completed',
                    groupValue: _selectedStatusFilter,
                    onSelected: (v) {
                      if (v) {
                        setState(() => _selectedStatusFilter = 'completed');
                      }
                    },
                  ),
                  _StatusFilterChip(
                    label: 'Cancelled',
                    value: 'cancelled',
                    groupValue: _selectedStatusFilter,
                    onSelected: (v) {
                      if (v) {
                        setState(() => _selectedStatusFilter = 'cancelled');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LaundryOrder>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load orders: ${snapshot.error}'),
                  );
                }
                var orders = snapshot.data ?? [];
                if (_selectedStatusFilter != 'all') {
                  orders = orders
                      .where((o) =>
                          o.status.toLowerCase() ==
                          _selectedStatusFilter.toLowerCase())
                      .toList();
                }
                if (orders.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _AdminOrderTile(order: order);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: orders.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<bool> onSelected;

  const _StatusFilterChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}

class _AdminOrderTile extends StatelessWidget {
  final LaundryOrder order;

  const _AdminOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: order.statusColor(context).withOpacity(0.15),
          child: Text(
            order.serviceName.isNotEmpty
                ? order.serviceName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: order.statusColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(order.serviceName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${order.clientEmail}'),
            Text(
              'Placed on ${order.createdAt.toLocal().toString().split(".").first}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
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

