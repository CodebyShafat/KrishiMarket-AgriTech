import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../../domain/entities/order_entity.dart';

import 'package:krishimarket/l10n/app_localizations.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsScreen({super.key, required this.order});

  void _cancelOrder(
    BuildContext context,
    OrderProvider provider,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelOrder),
        content: Text(l10n.confirmCancellation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              provider.cancelOrder(order.orderId);
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back to orders list
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateStatus(
    BuildContext context,
    OrderProvider provider,
    OrderStatus newStatus,
  ) {
    provider.updateOrderStatus(order.orderId, newStatus);
    Navigator.pop(context); // Assuming we pop after updating or refresh
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().currentUser;
    final isFarmer = user?.role == 'Farmer';
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderDetails)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  order.status.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.date}: ${order.createdAt.toLocal().toString().split(' ')[0]}',
            ),
            const SizedBox(height: 16),
            const Divider(),

            Text(
              l10n.items,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            ...order.items.map(
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${i.quantity}x ${i.productName} (${i.farmerName})',
                      ),
                    ),
                    Text('₹${i.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            Text(
              l10n.deliveryLocation,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(order.deliveryLocation),
            const SizedBox(height: 32),

            if (!isFarmer && order.status == OrderStatus.placed)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelOrder(context, provider, l10n),
                  child: Text(
                    l10n.cancelOrder,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),

            if (isFarmer &&
                order.status != OrderStatus.cancelled &&
                order.status != OrderStatus.completed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.updateStatus,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (order.status == OrderStatus.placed)
                    ElevatedButton(
                      onPressed: () => _updateStatus(
                        context,
                        provider,
                        OrderStatus.accepted,
                      ),
                      child: Text(l10n.accepted),
                    ),
                  if (order.status == OrderStatus.accepted)
                    ElevatedButton(
                      onPressed: () => _updateStatus(
                        context,
                        provider,
                        OrderStatus.preparing,
                      ),
                      child: Text(l10n.preparing),
                    ),
                  if (order.status == OrderStatus.preparing)
                    ElevatedButton(
                      onPressed: () => _updateStatus(
                        context,
                        provider,
                        OrderStatus.readyForPickup,
                      ),
                      child: Text(l10n.readyForPickup),
                    ),
                  if (order.status == OrderStatus.readyForPickup)
                    ElevatedButton(
                      onPressed: () => _updateStatus(
                        context,
                        provider,
                        OrderStatus.completed,
                      ),
                      child: Text(l10n.completed),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
