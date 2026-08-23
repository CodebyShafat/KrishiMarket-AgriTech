class ProductEntity {
  final String productId;
  final String farmerId;
  final String name;
  final String category;
  final String description;
  final String qualityGrade;
  final double price;
  final String unit;
  final double availableQuantity;
  final String location;
  final DateTime harvestDate;
  final bool isAvailable;
  final DateTime createdAt;

  ProductEntity({
    required this.productId,
    required this.farmerId,
    required this.name,
    required this.category,
    required this.description,
    required this.qualityGrade,
    required this.price,
    required this.unit,
    required this.availableQuantity,
    required this.location,
    required this.harvestDate,
    required this.isAvailable,
    required this.createdAt,
  });

  ProductEntity copyWith({
    String? productId,
    String? farmerId,
    String? name,
    String? category,
    String? description,
    String? qualityGrade,
    double? price,
    String? unit,
    double? availableQuantity,
    String? location,
    DateTime? harvestDate,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return ProductEntity(
      productId: productId ?? this.productId,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      location: location ?? this.location,
      harvestDate: harvestDate ?? this.harvestDate,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
