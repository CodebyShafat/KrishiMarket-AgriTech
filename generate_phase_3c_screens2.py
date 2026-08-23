import os

files = {
    r"lib\features\marketplace\presentation\pages\my_orders_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/order_entity.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        if (user.role == 'Farmer') {
          context.read<OrderProvider>().loadFarmerOrders(user.id);
        } else {
          context.read<OrderProvider>().loadCustomerOrders(user.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<OrderProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final isFarmer = user?.role == 'Farmer';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myOrders ?? 'My Orders'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.orders.isEmpty
              ? Center(child: Text(l10n.noOrders ?? 'No orders found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.orders.length,
                  itemBuilder: (context, index) {
                    final order = provider.orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.orderDetails,
                            arguments: order,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  _buildStatusChip(order.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${l10n.date ?? 'Date'}: ${order.createdAt.toLocal().toString().split(' ')[0]}'),
                              const SizedBox(height: 4),
                              Text('${l10n.items ?? 'Items'}: ${order.items.length}'),
                              if (isFarmer) ...[
                                const SizedBox(height: 4),
                                Text('${l10n.customer ?? 'Customer'}: ${order.customerId}'),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                '${l10n.total ?? 'Total'}: ₹${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.placed:
        color = Colors.blue;
        break;
      case OrderStatus.accepted:
        color = Colors.indigo;
        break;
      case OrderStatus.preparing:
        color = Colors.orange;
        break;
      case OrderStatus.readyForPickup:
        color = Colors.teal;
        break;
      case OrderStatus.completed:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
""",
    r"lib\features\marketplace\presentation\pages\order_details_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../../domain/entities/order_entity.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsScreen({super.key, required this.order});

  void _cancelOrder(BuildContext context, OrderProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelOrder ?? 'Cancel Order'),
        content: Text(l10n.confirmCancellation ?? 'Are you sure you want to cancel this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
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

  void _updateStatus(BuildContext context, OrderProvider provider, OrderStatus newStatus) {
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
      appBar: AppBar(
        title: Text(l10n.orderDetails ?? 'Order Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderId, style: Theme.of(context).textTheme.headlineSmall),
                Text(order.status.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${l10n.date ?? 'Date'}: ${order.createdAt.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 16),
            const Divider(),
            
            Text(l10n.items ?? 'Items', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ...order.items.map((i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${i.quantity}x ${i.productName} (${i.farmerName})')),
                  Text('₹${i.subtotal.toStringAsFixed(2)}'),
                ],
              ),
            )),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.total ?? 'Total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('₹${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            
            Text(l10n.deliveryLocation ?? 'Delivery Location', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(order.deliveryLocation),
            const SizedBox(height: 32),
            
            if (!isFarmer && order.status == OrderStatus.placed)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelOrder(context, provider, l10n),
                  child: Text(l10n.cancelOrder ?? 'Cancel Order', style: const TextStyle(color: Colors.red)),
                ),
              ),

            if (isFarmer && order.status != OrderStatus.cancelled && order.status != OrderStatus.completed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.updateStatus ?? 'Update Status', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  if (order.status == OrderStatus.placed)
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, provider, OrderStatus.accepted),
                      child: Text(l10n.accepted ?? 'Accept Order'),
                    ),
                  if (order.status == OrderStatus.accepted)
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, provider, OrderStatus.preparing),
                      child: Text(l10n.preparing ?? 'Mark as Preparing'),
                    ),
                  if (order.status == OrderStatus.preparing)
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, provider, OrderStatus.readyForPickup),
                      child: Text(l10n.readyForPickup ?? 'Mark Ready for Pickup'),
                    ),
                  if (order.status == OrderStatus.readyForPickup)
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, provider, OrderStatus.completed),
                      child: Text(l10n.completed ?? 'Mark Completed'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
"""
}

def main():
    for filepath, content in files.items():
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content.strip())
            print(f"Created {filepath}")

if __name__ == '__main__':
    main()
