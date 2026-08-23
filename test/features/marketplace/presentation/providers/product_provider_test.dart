import 'package:flutter_test/flutter_test.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_product_repository.dart';
import 'package:krishimarket/features/marketplace/domain/entities/product_entity.dart';
import 'package:krishimarket/features/marketplace/presentation/providers/product_provider.dart';

void main() {
  late ProductProvider provider;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    provider = ProductProvider(repository);
  });

  group('ProductProvider', () {
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

    test('initial state', () {
      expect(provider.isLoading, false);
      expect(provider.products.isEmpty, true);
    });

    test('addProduct and load products', () async {
      await provider.addProduct(product);
      expect(provider.products.length, 1);

      await provider.loadFarmerProducts('farmer1');
      expect(provider.products.length, 1);
      expect(provider.products.first.name, 'Wheat');
    });
  });
}
