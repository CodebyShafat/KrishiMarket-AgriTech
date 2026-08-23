import '../entities/bulk_offer_entity.dart';

abstract class BulkOfferRepository {
  Future<void> createOffer(BulkOfferEntity offer);
  Future<List<BulkOfferEntity>> getOffersForRequirement(String requirementId);
  Future<List<BulkOfferEntity>> getFarmerOffers(String farmerId);
  Future<BulkOfferEntity> getOfferById(String offerId);
  Future<void> updateOfferStatus(
    String offerId,
    BulkOfferStatus status, {
    double? acceptedQuantity,
  });
  Future<void> withdrawOffer(String offerId);
}
