import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/order.dart';
import 'api_exception.dart';

class OrderService {
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<DeliveryOrder>> getDriverOrders({
    required String driverId,
    required String token,
  }) async {
    final response = await _get(
      Uri.parse(ApiConfig.driverOrders(driverId)),
      token,
    );
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => DeliveryOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DeliveryOrder> getOrderById({
    required String orderId,
    required String token,
  }) async {
    final response = await _get(Uri.parse(ApiConfig.orderById(orderId)), token);
    return DeliveryOrder.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DeliveryOrder> markPickedUp({
    required String orderId,
    required String token,
  }) async {
    final response =
        await _put(Uri.parse(ApiConfig.orderPickup(orderId)), token);
    return DeliveryOrder.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DeliveryOrder> markOutForDelivery({
    required String orderId,
    required String token,
  }) async {
    final response =
        await _put(Uri.parse(ApiConfig.orderOutForDelivery(orderId)), token);
    return DeliveryOrder.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DeliveryOrder> markDelivered({
    required String orderId,
    required String token,
  }) async {
    final response =
        await _put(Uri.parse(ApiConfig.orderDeliver(orderId)), token);
    return DeliveryOrder.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // --- shared HTTP helpers -------------------------------------------------

  Future<http.Response> _get(Uri uri, String token) async {
    try {
      final response = await http
          .get(uri, headers: _headers(token))
          .timeout(ApiConfig.requestTimeout);
      _throwIfError(response);
      return response;
    } on SocketException {
      throw ApiException('Could not reach the server. Check your connection.');
    }
  }

  Future<http.Response> _put(Uri uri, String token) async {
    try {
      final response = await http
          .put(uri, headers: _headers(token))
          .timeout(ApiConfig.requestTimeout);
      _throwIfError(response);
      return response;
    } on SocketException {
      throw ApiException('Could not reach the server. Check your connection.');
    }
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String message = 'Something went wrong (${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? message;
    } catch (_) {
      // response wasn't JSON; keep default message
    }

    if (response.statusCode == 401) {
      throw ApiException('Session expired. Please log in again.', statusCode: 401);
    }
    throw ApiException(message, statusCode: response.statusCode);
  }
}
