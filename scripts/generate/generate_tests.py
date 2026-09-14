import os

files = {
    r"test\features\marketplace\domain\entities\product_entity_test.dart": """
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
""",
    r"test\features\marketplace\data\repositories\mock_product_repository_test.dart": """
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
""",
    r"test\features\marketplace\presentation\providers\product_provider_test.dart": """
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
"""
}

def main():
    for filepath, content in files.items():
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content.strip())
            print(f"Created {filepath}")

if __name__ == '__main__':
    main()
