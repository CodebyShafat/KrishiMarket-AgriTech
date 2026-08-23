import 'package:flutter_test/flutter_test.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_product_repository.dart';
import 'package:krishimarket/features/marketplace/domain/entities/product_entity.dart';

void main() {
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
  });

  group('MockProductRepository', () {
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

    test('should add a product and retrieve it', () async {
      await repository.createProduct(product);
      final products = await repository.getFarmerProducts('farmer1');
      expect(products.length, 1);
      expect(products.first.name, 'Wheat');
    });

    test('should update a product', () async {
      await repository.createProduct(product);
      final updated = product.copyWith(price: 120);
      await repository.updateProduct(updated);
      final fetched = await repository.getProductById('1');
      expect(fetched.price, 120);
    });

    test('should delete a product', () async {
      await repository.createProduct(product);
      await repository.deleteProduct('1');
      final products = await repository.getFarmerProducts('farmer1');
      expect(products.isEmpty, true);
    });

    test('should toggle availability', () async {
      await repository.createProduct(product);
      await repository.toggleAvailability('1');
      final fetched = await repository.getProductById('1');
      expect(fetched.isAvailable, false);
    });
  });
}
