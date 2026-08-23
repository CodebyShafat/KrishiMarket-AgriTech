import 'package:flutter/foundation.dart';

import '../../domain/entities/bulk_offer_entity.dart';
import '../../domain/entities/bulk_requirement_entity.dart';
import '../../domain/repositories/bulk_offer_repository.dart';
import '../../domain/repositories/bulk_requirement_repository.dart';

class BulkOfferProvider with ChangeNotifier {
  final BulkOfferRepository _offerRepository;
  final BulkRequirementRepository _requirementRepository;

  BulkOfferProvider(this._offerRepository, this._requirementRepository);

  List<BulkOfferEntity> _offers = [];
  bool _isLoading = false;
  String? _error;

  List<BulkOfferEntity> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOffersForRequirement(String requirementId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _offers = await _offerRepository.getOffersForRequirement(requirementId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFarmerOffers(String farmerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _offers = await _offerRepository.getFarmerOffers(farmerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitOffer(BulkOfferEntity offer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _offerRepository.createOffer(offer);
      _offers.insert(0, offer);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> withdrawOffer(String offerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _offerRepository.withdrawOffer(offerId);
      final index = _offers.indexWhere((o) => o.offerId == offerId);
      if (index >= 0) {
        _offers[index] = _offers[index].copyWith(
          status: BulkOfferStatus.withdrawn,
        );
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptOffer(String offerId, double acceptedQuantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final offer = await _offerRepository.getOfferById(offerId);
      if (offer.status != BulkOfferStatus.submitted &&
          offer.status != BulkOfferStatus.shortlisted) {
        throw Exception('Offer is not in a valid state to be accepted.');
      }
      if (acceptedQuantity > offer.availableQuantity) {
        throw Exception('Accepted quantity cannot exceed offered quantity.');
      }

      final req = await _requirementRepository.getRequirementById(
        offer.requirementId,
      );
      if (req.status != BulkRequirementStatus.open &&
          req.status != BulkRequirementStatus.partiallyFulfilled) {
        throw Exception('Requirement is no longer open.');
      }

      final remaining = req.requiredQuantity - req.fulfilledQuantity;
      if (acceptedQuantity > remaining) {
        throw Exception('Accepted quantity exceeds remaining requirement.');
      }

      // Proceed to accept
      await _offerRepository.updateOfferStatus(
        offerId,
        BulkOfferStatus.accepted,
        acceptedQuantity: acceptedQuantity,
      );

      // Update fulfillment
      final newFulfilled = req.fulfilledQuantity + acceptedQuantity;
      final newStatus = newFulfilled >= req.requiredQuantity
          ? BulkRequirementStatus.fulfilled
          : BulkRequirementStatus.partiallyFulfilled;

      final updatedReq = req.copyWith(
        fulfilledQuantity: newFulfilled,
        status: newStatus,
      );

      await _requirementRepository.updateRequirement(updatedReq);

      // Refresh local list
      final index = _offers.indexWhere((o) => o.offerId == offerId);
      if (index >= 0) {
        _offers[index] = _offers[index].copyWith(
          status: BulkOfferStatus.accepted,
          acceptedQuantity: acceptedQuantity,
        );
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectOffer(String offerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final offer = await _offerRepository.getOfferById(offerId);
      if (offer.status == BulkOfferStatus.accepted) {
        throw Exception('Cannot reject an already accepted offer.');
      }
      await _offerRepository.updateOfferStatus(
        offerId,
        BulkOfferStatus.rejected,
      );

      final index = _offers.indexWhere((o) => o.offerId == offerId);
      if (index >= 0) {
        _offers[index] = _offers[index].copyWith(
          status: BulkOfferStatus.rejected,
        );
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void sortOffersByPrice(bool ascending) {
    if (ascending) {
      _offers.sort((a, b) => a.offeredPrice.compareTo(b.offeredPrice));
    } else {
      _offers.sort((a, b) => b.offeredPrice.compareTo(a.offeredPrice));
    }
    notifyListeners();
  }
}
