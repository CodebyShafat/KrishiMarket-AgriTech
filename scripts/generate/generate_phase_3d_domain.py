import os

files = {
    r"lib\features\marketplace\domain\entities\bulk_requirement_entity.dart": """
enum BulkRequirementStatus { draft, open, partiallyFulfilled, fulfilled, cancelled, expired }

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
""",
    r"lib\features\marketplace\domain\entities\bulk_offer_entity.dart": """
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
""",
    r"lib\features\marketplace\domain\repositories\bulk_requirement_repository.dart": """
import '../entities/bulk_requirement_entity.dart';

abstract class BulkRequirementRepository {
  Future<void> createRequirement(BulkRequirementEntity requirement);
  Future<List<BulkRequirementEntity>> getBuyerRequirements(String buyerId);
  Future<List<BulkRequirementEntity>> getOpenRequirements();
  Future<BulkRequirementEntity> getRequirementById(String requirementId);
  Future<void> updateRequirement(BulkRequirementEntity requirement);
  Future<void> cancelRequirement(String requirementId);
  Future<void> updateRequirementStatus(String requirementId, BulkRequirementStatus status);
}
""",
    r"lib\features\marketplace\domain\repositories\bulk_offer_repository.dart": """
import '../entities/bulk_offer_entity.dart';

abstract class BulkOfferRepository {
  Future<void> createOffer(BulkOfferEntity offer);
  Future<List<BulkOfferEntity>> getOffersForRequirement(String requirementId);
  Future<List<BulkOfferEntity>> getFarmerOffers(String farmerId);
  Future<BulkOfferEntity> getOfferById(String offerId);
  Future<void> updateOfferStatus(String offerId, BulkOfferStatus status, {double? acceptedQuantity});
  Future<void> withdrawOffer(String offerId);
}
""",
    r"lib\features\marketplace\data\repositories\mock_bulk_requirement_repository.dart": """
import '../../domain/entities/bulk_requirement_entity.dart';
import '../../domain/repositories/bulk_requirement_repository.dart';

class MockBulkRequirementRepository implements BulkRequirementRepository {
  final List<BulkRequirementEntity> _requirements = [
    BulkRequirementEntity(
      requirementId: 'BR-1',
      buyerId: 'bulk1',
      buyerName: 'Big Bazaar',
      productName: 'Potato',
      category: 'Potato',
      requiredQuantity: 1000,
      fulfilledQuantity: 0,
      unit: 'kg',
      targetPrice: 22,
      deliveryLocation: 'Kanpur',
      requiredByDate: DateTime.now().add(const Duration(days: 7)),
      description: 'Looking for 1000kg of grade A potatoes.',
      status: BulkRequirementStatus.open,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      offerCount: 3,
    ),
    BulkRequirementEntity(
      requirementId: 'BR-2',
      buyerId: 'bulk1',
      buyerName: 'Big Bazaar',
      productName: 'Wheat',
      category: 'Wheat',
      requiredQuantity: 2000,
      fulfilledQuantity: 1000,
      unit: 'kg',
      targetPrice: 25,
      deliveryLocation: 'Lucknow',
      requiredByDate: DateTime.now().add(const Duration(days: 14)),
      description: 'Premium wheat requirement.',
      status: BulkRequirementStatus.partiallyFulfilled,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      offerCount: 2,
    ),
    BulkRequirementEntity(
      requirementId: 'BR-3',
      buyerId: 'bulk1',
      buyerName: 'Big Bazaar',
      productName: 'Onion',
      category: 'Onion',
      requiredQuantity: 500,
      fulfilledQuantity: 500,
      unit: 'kg',
      targetPrice: 30,
      deliveryLocation: 'Kanpur',
      requiredByDate: DateTime.now().add(const Duration(days: 5)),
      description: 'Red onions needed immediately.',
      status: BulkRequirementStatus.fulfilled,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      offerCount: 4,
    ),
    BulkRequirementEntity(
      requirementId: 'BR-4',
      buyerId: 'bulk2',
      buyerName: 'Fresh Mart',
      productName: 'Rice',
      category: 'Rice',
      requiredQuantity: 1500,
      fulfilledQuantity: 0,
      unit: 'kg',
      targetPrice: 50,
      deliveryLocation: 'Unnao',
      requiredByDate: DateTime.now().add(const Duration(days: 10)),
      description: 'Basmati rice requirement.',
      status: BulkRequirementStatus.open,
      createdAt: DateTime.now(),
      offerCount: 0,
    ),
    BulkRequirementEntity(
      requirementId: 'BR-5',
      buyerId: 'bulk1',
      buyerName: 'Big Bazaar',
      productName: 'Tomato',
      category: 'Tomato',
      requiredQuantity: 800,
      fulfilledQuantity: 0,
      unit: 'kg',
      targetPrice: 40,
      deliveryLocation: 'Kanpur',
      requiredByDate: DateTime.now().add(const Duration(days: 3)),
      description: 'Fresh ripe tomatoes.',
      status: BulkRequirementStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      offerCount: 1,
    ),
  ];

  @override
  Future<void> createRequirement(BulkRequirementEntity requirement) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _requirements.insert(0, requirement);
  }

  @override
  Future<List<BulkRequirementEntity>> getBuyerRequirements(String buyerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requirements.where((r) => r.buyerId == buyerId).toList();
  }

  @override
  Future<List<BulkRequirementEntity>> getOpenRequirements() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requirements.where((r) => r.status == BulkRequirementStatus.open || r.status == BulkRequirementStatus.partiallyFulfilled).toList();
  }

  @override
  Future<BulkRequirementEntity> getRequirementById(String requirementId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _requirements.firstWhere((r) => r.requirementId == requirementId, 
      orElse: () => throw Exception('Requirement not found'));
  }

  @override
  Future<void> updateRequirement(BulkRequirementEntity requirement) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requirements.indexWhere((r) => r.requirementId == requirement.requirementId);
    if (index >= 0) {
      if (_requirements[index].status != BulkRequirementStatus.draft && 
          _requirements[index].status != BulkRequirementStatus.open) {
        throw Exception('Cannot update requirement in current status');
      }
      _requirements[index] = requirement;
    } else {
      throw Exception('Requirement not found');
    }
  }

  @override
  Future<void> cancelRequirement(String requirementId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requirements.indexWhere((r) => r.requirementId == requirementId);
    if (index >= 0) {
      if (_requirements[index].status == BulkRequirementStatus.draft || 
          _requirements[index].status == BulkRequirementStatus.open) {
        _requirements[index] = _requirements[index].copyWith(status: BulkRequirementStatus.cancelled);
      } else {
        throw Exception('Cannot cancel requirement in current status');
      }
    } else {
      throw Exception('Requirement not found');
    }
  }

  @override
  Future<void> updateRequirementStatus(String requirementId, BulkRequirementStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requirements.indexWhere((r) => r.requirementId == requirementId);
    if (index >= 0) {
      _requirements[index] = _requirements[index].copyWith(status: status);
    } else {
      throw Exception('Requirement not found');
    }
  }
  
  // Helper for internal orchestration
  void incrementOfferCount(String requirementId) {
    final index = _requirements.indexWhere((r) => r.requirementId == requirementId);
    if (index >= 0) {
      _requirements[index] = _requirements[index].copyWith(offerCount: _requirements[index].offerCount + 1);
    }
  }
}
""",
    r"lib\features\marketplace\data\repositories\mock_bulk_offer_repository.dart": """
import '../../domain/entities/bulk_offer_entity.dart';
import '../../domain/repositories/bulk_offer_repository.dart';

class MockBulkOfferRepository implements BulkOfferRepository {
  final List<BulkOfferEntity> _offers = [
    BulkOfferEntity(
      offerId: 'O-1',
      requirementId: 'BR-1', // Potato 1000kg target 22
      farmerId: 'Manoj',
      farmerName: 'Manoj',
      availableQuantity: 500,
      offeredPrice: 21,
      unit: 'kg',
      qualityGrade: 'Premium',
      estimatedReadyDate: DateTime.now().add(const Duration(days: 2)),
      note: 'Freshly harvested large potatoes.',
      status: BulkOfferStatus.submitted,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    BulkOfferEntity(
      offerId: 'O-2',
      requirementId: 'BR-1',
      farmerId: 'Suresh',
      farmerName: 'Suresh',
      availableQuantity: 300,
      offeredPrice: 20,
      unit: 'kg',
      qualityGrade: 'Grade A',
      estimatedReadyDate: DateTime.now().add(const Duration(days: 4)),
      note: 'Organically grown.',
      status: BulkOfferStatus.submitted,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    BulkOfferEntity(
      offerId: 'O-3',
      requirementId: 'BR-1',
      farmerId: 'Vimal',
      farmerName: 'Vimal',
      availableQuantity: 700,
      offeredPrice: 23,
      unit: 'kg',
      qualityGrade: 'Premium',
      estimatedReadyDate: DateTime.now().add(const Duration(days: 1)),
      note: 'Available immediately.',
      status: BulkOfferStatus.submitted,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  @override
  Future<void> createOffer(BulkOfferEntity offer) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _offers.insert(0, offer);
  }

  @override
  Future<List<BulkOfferEntity>> getOffersForRequirement(String requirementId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _offers.where((o) => o.requirementId == requirementId).toList();
  }

  @override
  Future<List<BulkOfferEntity>> getFarmerOffers(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _offers.where((o) => o.farmerId == farmerId).toList();
  }

  @override
  Future<BulkOfferEntity> getOfferById(String offerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _offers.firstWhere((o) => o.offerId == offerId, 
      orElse: () => throw Exception('Offer not found'));
  }

  @override
  Future<void> updateOfferStatus(String offerId, BulkOfferStatus status, {double? acceptedQuantity}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _offers.indexWhere((o) => o.offerId == offerId);
    if (index >= 0) {
      _offers[index] = _offers[index].copyWith(
        status: status,
        acceptedQuantity: acceptedQuantity ?? _offers[index].acceptedQuantity
      );
    } else {
      throw Exception('Offer not found');
    }
  }

  @override
  Future<void> withdrawOffer(String offerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _offers.indexWhere((o) => o.offerId == offerId);
    if (index >= 0) {
      if (_offers[index].status == BulkOfferStatus.submitted) {
        _offers[index] = _offers[index].copyWith(status: BulkOfferStatus.withdrawn);
      } else {
        throw Exception('Can only withdraw submitted offers.');
      }
    } else {
      throw Exception('Offer not found');
    }
  }
}
"""
}

def main():
    for filepath, content in files.items():
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content.strip())
            print(f"Created {filepath}")

if __name__ == '__main__':
    main()
