import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:krishimarket/features/marketplace/domain/entities/bulk_requirement_entity.dart';
import 'package:krishimarket/features/marketplace/domain/entities/bulk_offer_entity.dart';

class StatusLocalizer {
  static String getLocalizedRequirementStatus(BulkRequirementStatus status, AppLocalizations l10n) {
    switch (status) {
      case BulkRequirementStatus.open: return l10n.open;
      case BulkRequirementStatus.partiallyFulfilled: return l10n.partiallyFulfilled;
      case BulkRequirementStatus.fulfilled: return l10n.fulfilled;
      case BulkRequirementStatus.cancelled: return 'Cancelled'; // Fallback if no localized string
      default: return status.name;
    }
  }

  static String getLocalizedOfferStatus(BulkOfferStatus status, AppLocalizations l10n) {
    switch (status) {
      case BulkOfferStatus.submitted: return l10n.submitted;
      case BulkOfferStatus.accepted: return l10n.accepted;
      case BulkOfferStatus.rejected: return l10n.rejected;
      case BulkOfferStatus.withdrawn: return l10n.withdrawn;
      default: return status.name;
    }
  }
}
