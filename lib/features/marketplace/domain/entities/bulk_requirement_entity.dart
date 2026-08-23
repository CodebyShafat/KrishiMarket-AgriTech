enum BulkRequirementStatus {
  draft,
  open,
  partiallyFulfilled,
  fulfilled,
  cancelled,
  expired,
}

class BulkRequirementEntity {
  final String requirementId;
  final String buyerId;
  final String buyerName;
  final String productName;
  final String category;
  final double requiredQuantity;
  final double fulfilledQuantity;
  final String unit;
  final double targetPrice;
  final String deliveryLocation;
  final DateTime requiredByDate;
  final String description;
  final BulkRequirementStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int offerCount;

  BulkRequirementEntity({
    required this.requirementId,
    required this.buyerId,
    required this.buyerName,
    required this.productName,
    required this.category,
    required this.requiredQuantity,
    this.fulfilledQuantity = 0.0,
    required this.unit,
    required this.targetPrice,
    required this.deliveryLocation,
    required this.requiredByDate,
    required this.description,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.offerCount = 0,
  });

  BulkRequirementEntity copyWith({
    String? requirementId,
    String? buyerId,
    String? buyerName,
    String? productName,
    String? category,
    double? requiredQuantity,
    double? fulfilledQuantity,
    String? unit,
    double? targetPrice,
    String? deliveryLocation,
    DateTime? requiredByDate,
    String? description,
    BulkRequirementStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? offerCount,
  }) {
    return BulkRequirementEntity(
      requirementId: requirementId ?? this.requirementId,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      requiredQuantity: requiredQuantity ?? this.requiredQuantity,
      fulfilledQuantity: fulfilledQuantity ?? this.fulfilledQuantity,
      unit: unit ?? this.unit,
      targetPrice: targetPrice ?? this.targetPrice,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      requiredByDate: requiredByDate ?? this.requiredByDate,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      offerCount: offerCount ?? this.offerCount,
    );
  }
}
