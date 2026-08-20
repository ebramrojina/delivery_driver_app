/// Central place for backend connection settings.
/// Change [baseUrl] to point at your running backend.
class ApiConfig {
  ApiConfig._();

  // Android emulator -> host machine localhost is 10.0.2.2
  // iOS simulator / physical device on same network -> use your machine's LAN IP
  // Production -> your deployed backend URL
  static const String baseUrl = 'https://delivery-backend-vtwh.onrender.com/api';

  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  static String driverOrders(String driverId) => '$baseUrl/orders/driver/$driverId';
  static String orderById(String orderId) => '$baseUrl/orders/$orderId';
  static String orderPickup(String orderId) => '$baseUrl/orders/$orderId/pickup';
  static String orderOutForDelivery(String orderId) => '$baseUrl/orders/$orderId/out-for-delivery';
  static String orderDeliver(String orderId) => '$baseUrl/orders/$orderId/deliver';

  static const Duration requestTimeout = Duration(seconds: 60);
}
