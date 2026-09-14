import os

files = {
    r"lib\features\marketplace\presentation\pages\cart_screen.dart": """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<CartProvider>().loadCart(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CartProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myCart ?? 'My Cart'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(l10n.emptyCart ?? 'Your cart is empty'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.continueShopping ?? 'Continue Shopping'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: _buildGroupedCart(provider.itemsGroupedByFarmer, context, l10n, user?.id ?? ''),
                      ),
                    ),
                    _buildCartTotal(context, provider, l10n),
                  ],
                ),
    );
  }

  List<Widget> _buildGroupedCart(Map<String, List<CartItemEntity>> groupedItems, BuildContext context, AppLocalizations l10n, String customerId) {
    final List<Widget> widgets = [];
    
    groupedItems.forEach((farmerName, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${l10n.farmer ?? 'Farmer'}: $farmerName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              ...items.map((item) => _buildCartItem(item, context, l10n, customerId)),
              const SizedBox(height: 8),
              Text(
                '${l10n.subtotal ?? 'Subtotal'}: ₹${items.fold<double>(0, (sum, i) => sum + i.subtotal).toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    });

    return widgets;
  }

  Widget _buildCartItem(CartItemEntity item, BuildContext context, AppLocalizations l10n, String customerId) {
    final provider = context.read<CartProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('₹${item.price}/${item.unit}'),
                  const SizedBox(height: 4),
                  Text('${l10n.subtotal ?? 'Subtotal'}: ₹${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        provider.updateQuantity(customerId, item.productId, item.quantity - 1);
                      },
                    ),
                    Text('${item.quantity} ${item.unit}'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        provider.updateQuantity(customerId, item.productId, item.quantity + 1);
                      },
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    provider.removeFromCart(customerId, item.productId);
                  },
                  child: Text(l10n.remove ?? 'Remove', style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartTotal(BuildContext context, CartProvider provider, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.grandTotal ?? 'Grand Total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('₹${provider.cartTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.checkout);
                },
                child: Text(l10n.checkout ?? 'Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
""",
    r"lib\features\marketplace\presentation\pages\checkout_screen.dart": """
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

  void _placeOrder(BuildContext context, CartProvider cart, String customerId, String location) async {
    final orderProvider = context.read<OrderProvider>();
    
    // Create one order for each farmer
    final grouped = cart.itemsGroupedByFarmer;
    
    try {
      for (var farmerItems in grouped.values) {
        if (farmerItems.isEmpty) continue;
        
        final orderItems = farmerItems.map((c) => OrderItemEntity(
          productId: c.productId,
          farmerId: c.farmerId,
          productName: c.productName,
          farmerName: c.farmerName,
          price: c.price,
          unit: c.unit,
          quantity: c.quantity,
          subtotal: c.subtotal,
        )).toList();
        
        final total = orderItems.fold<double>(0, (sum, i) => sum + i.subtotal);
        final orderId = 'KM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        
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
      Navigator.pushReplacementNamed(context, AppRouter.orderConfirmation);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      appBar: AppBar(
        title: Text(l10n.orderSummary ?? 'Order Summary'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.deliveryLocation ?? 'Delivery Location', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(location),
                const Divider(),
                const SizedBox(height: 16),
                Text(l10n.items ?? 'Items', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...cart.items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${i.quantity}x ${i.productName} (${i.farmerName})'),
                      Text('₹${i.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
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
                      Expanded(child: Text(l10n.paymentIntegrationComingSoon ?? 'Payment integration coming soon')),
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
                      Text(l10n.grandTotal ?? 'Grand Total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('₹${cart.cartTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _placeOrder(context, cart, customerId, location),
                      child: Text(l10n.placeOrder ?? 'Place Order'),
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
""",
    r"lib\features\marketplace\presentation\pages\order_confirmation_screen.dart": """
import 'package:flutter/material.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/routing/app_router.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 100, color: Colors.green),
                const SizedBox(height: 24),
                Text(
                  l10n.orderPlaced ?? 'Order Placed Successfully!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRouter.myOrders);
                    },
                    child: Text(l10n.viewMyOrders ?? 'View My Orders'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, AppRouter.customer, (route) => false);
                    },
                    child: Text(l10n.continueShopping ?? 'Continue Shopping'),
                  ),
                ),
              ],
            ),
          ),
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
