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
  Future<List<BulkRequirementEntity>> getBuyerRequirements(
    String buyerId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requirements.where((r) => r.buyerId == buyerId).toList();
  }

  @override
  Future<List<BulkRequirementEntity>> getOpenRequirements() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requirements
        .where(
          (r) =>
              r.status == BulkRequirementStatus.open ||
              r.status == BulkRequirementStatus.partiallyFulfilled,
        )
        .toList();
  }

  @override
  Future<BulkRequirementEntity> getRequirementById(String requirementId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _requirements.firstWhere(
      (r) => r.requirementId == requirementId,
      orElse: () => throw Exception('Requirement not found'),
    );
  }

  @override
  Future<void> updateRequirement(BulkRequirementEntity requirement) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requirements.indexWhere(
      (r) => r.requirementId == requirement.requirementId,
    );
    if (index >= 0) {
      if (_requirements[index].status != BulkRequirementStatus.draft &&
          _requirements[index].status != BulkRequirementStatus.open &&
          _requirements[index].status !=
              BulkRequirementStatus.partiallyFulfilled) {
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
    final index = _requirements.indexWhere(
      (r) => r.requirementId == requirementId,
    );
    if (index >= 0) {
      if (_requirements[index].status == BulkRequirementStatus.draft ||
          _requirements[index].status == BulkRequirementStatus.open) {
        _requirements[index] = _requirements[index].copyWith(
          status: BulkRequirementStatus.cancelled,
        );
      } else {
        throw Exception('Cannot cancel requirement in current status');
      }
    } else {
      throw Exception('Requirement not found');
    }
  }

  @override
  Future<void> updateRequirementStatus(
    String requirementId,
    BulkRequirementStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requirements.indexWhere(
      (r) => r.requirementId == requirementId,
    );
    if (index >= 0) {
      _requirements[index] = _requirements[index].copyWith(status: status);
    } else {
      throw Exception('Requirement not found');
    }
  }

  // Helper for internal orchestration
  void incrementOfferCount(String requirementId) {
    final index = _requirements.indexWhere(
      (r) => r.requirementId == requirementId,
    );
    if (index >= 0) {
      _requirements[index] = _requirements[index].copyWith(
        offerCount: _requirements[index].offerCount + 1,
      );
    }
  }
}
