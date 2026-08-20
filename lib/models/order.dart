/// Mirrors the status flow enforced server-side:
/// created -> assigned -> picked_up -> out_for_delivery -> delivered
enum OrderStatus { created, assigned, pickedUp, outForDelivery, delivered, unknown }

OrderStatus orderStatusFromString(String? value) {
  switch (value) {
    case 'created':
      return OrderStatus.created;
    case 'assigned':
      return OrderStatus.assigned;
    case 'picked_up':
      return OrderStatus.pickedUp;
    case 'out_for_delivery':
      return OrderStatus.outForDelivery;
    case 'delivered':
      return OrderStatus.delivered;
    default:
      return OrderStatus.unknown;
  }
}

String orderStatusToApiString(OrderStatus status) {
  switch (status) {
    case OrderStatus.created:
      return 'created';
    case OrderStatus.assigned:
      return 'assigned';
    case OrderStatus.pickedUp:
      return 'picked_up';
    case OrderStatus.outForDelivery:
      return 'out_for_delivery';
    case OrderStatus.delivered:
      return 'delivered';
    case OrderStatus.unknown:
      return 'unknown';
  }
}

class DeliveryAddress {
  final String label;
  final double? lat;
  final double? lng;

  DeliveryAddress({required this.label, this.lat, this.lng});

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      label: json['label'] as String? ?? 'No address provided',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}

class DeliveryOrder {
  final String id;
  final String customerId;
  final String? driverId;
  final OrderStatus status;
  final DeliveryAddress pickupAddress;
  final DeliveryAddress deliveryAddress;
  final DateTime? createdAt;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;

  DeliveryOrder({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.status,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.createdAt,
    this.assignedAt,
    this.pickedUpAt,
    this.outForDeliveryAt,
    this.deliveredAt,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    // customerId/driverId may come back populated (as objects) or as raw id strings
    String? extractId(dynamic field) {
      if (field == null) return null;
      if (field is String) return field;
      if (field is Map<String, dynamic>) return field['_id'] as String?;
      return null;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value as String);
    }

    return DeliveryOrder(
      id: json['_id'] as String,
      customerId: extractId(json['customerId']) ?? '',
      driverId: extractId(json['driverId']),
      status: orderStatusFromString(json['status'] as String?),
      pickupAddress: DeliveryAddress.fromJson(
          json['pickupAddress'] as Map<String, dynamic>? ?? {}),
      deliveryAddress: DeliveryAddress.fromJson(
          json['deliveryAddress'] as Map<String, dynamic>? ?? {}),
      createdAt: parseDate(json['createdAt']),
      assignedAt: parseDate(json['assignedAt']),
      pickedUpAt: parseDate(json['pickedUpAt']),
      outForDeliveryAt: parseDate(json['outForDeliveryAt']),
      deliveredAt: parseDate(json['deliveredAt']),
    );
  }

  /// The single next valid action a driver can take from the current status,
  /// or null if there's nothing left to do (delivered / not yet assigned).
  OrderStatus? get nextStatus {
    switch (status) {
      case OrderStatus.assigned:
        return OrderStatus.pickedUp;
      case OrderStatus.pickedUp:
        return OrderStatus.outForDelivery;
      case OrderStatus.outForDelivery:
        return OrderStatus.delivered;
      default:
        return null;
    }
  }
}
