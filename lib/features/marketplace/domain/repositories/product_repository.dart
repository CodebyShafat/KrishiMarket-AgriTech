import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getAllAvailableProducts({
    String? search,
    String? category,
    int skip = 0,
    int limit = 100,
  });
  Future<List<ProductEntity>> getFarmerProducts(String farmerId);
  Future<ProductEntity> getProductById(String productId);
  Future<void> createProduct(ProductEntity product);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String productId);
  Future<void> toggleAvailability(String productId);
}
