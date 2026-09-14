import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../../core/network/api_client.dart';

class ApiProductRepository implements ProductRepository {
  final ApiClient apiClient;

  ApiProductRepository({required this.apiClient});

  @override
  Future<void> createProduct(ProductEntity product) async {
    await apiClient.post(
      '/products',
      body: {
        'title': product.name,
        'crop': product.category,
        'price': product.price,
        'quantity': product.availableQuantity,
        'unit': product.unit,
        'description': product.description,
        'image_url': product.location,
      },
      requiresAuth: true,
    );
  }

  @override
  Future<List<ProductEntity>> getAllAvailableProducts({
    String? search,
    String? category,
    int skip = 0,
    int limit = 100,
  }) async {
    String url = '/products?skip=$skip&limit=$limit';
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }
    if (category != null && category != 'All') {
      url += '&crop=$category';
    }
    final response = await apiClient.get(url, requiresAuth: true);
    if (response is List) {
      return response.map((data) => _mapToEntity(data)).toList();
    }
    return [];
  }

  @override
  Future<List<ProductEntity>> getFarmerProducts(String farmerId) async {
    final response = await apiClient.get(
      '/products?farmer_id=$farmerId',
      requiresAuth: true,
    );
    if (response is List) {
      return response.map((data) => _mapToEntity(data)).toList();
    }
    return [];
  }

  @override
  Future<ProductEntity> getProductById(String productId) async {
    final response = await apiClient.get(
      '/products/$productId',
      requiresAuth: true,
    );
    return _mapToEntity(response);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    await apiClient.put(
      '/products/${product.productId}',
      body: {
        'title': product.name,
        'crop': product.category,
        'price': product.price,
        'quantity': product.availableQuantity,
        'unit': product.unit,
        'description': product.description,
        'image_url': product.location,
      },
      requiresAuth: true,
    );
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await apiClient.delete('/products/$productId', requiresAuth: true);
  }

  @override
  Future<void> toggleAvailability(String productId) async {
    final product = await getProductById(productId);
    final newQty = product.isAvailable ? 0.0 : 100.0;
    await apiClient.put(
      '/products/$productId',
      body: {'quantity': newQty},
      requiresAuth: true,
    );
  }

  ProductEntity _mapToEntity(dynamic d) {
    final data = d as Map<String, dynamic>;
    return ProductEntity(
      productId: data['id'],
      farmerId: data['farmer_id'],
      name: data['title'],
      category: data['crop'],
      price: (data['price'] as num).toDouble(),
      availableQuantity: (data['quantity'] as num).toDouble(),
      unit: data['unit'],
      description: data['description'] ?? '',
      location: data['image_url'] ?? '',
      qualityGrade: 'Standard', // Default
      harvestDate: DateTime.now(), // Default
      isAvailable: (data['quantity'] as num) > 0,
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
