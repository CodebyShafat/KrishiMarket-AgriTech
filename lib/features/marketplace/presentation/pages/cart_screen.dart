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
      appBar: AppBar(title: Text(l10n.myCart)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.emptyCart),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.continueShopping),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: _buildGroupedCart(
                      provider.itemsGroupedByFarmer,
                      context,
                      l10n,
                      user?.id ?? '',
                    ),
                  ),
                ),
                _buildCartTotal(context, provider, l10n),
              ],
            ),
    );
  }

  List<Widget> _buildGroupedCart(
    Map<String, List<CartItemEntity>> groupedItems,
    BuildContext context,
    AppLocalizations l10n,
    String customerId,
  ) {
    final List<Widget> widgets = [];

    groupedItems.forEach((farmerName, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${l10n.farmer}: $farmerName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(),
              ...items.map(
                (item) => _buildCartItem(item, context, l10n, customerId),
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.subtotal}: ₹${items.fold<double>(0, (sum, i) => sum + i.subtotal).toStringAsFixed(2)}',
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

  Widget _buildCartItem(
    CartItemEntity item,
    BuildContext context,
    AppLocalizations l10n,
    String customerId,
  ) {
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
                  Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('₹${item.price}/${item.unit}'),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.subtotal}: ₹${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
                  ),
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
                        provider.updateQuantity(
                          customerId,
                          item.productId,
                          item.quantity - 1,
                        );
                      },
                    ),
                    Text('${item.quantity} ${item.unit}'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        provider.updateQuantity(
                          customerId,
                          item.productId,
                          item.quantity + 1,
                        );
                      },
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    provider.removeFromCart(customerId, item.productId);
                  },
                  child: Text(
                    l10n.remove,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartTotal(
    BuildContext context,
    CartProvider provider,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
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
                  '₹${provider.cartTotal.toStringAsFixed(2)}',
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
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.checkout);
                },
                child: Text(l10n.checkout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
