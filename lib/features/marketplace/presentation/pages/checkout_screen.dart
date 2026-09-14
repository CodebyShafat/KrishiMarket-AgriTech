import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../../domain/entities/order_entity.dart';

import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  void _placeOrder(
    BuildContext context,
    CartProvider cart,
    String customerId,
    String location,
  ) async {
    final orderProvider = context.read<OrderProvider>();

    // Create one order for each farmer
    final grouped = cart.itemsGroupedByFarmer;

    try {
      for (var farmerItems in grouped.values) {
        if (farmerItems.isEmpty) continue;

        final orderItems = farmerItems
            .map(
              (c) => OrderItemEntity(
                productId: c.productId,
                farmerId: c.farmerId,
                productName: c.productName,
                farmerName: c.farmerName,
                price: c.price,
                unit: c.unit,
                quantity: c.quantity,
                subtotal: c.subtotal,
              ),
            )
            .toList();

        final total = orderItems.fold<double>(0, (sum, i) => sum + i.subtotal);
        final orderId =
            'KM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

        final order = OrderEntity(
          orderId: orderId,
          customerId: customerId,
          items: orderItems,
          totalAmount: total,
          status: OrderStatus.placed,
          createdAt: DateTime.now(),
          deliveryLocation: location,
        );

        await orderProvider.createOrder(order);
      }

      await cart.clearCart(customerId);
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.orderConfirmation);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cart = context.watch<CartProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final customerId = user?.id ?? '';
    final location = user?.location ?? 'Default Location';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderSummary)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.deliveryLocation,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(location),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  l10n.items,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...cart.items.map(
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${i.quantity}x ${i.productName} (${i.farmerName})',
                        ),
                        Text('₹${i.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.paymentIntegrationComingSoon)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.grandTotal,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${cart.cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: context.watch<OrderProvider>().isLoading || cart.isLoading
                          ? null
                          : () => _placeOrder(context, cart, customerId, location),
                      child: context.watch<OrderProvider>().isLoading || cart.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.placeOrder),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
