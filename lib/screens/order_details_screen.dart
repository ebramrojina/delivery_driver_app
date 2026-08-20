import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../services/order_service.dart';
import '../services/api_exception.dart';
import '../widgets/status_badge.dart';
import '../l10n/app_strings.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderService _orderService = OrderService();
  DeliveryOrder? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      final order = await _orderService.getOrderById(
        orderId: widget.orderId,
        token: auth.token!,
      );
      setState(() => _order = order);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openInMaps(double? lat, double? lng, String label) async {
    final s = AppStrings.of(context);
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noCoordinatesFor(label))),
      );
      return;
    }
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleAction() async {
    final order = _order;
    if (order == null) return;

    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();
    final s = AppStrings.of(context);

    final errorMessage = await orderProvider.advanceStatus(
      order: order,
      token: auth.token!,
    );

    if (!mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    // Reflect the update on this screen too (provider updated the list already).
    final refreshed = orderProvider.orders.firstWhere(
      (o) => o.id == order.id,
      orElse: () => order,
    );
    setState(() => _order = refreshed);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.orderUpdatedTo(s.statusLabel(refreshed.status)))),
    );
  }

  String _actionButtonLabel(OrderStatus next, AppStrings s) {
    switch (next) {
      case OrderStatus.pickedUp:
        return s.markPickedUp;
      case OrderStatus.outForDelivery:
        return s.markOutForDelivery;
      case OrderStatus.delivered:
        return s.markDelivered;
      default:
        return s.updateStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final isUpdating = _order != null && orderProvider.updatingOrderId == _order!.id;
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.orderDetails)),
      body: _buildBody(isUpdating, s),
    );
  }

  Widget _buildBody(bool isUpdating, AppStrings s) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadOrder, child: Text(s.retry)),
            ],
          ),
        ),
      );
    }

    final order = _order!;
    final next = order.nextStatus;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.orderNumber(order.id.substring(order.id.length - 6)),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 20),
          _AddressCard(
            icon: Icons.storefront,
            title: s.pickupAddress,
            address: order.pickupAddress,
            openInMapsLabel: s.openInMaps,
            onNavigate: () => _openInMaps(
              order.pickupAddress.lat,
              order.pickupAddress.lng,
              s.pickupAddress,
            ),
          ),
          const SizedBox(height: 12),
          _AddressCard(
            icon: Icons.location_on,
            title: s.deliveryAddress,
            address: order.deliveryAddress,
            openInMapsLabel: s.openInMaps,
            onNavigate: () => _openInMaps(
              order.deliveryAddress.lat,
              order.deliveryAddress.lng,
              s.deliveryAddress,
            ),
          ),
          const SizedBox(height: 20),
          _StatusTimeline(order: order, s: s),
          const SizedBox(height: 28),
          if (next != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUpdating ? null : _handleAction,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_actionButtonLabel(next, s), style: const TextStyle(fontSize: 16)),
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(s.noFurtherAction, style: const TextStyle(color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final DeliveryAddress address;
  final String openInMapsLabel;
  final VoidCallback onNavigate;

  const _AddressCard({
    required this.icon,
    required this.title,
    required this.address,
    required this.openInMapsLabel,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(address.label, style: TextStyle(color: Colors.grey[800])),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: openInMapsLabel,
              onPressed: onNavigate,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final DeliveryOrder order;
  final AppStrings s;
  const _StatusTimeline({required this.order, required this.s});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, h:mm a');

    final steps = <MapEntry<String, DateTime?>>[
      MapEntry(s.statusLabel(OrderStatus.created), order.createdAt),
      MapEntry(s.statusLabel(OrderStatus.assigned), order.assignedAt),
      MapEntry(s.statusLabel(OrderStatus.pickedUp), order.pickedUpAt),
      MapEntry(s.statusLabel(OrderStatus.outForDelivery), order.outForDeliveryAt),
      MapEntry(s.statusLabel(OrderStatus.delivered), order.deliveredAt),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.timeline, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 8),
        ...steps.map((step) {
          final label = step.key;
          final timestamp = step.value;
          final done = timestamp != null;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                  color: done ? Colors.green : Colors.grey[400],
                ),
                const SizedBox(width: 10),
                Text(label, style: TextStyle(color: done ? Colors.black87 : Colors.grey)),
                const Spacer(),
                if (timestamp != null)
                  Text(
                    dateFormat.format(timestamp.toLocal()),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
