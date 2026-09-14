import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('as'),
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('or'),
    Locale('pa'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'KrishiMarket'**
  String get appTitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get whoAreYou;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @bulkBuyer.
  ///
  /// In en, this message translates to:
  /// **'Bulk Buyer'**
  String get bulkBuyer;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @notImplemented.
  ///
  /// In en, this message translates to:
  /// **'Navigation not implemented yet.'**
  String get notImplemented;

  /// No description provided for @farmerHome.
  ///
  /// In en, this message translates to:
  /// **'Farmer Home'**
  String get farmerHome;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @marketPrices.
  ///
  /// In en, this message translates to:
  /// **'Market Prices'**
  String get marketPrices;

  /// No description provided for @customerHome.
  ///
  /// In en, this message translates to:
  /// **'Customer Home'**
  String get customerHome;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search Products'**
  String get searchProducts;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @nearbyFresh.
  ///
  /// In en, this message translates to:
  /// **'Nearby & Fresh'**
  String get nearbyFresh;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @bulkBuyerHome.
  ///
  /// In en, this message translates to:
  /// **'Bulk Buyer Home'**
  String get bulkBuyerHome;

  /// No description provided for @bulkSearch.
  ///
  /// In en, this message translates to:
  /// **'Bulk Search'**
  String get bulkSearch;

  /// No description provided for @bulkOrders.
  ///
  /// In en, this message translates to:
  /// **'Bulk Orders'**
  String get bulkOrders;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @negotiations.
  ///
  /// In en, this message translates to:
  /// **'Negotiations'**
  String get negotiations;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @phoneAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get phoneAuthTitle;

  /// No description provided for @phoneAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get phoneAuthSubtitle;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get phoneNumberHint;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @termsAccept.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you accept our Terms and Privacy Policy'**
  String get termsAccept;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your phone'**
  String get otpSubtitle;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @verifyBtn.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyBtn;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get invalidOtp;

  /// No description provided for @otpExpired.
  ///
  /// In en, this message translates to:
  /// **'OTP Expired'**
  String get otpExpired;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get tooManyAttempts;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get profileTitle;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameHint;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Location (Village/City)'**
  String get locationHint;

  /// No description provided for @businessNameHint.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessNameHint;

  /// No description provided for @businessTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get businessTypeHint;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// No description provided for @groceryStore.
  ///
  /// In en, this message translates to:
  /// **'Grocery Store'**
  String get groceryStore;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @myProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get myProducts;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @harvestDate.
  ///
  /// In en, this message translates to:
  /// **'Harvest Date'**
  String get harvestDate;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProduct;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No Products'**
  String get noProducts;

  /// No description provided for @productAdded.
  ///
  /// In en, this message translates to:
  /// **'Product Added'**
  String get productAdded;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product Updated'**
  String get productUpdated;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product Deleted'**
  String get productDeleted;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required Field'**
  String get requiredField;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid Price'**
  String get invalidPrice;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get confirmDeleteMsg;

  /// No description provided for @uploadImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Image placeholder (Future)'**
  String get uploadImageLabel;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationNumeric.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive number'**
  String get validationNumeric;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @nearbyProducts.
  ///
  /// In en, this message translates to:
  /// **'Nearby Products'**
  String get nearbyProducts;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @wheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get wheat;

  /// No description provided for @rice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get rice;

  /// No description provided for @potato.
  ///
  /// In en, this message translates to:
  /// **'Potato'**
  String get potato;

  /// No description provided for @onion.
  ///
  /// In en, this message translates to:
  /// **'Onion'**
  String get onion;

  /// No description provided for @tomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get tomato;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// No description provided for @pulses.
  ///
  /// In en, this message translates to:
  /// **'Pulses'**
  String get pulses;

  /// No description provided for @spices.
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get spices;

  /// No description provided for @farmerId.
  ///
  /// In en, this message translates to:
  /// **'Farmer ID'**
  String get farmerId;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @nearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get nearest;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @compare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compare;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now (Coming Soon)'**
  String get buyNow;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully'**
  String get orderPlaced;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @placed.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get placed;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @readyForPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get readyForPickup;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @confirmCancellation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get confirmCancellation;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @viewMyOrders.
  ///
  /// In en, this message translates to:
  /// **'View My Orders'**
  String get viewMyOrders;

  /// No description provided for @deliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get deliveryLocation;

  /// No description provided for @paymentIntegrationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Payment integration coming soon'**
  String get paymentIntegrationComingSoon;

  /// No description provided for @emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCart;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrders;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @farmerOrders.
  ///
  /// In en, this message translates to:
  /// **'Farmer Orders'**
  String get farmerOrders;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @bulkRequirements.
  ///
  /// In en, this message translates to:
  /// **'Bulk Requirements'**
  String get bulkRequirements;

  /// No description provided for @myRequirements.
  ///
  /// In en, this message translates to:
  /// **'My Requirements'**
  String get myRequirements;

  /// No description provided for @createRequirement.
  ///
  /// In en, this message translates to:
  /// **'Create Requirement'**
  String get createRequirement;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @requiredQuantity.
  ///
  /// In en, this message translates to:
  /// **'Required Quantity'**
  String get requiredQuantity;

  /// No description provided for @targetPrice.
  ///
  /// In en, this message translates to:
  /// **'Target Price'**
  String get targetPrice;

  /// No description provided for @requiredBy.
  ///
  /// In en, this message translates to:
  /// **'Required By'**
  String get requiredBy;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @viewOffers.
  ///
  /// In en, this message translates to:
  /// **'View Offers'**
  String get viewOffers;

  /// No description provided for @submitOffer.
  ///
  /// In en, this message translates to:
  /// **'Submit Offer'**
  String get submitOffer;

  /// No description provided for @availableQuantity.
  ///
  /// In en, this message translates to:
  /// **'Available Quantity'**
  String get availableQuantity;

  /// No description provided for @offeredPrice.
  ///
  /// In en, this message translates to:
  /// **'Offered Price'**
  String get offeredPrice;

  /// No description provided for @readyDate.
  ///
  /// In en, this message translates to:
  /// **'Ready Date'**
  String get readyDate;

  /// No description provided for @farmerNote.
  ///
  /// In en, this message translates to:
  /// **'Farmer Note'**
  String get farmerNote;

  /// No description provided for @myOffers.
  ///
  /// In en, this message translates to:
  /// **'My Offers'**
  String get myOffers;

  /// No description provided for @acceptOffer.
  ///
  /// In en, this message translates to:
  /// **'Accept Offer'**
  String get acceptOffer;

  /// No description provided for @rejectOffer.
  ///
  /// In en, this message translates to:
  /// **'Reject Offer'**
  String get rejectOffer;

  /// No description provided for @withdrawOffer.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Offer'**
  String get withdrawOffer;

  /// No description provided for @acceptedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Accepted Quantity'**
  String get acceptedQuantity;

  /// No description provided for @remainingQuantity.
  ///
  /// In en, this message translates to:
  /// **'Remaining Quantity'**
  String get remainingQuantity;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @partiallyFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Partially Fulfilled'**
  String get partiallyFulfilled;

  /// No description provided for @fulfilled.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled'**
  String get fulfilled;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @shortlisted.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get shortlisted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @withdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get withdrawn;

  /// No description provided for @bestQuality.
  ///
  /// In en, this message translates to:
  /// **'Best Quality'**
  String get bestQuality;

  /// No description provided for @earliestReadyDate.
  ///
  /// In en, this message translates to:
  /// **'Earliest Ready Date'**
  String get earliestReadyDate;

  /// No description provided for @noRequirements.
  ///
  /// In en, this message translates to:
  /// **'No requirements found'**
  String get noRequirements;

  /// No description provided for @noOffers.
  ///
  /// In en, this message translates to:
  /// **'No offers found'**
  String get noOffers;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @compareOffers.
  ///
  /// In en, this message translates to:
  /// **'Compare Offers'**
  String get compareOffers;

  /// No description provided for @buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyer;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @askMeAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything...'**
  String get askMeAnything;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @stopListening.
  ///
  /// In en, this message translates to:
  /// **'Stop Listening'**
  String get stopListening;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @clearConversation.
  ///
  /// In en, this message translates to:
  /// **'Clear Conversation'**
  String get clearConversation;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @findProducts.
  ///
  /// In en, this message translates to:
  /// **'Find Products'**
  String get findProducts;

  /// No description provided for @comparePrices.
  ///
  /// In en, this message translates to:
  /// **'Compare Prices'**
  String get comparePrices;

  /// No description provided for @findBulkRequirements.
  ///
  /// In en, this message translates to:
  /// **'Find Bulk Requirements'**
  String get findBulkRequirements;

  /// No description provided for @createListing.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListing;

  /// No description provided for @actionNeedsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Please confirm this action.'**
  String get actionNeedsConfirmation;

  /// No description provided for @actionNeedsMoreInformation.
  ///
  /// In en, this message translates to:
  /// **'I need more information to proceed.'**
  String get actionNeedsMoreInformation;

  /// No description provided for @actionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Action completed successfully.'**
  String get actionSuccess;

  /// No description provided for @actionError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the action.'**
  String get actionError;

  /// No description provided for @ai_ask_quantity.
  ///
  /// In en, this message translates to:
  /// **'How much quantity do you need?'**
  String get ai_ask_quantity;

  /// No description provided for @ai_ask_price.
  ///
  /// In en, this message translates to:
  /// **'What is your target price?'**
  String get ai_ask_price;

  /// No description provided for @ai_ask_crop.
  ///
  /// In en, this message translates to:
  /// **'Which crop are you looking for?'**
  String get ai_ask_crop;

  /// No description provided for @ai_confirm_listing.
  ///
  /// In en, this message translates to:
  /// **'Please confirm if you want to create this listing.'**
  String get ai_confirm_listing;

  /// No description provided for @ai_confirm_order.
  ///
  /// In en, this message translates to:
  /// **'Please confirm if you want to place this order.'**
  String get ai_confirm_order;

  /// No description provided for @ai_confirm_requirement.
  ///
  /// In en, this message translates to:
  /// **'Please confirm if you want to create this requirement.'**
  String get ai_confirm_requirement;

  /// No description provided for @ai_confirm_offer.
  ///
  /// In en, this message translates to:
  /// **'Please confirm if you want to submit this offer.'**
  String get ai_confirm_offer;

  /// No description provided for @ai_greet.
  ///
  /// In en, this message translates to:
  /// **'Hello! How can I help you today?'**
  String get ai_greet;

  /// No description provided for @ai_network_error.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get ai_network_error;

  /// No description provided for @ai_service_error.
  ///
  /// In en, this message translates to:
  /// **'AI service error. Please try again later.'**
  String get ai_service_error;

  /// No description provided for @ai_parse_error.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t understand that. Please rephrase.'**
  String get ai_parse_error;

  /// No description provided for @ai_fallback_response.
  ///
  /// In en, this message translates to:
  /// **'I\'m not sure how to help with that. Can you provide more details?'**
  String get ai_fallback_response;

  /// No description provided for @ai_action_success.
  ///
  /// In en, this message translates to:
  /// **'Action completed successfully.'**
  String get ai_action_success;

  /// No description provided for @ai_action_error.
  ///
  /// In en, this message translates to:
  /// **'Action failed to execute.'**
  String get ai_action_error;

  /// No description provided for @ai_confirm_action.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed?'**
  String get ai_confirm_action;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'as',
    'bn',
    'en',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'or',
    'pa',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return AppLocalizationsAs();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
