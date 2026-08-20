import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/api_exception.dart';

/// Holds the driver's order list and handles status-update actions.
///
/// Real-time hook point: when Socket.IO is added, listen for an
/// `order:statusUpdated` event elsewhere in the app and call
/// [applyServerUpdate] with the incoming order — the UI will refresh
/// automatically since this is a ChangeNotifier. No screen code needs
/// to change.
class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<DeliveryOrder> orders = [];
  bool isLoading = false;
  String? errorMessage;

  /// Order id currently mid-update, so the UI can disable just that
  /// order's button instead of blocking the whole screen.
  String? updatingOrderId;

  Future<void> fetchDriverOrders({
    required String driverId,
    required String token,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      orders = await _orderService.getDriverOrders(driverId: driverId, token: token);
      // Most relevant / actionable orders first.
      orders.sort((a, b) => a.status.index.compareTo(b.status.index));
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Advances [order] to its next valid status (pickup -> out-for-delivery -> delivered).
  /// Returns an error message on failure, or null on success.
  Future<String?> advanceStatus({
    required DeliveryOrder order,
    required String token,
  }) async {
    final next = order.nextStatus;
    if (next == null) return 'This order has no further action available.';

    updatingOrderId = order.id;
    notifyListeners();

    try {
      DeliveryOrder updated;
      switch (next) {
        case OrderStatus.pickedUp:
          updated = await _orderService.markPickedUp(orderId: order.id, token: token);
          break;
        case OrderStatus.outForDelivery:
          updated = await _orderService.markOutForDelivery(orderId: order.id, token: token);
          break;
        case OrderStatus.delivered:
          updated = await _orderService.markDelivered(orderId: order.id, token: token);
          break;
        default:
          return 'Unsupported status transition.';
      }
      applyServerUpdate(updated);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      updatingOrderId = null;
      notifyListeners();
    }
  }

  /// Replaces an order in the local list with a fresher copy from the
  /// server (used after a manual update now, and by a socket listener later).
  void applyServerUpdate(DeliveryOrder updated) {
    final index = orders.indexWhere((o) => o.id == updated.id);
    if (index == -1) {
      orders.add(updated);
    } else {
      orders[index] = updated;
    }
    notifyListeners();
  }

  void clear() {
    orders = [];
    errorMessage = null;
    notifyListeners();
  }
}
