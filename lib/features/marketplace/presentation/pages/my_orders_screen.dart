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
      appBar: AppBar(title: Text(l10n.myOrders)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.orders.isEmpty
          ? Center(child: Text(l10n.noOrders))
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
                              Text(
                                order.orderId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildStatusChip(order.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.date}: ${order.createdAt.toLocal().toString().split(' ')[0]}',
                          ),
                          const SizedBox(height: 4),
                          Text('${l10n.items}: ${order.items.length}'),
                          if (isFarmer) ...[
                            const SizedBox(height: 4),
                            Text('${l10n.customer}: ${order.customerId}'),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.total}: ₹${order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
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
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
