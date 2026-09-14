import 'package:flutter/material.dart';

import '../../../marketplace/domain/entities/product_entity.dart';

class ProductResultCard extends StatelessWidget {
  final dynamic product; // Usually ProductEntity

  const ProductResultCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    if (product is! ProductEntity) return const SizedBox();
    final p = product as ProductEntity;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text('₹${p.price}/${p.unit}'),
            Text('Farmer: ${p.farmerId}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('View')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
