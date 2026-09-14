import 'package:flutter/material.dart';

import '../../domain/entities/product_entity.dart';

import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/core/utils/category_localizer.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text('${l10n.category}: ${CategoryLocalizer.getLocalizedCategory(product.category, l10n)}'),
                    const SizedBox(height: 4),
                    Text('${l10n.price}: ₹${product.price}/${product.unit}'),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.quantity}: ${product.availableQuantity} ${product.unit}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.isAvailable ? l10n.available : l10n.unavailable,
                      style: TextStyle(
                        color: product.isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                  Switch(
                    value: product.isAvailable,
                    onChanged: (val) => onToggleAvailability(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
