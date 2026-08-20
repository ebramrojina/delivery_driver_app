import 'package:flutter/material.dart';
import '../models/order.dart';
import '../l10n/app_strings.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.orderNumber(order.id.substring(order.id.length - 6)),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 10),
              _AddressRow(icon: Icons.storefront, label: s.pickup, text: order.pickupAddress.label),
              const SizedBox(height: 4),
              _AddressRow(icon: Icons.location_on, label: s.deliverTo, text: order.deliveryAddress.label),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;

  const _AddressRow({required this.icon, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(color: Colors.grey[800], fontSize: 13),
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
