import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ServiceDetailScreen extends StatefulWidget {
  final LaundryService service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String? _clothesType;
  int _quantity = 1;
  String? _size;
  String? _dropBoxId;
  bool _isSubmitting = false;

  final List<Map<String, String>> _clothesTypes = [
    {'value': 'shirts', 'label': 'Shirts'},
    {'value': 'pants', 'label': 'Pants'},
    {'value': 'dresses', 'label': 'Dresses'},
    {'value': 'skirts', 'label': 'Skirts'},
    {'value': 'jackets', 'label': 'Jackets'},
    {'value': 'bedsheets', 'label': 'Bedsheets'},
    {'value': 'towels', 'label': 'Towels'},
    {'value': 'mixed', 'label': 'Mixed'},
  ];

  final List<String> _sizes = ['Small', 'Medium', 'Large'];

  static const double _serviceCharge = 2.50;

  double _getSizeMultiplier(String? size) {
    switch (size?.toLowerCase()) {
      case 'medium':
        return 1.15;
      case 'large':
        return 1.35;
      default:
        return 1.0;
    }
  }

  Map<String, double> _getCharges() {
    final multiplier = _getSizeMultiplier(_size);
    final subtotal = (_quantity * widget.service.ratePerItem * multiplier);
    final total = subtotal + _serviceCharge;
    return {
      'subtotal': subtotal,
      'serviceCharge': _serviceCharge,
      'total': total
    };
  }

  @override
  void initState() {
    super.initState();
    _loadStoredEmail();
  }

  Future<void> _loadStoredEmail() async {
    final email = await StorageService.getUserEmail();
    if (mounted && email != null && email.isNotEmpty) {
      setState(() => _emailController.text = email);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );
    if (result != null && mounted) {
      setState(() => _dropBoxId = result);
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clothesType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select clothes type')),
      );
      return;
    }
    if (_size == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select size')),
      );
      return;
    }
    if (_dropBoxId == null || _dropBoxId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan the drop box QR code')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final charges = _getCharges();
      final orderData = {
        'service_id': widget.service.id,
        'service_name': widget.service.title,
        'clothes_type': _clothesType,
        'quantity': _quantity,
        'size': _size!.toLowerCase(),
        'drop_box_id': _dropBoxId,
        'client_email': _emailController.text.trim(),
        'subtotal': charges['subtotal'],
        'service_charge': charges['serviceCharge'],
        'total': charges['total'],
      };

      await ApiService.submitOrder(orderData);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.title),
        titleTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            widget.service.iconColor.withOpacity(0.2),
                        child: Icon(widget.service.icon,
                            size: 36, color: widget.service.iconColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.service.title,
                                style: Theme.of(context).textTheme.titleLarge),
                            Text(widget.service.description,
                                style: TextStyle(color: Colors.grey[600])),
                            Text('from ${widget.service.price}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1565C0))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Clothes type
              const Text('Clothes Type *',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _clothesType,
                decoration: _inputDecoration(),
                items: _clothesTypes
                    .map((e) => DropdownMenuItem(
                        value: e['value'], child: Text(e['label']!)))
                    .toList(),
                onChanged: (v) => setState(() => _clothesType = v),
              ),
              const SizedBox(height: 20),

              // Quantity
              const Text('Quantity *',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filled(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove)),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_quantity',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton.filled(
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(Icons.add)),
                ],
              ),
              const SizedBox(height: 20),

              // Size
              const Text('Size *',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _sizes.map((s) {
                  final selected = _size == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: selected,
                    onSelected: (v) => setState(() => _size = v ? s : null),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Drop box QR
              const Text('Drop Box ID *',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _scanQRCode,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code_scanner,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _dropBoxId ?? 'Tap to scan QR code on drop box',
                          style: TextStyle(
                              color: _dropBoxId != null
                                  ? Colors.black87
                                  : Colors.grey[600]),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Client email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(label: 'Client Email *'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter email';
                  if (!v.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Charges breakdown
              _ChargesSummary(
                quantity: _quantity,
                ratePerItem: widget.service.ratePerItem,
                size: _size,
                sizeMultiplier: _getSizeMultiplier(_size),
                serviceCharge: _serviceCharge,
              ),
              const SizedBox(height: 24),

              // Submit
              FilledButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? label}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _ChargesSummary extends StatelessWidget {
  final int quantity;
  final double ratePerItem;
  final String? size;
  final double sizeMultiplier;
  final double serviceCharge;

  const _ChargesSummary({
    required this.quantity,
    required this.ratePerItem,
    required this.size,
    required this.sizeMultiplier,
    required this.serviceCharge,
  });

  String _format(double value) => '£${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final unitRate = ratePerItem * sizeMultiplier;
    final subtotal = quantity * unitRate;
    final total = subtotal + serviceCharge;

    final sizeNote = sizeMultiplier != 1 && size != null
        ? ' ($size: ${((sizeMultiplier - 1) * 100).round()}% extra)'
        : '';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Charges Summary',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildRow(
                'Subtotal',
                '$quantity items × ${_format(unitRate)}$sizeNote',
                _format(subtotal)),
            const SizedBox(height: 8),
            _buildRow('Service charge', 'Fixed fee', _format(serviceCharge)),
            const Divider(),
            _buildRow('Total', '', _format(total), isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String detail, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                        fontSize: isTotal ? 16 : 14)),
                if (detail.isNotEmpty)
                  Text(detail,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Text(value,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  fontSize: isTotal ? 18 : 14,
                  color: isTotal ? const Color(0xFF1565C0) : null)),
        ],
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final code =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;

    if (code != null && code.isNotEmpty) {
      _isProcessing = true;
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Drop Box QR Code')),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect, controller: _controller),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Position QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
            ),
          ),
        ],
      ),
    );
  }
}
