import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../widgets/order_card.dart';
import 'order_details_screen.dart';
import 'login_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null || auth.token == null) return;

    await context.read<OrderProvider>().fetchDriverOrders(
          driverId: auth.currentUser!.id,
          token: auth.token!,
        );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    context.read<OrderProvider>().clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.hiName(auth.currentUser?.name.split(' ').first ?? '')),
        actions: [
          TextButton(
            onPressed: () => context.read<LocaleProvider>().toggleLocale(),
            child: Text(s.switchLanguage, style: const TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: s.logOut,
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _buildBody(orderProvider, s),
      ),
    );
  }

  Widget _buildBody(OrderProvider orderProvider, AppStrings s) {
    if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProvider.errorMessage != null && orderProvider.orders.isEmpty) {
      return _ErrorState(message: orderProvider.errorMessage!, onRetry: _loadOrders, retryLabel: s.retry);
    }

    if (orderProvider.orders.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${s.noOrdersYet}\n${s.pullToRefresh}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: orderProvider.orders.length,
      itemBuilder: (context, index) {
        final order = orderProvider.orders[index];
        return OrderCard(
          order: order,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: order.id)),
            );
          },
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const _ErrorState({required this.message, required this.onRetry, required this.retryLabel});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
