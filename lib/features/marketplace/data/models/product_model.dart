import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.productId,
    required super.farmerId,
    required super.name,
    required super.category,
    required super.description,
    required super.qualityGrade,
    required super.price,
    required super.unit,
    required super.availableQuantity,
    required super.location,
    required super.harvestDate,
    required super.isAvailable,
    required super.createdAt,
  });

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      productId: entity.productId,
      farmerId: entity.farmerId,
      name: entity.name,
      category: entity.category,
      description: entity.description,
      qualityGrade: entity.qualityGrade,
      price: entity.price,
      unit: entity.unit,
      availableQuantity: entity.availableQuantity,
      location: entity.location,
      harvestDate: entity.harvestDate,
      isAvailable: entity.isAvailable,
      createdAt: entity.createdAt,
    );
  }
}
