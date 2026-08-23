class CartItemEntity {
  final String productId;
  final String farmerId;
  final String productName;
  final String farmerName;
  final double price;
  final String unit;
  final double quantity;
  final String quality;
  final double availableQuantity;

  CartItemEntity({
    required this.productId,
    required this.farmerId,
    required this.productName,
    required this.farmerName,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.quality,
    required this.availableQuantity,
  });

  double get subtotal => price * quantity;

  CartItemEntity copyWith({
    String? productId,
    String? farmerId,
    String? productName,
    String? farmerName,
    double? price,
    String? unit,
    double? quantity,
    String? quality,
    double? availableQuantity,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      farmerId: farmerId ?? this.farmerId,
      productName: productName ?? this.productName,
      farmerName: farmerName ?? this.farmerName,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      quality: quality ?? this.quality,
      availableQuantity: availableQuantity ?? this.availableQuantity,
    );
  }
}
