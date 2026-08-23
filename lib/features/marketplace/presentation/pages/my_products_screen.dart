import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

import 'package:krishimarket/core/routing/app_router.dart';
import 'package:krishimarket/l10n/app_localizations.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final farmerId = authProvider.currentUser?.id ?? 'test-farmer-id';
      context.read<ProductProvider>().loadFarmerProducts(farmerId);
    });
  }

  void _confirmDelete(BuildContext context, String productId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(productId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l10n.productDeleted)));
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProducts)),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.products.isEmpty) {
            return Center(child: Text(l10n.noProducts));
          }

          return ListView.builder(
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.productDetails,
                    arguments: product,
                  );
                },
                onEdit: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.addProduct,
                    arguments: product,
                  );
                },
                onDelete: () => _confirmDelete(context, product.productId),
                onToggleAvailability: () {
                  provider.toggleAvailability(product.productId);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addProduct);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
