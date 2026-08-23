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
  Future<List<BulkOfferEntity>> getOffersForRequirement(
    String requirementId,
  ) async {
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
    return _offers.firstWhere(
      (o) => o.offerId == offerId,
      orElse: () => throw Exception('Offer not found'),
    );
  }

  @override
  Future<void> updateOfferStatus(
    String offerId,
    BulkOfferStatus status, {
    double? acceptedQuantity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _offers.indexWhere((o) => o.offerId == offerId);
    if (index >= 0) {
      _offers[index] = _offers[index].copyWith(
        status: status,
        acceptedQuantity: acceptedQuantity ?? _offers[index].acceptedQuantity,
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
        _offers[index] = _offers[index].copyWith(
          status: BulkOfferStatus.withdrawn,
        );
      } else {
        throw Exception('Can only withdraw submitted offers.');
      }
    } else {
      throw Exception('Offer not found');
    }
  }
}
