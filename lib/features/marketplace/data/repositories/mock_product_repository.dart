import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class MockProductRepository implements ProductRepository {
  final List<ProductEntity> _products = [
    ProductEntity(
      productId: 'p1',
      farmerId: 'Manoj',
      name: 'Premium Wheat',
      category: 'Wheat',
      description: 'High quality premium wheat directly from Kanpur farms.',
      qualityGrade: 'Premium',
      price: 28.0,
      unit: 'kg',
      availableQuantity: 500,
      location: 'Kanpur',
      harvestDate: DateTime.now().subtract(const Duration(days: 10)),
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ProductEntity(
      productId: 'p2',
      farmerId: 'Suresh',
      name: 'Grade A Wheat',
      category: 'Wheat',
      description: 'Grade A wheat, organically grown.',
      qualityGrade: 'Grade A',
      price: 30.0,
      unit: 'kg',
      availableQuantity: 300,
      location: 'Kanpur',
      harvestDate: DateTime.now().subtract(const Duration(days: 15)),
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    ProductEntity(
      productId: 'p3',
      farmerId: 'Vimal',
      name: 'Standard Wheat',
      category: 'Wheat',
      description: 'Standard quality wheat for daily use.',
      qualityGrade: 'Standard',
      price: 27.0,
      unit: 'kg',
      availableQuantity: 700,
      location: 'Kanpur',
      harvestDate: DateTime.now().subtract(const Duration(days: 20)),
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ProductEntity(
      productId: 'p4',
      farmerId: 'Ramesh',
      name: 'Basmati Rice',
      category: 'Rice',
      description: 'Aromatic basmati rice.',
      qualityGrade: 'Premium',
      price: 80.0,
      unit: 'kg',
      availableQuantity: 200,
      location: 'Lucknow',
      harvestDate: DateTime.now().subtract(const Duration(days: 5)),
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ProductEntity(
      productId: 'p5',
      farmerId: 'Dinesh',
      name: 'Sona Masuri Rice',
      category: 'Rice',
      description: 'Light and aromatic Sona Masuri rice.',
      qualityGrade: 'Grade A',
      price: 55.0,
      unit: 'kg',
      availableQuantity: 400,
      location: 'Unnao',
      harvestDate: DateTime.now().subtract(const Duration(days: 8)),
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ProductEntity(
      productId: 'p6',
      farmerId: 'Manoj',
      name: 'Fresh Potatoes',
      category: 'Potato',
      description: 'Freshly harvested large potatoes.',
      qualityGrade: 'Grade A',
      price: 15.0,
      unit: 'kg',
      availableQuantity: 1000,
      location: 'Kanpur',
      harvestDate: DateTime.now().subtract(const Duration(days: 2)),
      isAvailable: true,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      productId: 'p7',
      farmerId: 'Amit',
      name: 'Organic Potatoes',
      category: 'Potato',
      description: '100% organic potatoes without pesticides.',
      qualityGrade: 'Premium',
      price: 20.0,
      unit: 'kg',
      availableQuantity: 500,
      location: 'Fatehpur',
      harvestDate: DateTime.now().subtract(const Duration(days: 3)),
      isAvailable: true,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      productId: 'p8',
      farmerId: 'Suresh',
      name: 'Red Onions',
      category: 'Onion',
      description: 'Crisp and pungent red onions.',
      qualityGrade: 'Standard',
      price: 25.0,
      unit: 'kg',
      availableQuantity: 600,
      location: 'Kanpur',
      harvestDate: DateTime.now().subtract(const Duration(days: 12)),
      isAvailable: true,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      productId: 'p9',
      farmerId: 'Amit',
      name: 'White Onions',
      category: 'Onion',
      description: 'Mild white onions suitable for salads.',
      qualityGrade: 'Grade A',
      price: 30.0,
      unit: 'kg',
      availableQuantity: 300,
      location: 'Fatehpur',
      harvestDate: DateTime.now().subtract(const Duration(days: 10)),
      isAvailable: true,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      productId: 'p10',
      farmerId: 'Vimal',
      name: 'Ripe Tomatoes',
      category: 'Tomato',
      description: 'Juicy red tomatoes ready for consumption.',
      qualityGrade: 'Grade A',
      price: 40.0,
      unit: 'kg',
      availableQuantity: 150,
      location: 'Kanpur',
      harvestDate: DateTime.now().subtract(const Duration(days: 1)),
      isAvailable: true,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      productId: 'p11',
      farmerId: 'Ramesh',
      name: 'Cherry Tomatoes',
      category: 'Tomato',
      description: 'Sweet cherry tomatoes.',
      qualityGrade: 'Premium',
      price: 60.0,
      unit: 'kg',
      availableQuantity: 50,
      location: 'Lucknow',
      harvestDate: DateTime.now(),
      isAvailable: true,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<ProductEntity>> getAllAvailableProducts({
    String? search,
    String? category,
    int skip = 0,
    int limit = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var products = _products.where((p) => p.isAvailable).toList();
    
    if (search != null && search.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(search.toLowerCase()) ||
              p.category.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    
    if (category != null && category != 'All') {
      products = products.where((p) => p.category == category).toList();
    }
    
    // Simple pagination mock
    if (skip >= products.length) return [];
    final endIndex = (skip + limit) < products.length ? (skip + limit) : products.length;
    return products.sublist(skip, endIndex);
  }

  @override
  Future<List<ProductEntity>> getFarmerProducts(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _products.where((p) => p.farmerId == farmerId).toList();
  }

  @override
  Future<ProductEntity> getProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _products.firstWhere(
      (p) => p.productId == productId,
      orElse: () => throw Exception('Product not found'),
    );
  }

  @override
  Future<void> createProduct(ProductEntity product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.add(product);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _products.indexWhere((p) => p.productId == product.productId);
    if (index >= 0) {
      _products[index] = product;
    } else {
      throw Exception('Product not found');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.removeWhere((p) => p.productId == productId);
  }

  @override
  Future<void> toggleAvailability(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _products.indexWhere((p) => p.productId == productId);
    if (index >= 0) {
      final p = _products[index];
      _products[index] = p.copyWith(isAvailable: !p.isAvailable);
    } else {
      throw Exception('Product not found');
    }
  }
}
