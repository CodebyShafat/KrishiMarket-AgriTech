import 'package:krishimarket/l10n/app_localizations.dart';

class CategoryLocalizer {
  static String getLocalizedCategory(String canonicalCategory, AppLocalizations l10n) {
    switch (canonicalCategory) {
      case 'Wheat': return l10n.wheat;
      case 'Rice': return l10n.rice;
      case 'Potato': return l10n.potato;
      case 'Onion': return l10n.onion;
      case 'Tomato': return l10n.tomato;
      case 'Vegetables': return l10n.vegetables;
      case 'Fruits': return l10n.fruits;
      case 'Pulses': return l10n.pulses;
      case 'Spices': return l10n.spices;
      case 'Other': return l10n.other;
      default: return canonicalCategory;
    }
  }
}
