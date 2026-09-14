import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/utils/category_localizer.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductEntity product;

  const ProductDetailsScreen({super.key, required this.product});

  void _addToCart(BuildContext context, AppLocalizations l10n) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final cartItem = CartItemEntity(
      productId: product.productId,
      farmerId: product.farmerId,
      productName: product.name,
      farmerName: product.farmerId, // mock using farmerId for name
      price: product.price,
      unit: product.unit,
      quantity: 1, // default 1
      quality: product.qualityGrade,
      availableQuantity: product.availableQuantity,
    );

    try {
      await context.read<CartProvider>().addToCart(user.id, cartItem);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.addedToCart)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().currentUser;
    final isCustomer = user?.role?.toLowerCase() == 'retail_buyer' || user?.role?.toLowerCase() == 'customer';

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 64, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.category}: ${CategoryLocalizer.getLocalizedCategory(product.category, l10n)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.price}: ₹${product.price}/${product.unit}',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.quantity}: ${product.availableQuantity} ${product.unit}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  Text(
                    l10n.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(product.description),
                  const SizedBox(height: 16),
                  Text('${l10n.farmerId}: ${product.farmerId}'),
                  const SizedBox(height: 8),
                  Text('${l10n.quality}: ${product.qualityGrade}'),
                  const SizedBox(height: 8),
                  Text('${l10n.location}: ${product.location}'),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.harvestDate}: ${product.harvestDate.toLocal().toString().split(' ')[0]}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.isAvailable ? (l10n.available) : (l10n.unavailable),
                    style: TextStyle(
                      color: product.isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isCustomer)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            product.isAvailable && product.availableQuantity > 0
                            ? () => _addToCart(context, l10n)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(l10n.addToCart),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
