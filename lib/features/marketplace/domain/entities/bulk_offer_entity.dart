enum BulkOfferStatus { submitted, shortlisted, accepted, rejected, withdrawn }

class BulkOfferEntity {
  final String offerId;
  final String requirementId;
  final String farmerId;
  final String farmerName;
  final double availableQuantity;
  final double acceptedQuantity;
  final double offeredPrice;
  final String unit;
  final String qualityGrade;
  final DateTime estimatedReadyDate;
  final String note;
  final BulkOfferStatus status;
  final DateTime createdAt;

  BulkOfferEntity({
    required this.offerId,
    required this.requirementId,
    required this.farmerId,
    required this.farmerName,
    required this.availableQuantity,
    this.acceptedQuantity = 0.0,
    required this.offeredPrice,
    required this.unit,
    required this.qualityGrade,
    required this.estimatedReadyDate,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  BulkOfferEntity copyWith({
    String? offerId,
    String? requirementId,
    String? farmerId,
    String? farmerName,
    double? availableQuantity,
    double? acceptedQuantity,
    double? offeredPrice,
    String? unit,
    String? qualityGrade,
    DateTime? estimatedReadyDate,
    String? note,
    BulkOfferStatus? status,
    DateTime? createdAt,
  }) {
    return BulkOfferEntity(
      offerId: offerId ?? this.offerId,
      requirementId: requirementId ?? this.requirementId,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      acceptedQuantity: acceptedQuantity ?? this.acceptedQuantity,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      unit: unit ?? this.unit,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      estimatedReadyDate: estimatedReadyDate ?? this.estimatedReadyDate,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
