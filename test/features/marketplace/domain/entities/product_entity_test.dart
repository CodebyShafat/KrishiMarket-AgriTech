import 'package:flutter_test/flutter_test.dart';
import 'package:krishimarket/features/marketplace/domain/entities/product_entity.dart';

void main() {
  group('ProductEntity', () {
    test('should copy with new values', () {
      final product = ProductEntity(
        productId: '1',
        farmerId: 'farmer1',
        name: 'Wheat',
        category: 'Grains',
        description: 'Good wheat',
        qualityGrade: 'A',
        price: 100,
        unit: 'kg',
        availableQuantity: 50,
        location: 'Pune',
        harvestDate: DateTime(2023),
        isAvailable: true,
        createdAt: DateTime(2023),
      );

      final updatedProduct = product.copyWith(price: 150, isAvailable: false);

      expect(updatedProduct.price, 150);
      expect(updatedProduct.isAvailable, false);
      expect(updatedProduct.name, 'Wheat');
    });
  });
}
