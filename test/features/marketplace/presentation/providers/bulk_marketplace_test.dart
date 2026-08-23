import 'package:flutter_test/flutter_test.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_bulk_requirement_repository.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_bulk_offer_repository.dart';
import 'package:krishimarket/features/marketplace/domain/entities/bulk_requirement_entity.dart';
import 'package:krishimarket/features/marketplace/domain/entities/bulk_offer_entity.dart';
import 'package:krishimarket/features/marketplace/presentation/providers/bulk_requirement_provider.dart';
import 'package:krishimarket/features/marketplace/presentation/providers/bulk_offer_provider.dart';

void main() {
  group('BulkRequirementProvider', () {
    late BulkRequirementProvider reqProvider;
    late MockBulkRequirementRepository reqRepo;

    setUp(() {
      reqRepo = MockBulkRequirementRepository();
      reqProvider = BulkRequirementProvider(reqRepo);
    });

    test('Load buyer requirements', () async {
      await reqProvider.loadBuyerRequirements('bulk1');
      expect(reqProvider.requirements.isNotEmpty, true);
    });

    test('Create requirement', () async {
      final req = BulkRequirementEntity(
        requirementId: 'BR-test',
        buyerId: 'bulk2',
        buyerName: 'Test Buyer',
        productName: 'Mango',
        category: 'Fruits',
        requiredQuantity: 500,
        unit: 'kg',
        targetPrice: 100,
        deliveryLocation: 'Pune',
        requiredByDate: DateTime.now().add(const Duration(days: 10)),
        description: 'Test',
        status: BulkRequirementStatus.open,
        createdAt: DateTime.now(),
      );

      await reqProvider.createRequirement(req);
      expect(reqProvider.requirements.length, 1);
      expect(reqProvider.requirements.first.productName, 'Mango');
    });

    test('Cancel requirement', () async {
      await reqProvider.loadBuyerRequirements('bulk1');
      final firstReq = reqProvider.requirements.firstWhere(
        (r) => r.status == BulkRequirementStatus.open,
      );
      await reqProvider.cancelRequirement(firstReq.requirementId);

      final updatedReq = reqProvider.requirements.firstWhere(
        (r) => r.requirementId == firstReq.requirementId,
      );
      expect(updatedReq.status, BulkRequirementStatus.cancelled);
    });
  });

  group('BulkOfferProvider and Partial Fulfillment', () {
    late BulkOfferProvider offerProvider;
    late MockBulkOfferRepository offerRepo;
    late MockBulkRequirementRepository reqRepo;

    setUp(() {
      reqRepo = MockBulkRequirementRepository();
      offerRepo = MockBulkOfferRepository();
      offerProvider = BulkOfferProvider(offerRepo, reqRepo);
    });

    test('Submit offer', () async {
      final offer = BulkOfferEntity(
        offerId: 'O-test',
        requirementId: 'BR-1',
        farmerId: 'Manoj',
        farmerName: 'Manoj',
        availableQuantity: 200,
        offeredPrice: 20,
        unit: 'kg',
        qualityGrade: 'A',
        estimatedReadyDate: DateTime.now(),
        note: 'Test',
        status: BulkOfferStatus.submitted,
        createdAt: DateTime.now(),
      );

      await offerProvider.submitOffer(offer);
      expect(offerProvider.offers.length, 1);
    });

    test('Accept offer exact quantity -> Requirement FULFILLED', () async {
      // BR-1 needs 1000kg.
      // O-1 has 500kg available.
      // O-3 has 700kg available.

      await offerProvider.loadOffersForRequirement('BR-1');

      // Accept 500 from O-1
      await offerProvider.acceptOffer('O-1', 500);

      var req = await reqRepo.getRequirementById('BR-1');
      expect(req.status, BulkRequirementStatus.partiallyFulfilled);
      expect(req.fulfilledQuantity, 500);

      // Accept 500 from O-3
      await offerProvider.acceptOffer('O-3', 500);

      req = await reqRepo.getRequirementById('BR-1');
      expect(req.status, BulkRequirementStatus.fulfilled);
      expect(req.fulfilledQuantity, 1000);
    });

    test('Accept offer exceeding requirement throws exception', () async {
      // BR-1 needs 1000kg.

      await offerProvider.loadOffersForRequirement('BR-1');

      // Accept 500 from O-1
      await offerProvider.acceptOffer('O-1', 500);

      // Attempt to accept 600 from O-3 (exceeds remaining 500)
      expect(() => offerProvider.acceptOffer('O-3', 600), throwsException);
    });

    test('Reject offer', () async {
      await offerProvider.loadOffersForRequirement('BR-1');
      await offerProvider.rejectOffer('O-1');

      final updatedOffer = offerProvider.offers.firstWhere(
        (o) => o.offerId == 'O-1',
      );
      expect(updatedOffer.status, BulkOfferStatus.rejected);
    });

    test('Withdraw offer', () async {
      await offerProvider.loadFarmerOffers('Manoj');
      final offer = offerProvider.offers.firstWhere((o) => o.offerId == 'O-1');
      await offerProvider.withdrawOffer(offer.offerId);

      final updatedOffer = offerProvider.offers.firstWhere(
        (o) => o.offerId == 'O-1',
      );
      expect(updatedOffer.status, BulkOfferStatus.withdrawn);
    });

    test('Sort offers by price', () async {
      await offerProvider.loadOffersForRequirement('BR-1');
      // Offers are 21, 20, 23
      offerProvider.sortOffersByPrice(true); // Low to High
      expect(offerProvider.offers[0].offeredPrice, 20);
      expect(offerProvider.offers[1].offeredPrice, 21);
      expect(offerProvider.offers[2].offeredPrice, 23);

      offerProvider.sortOffersByPrice(false); // High to Low
      expect(offerProvider.offers[0].offeredPrice, 23);
      expect(offerProvider.offers[1].offeredPrice, 21);
      expect(offerProvider.offers[2].offeredPrice, 20);
    });
  });
}
