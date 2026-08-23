import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/language_selection_screen.dart';
import '../../features/auth/presentation/pages/role_selection_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/marketplace/presentation/pages/farmer_home_screen.dart';
import '../../features/marketplace/presentation/pages/customer_home_screen.dart';
import '../../features/marketplace/presentation/pages/bulk_buyer_home_screen.dart';

import '../../features/auth/presentation/pages/phone_auth_screen.dart';
import '../../features/auth/presentation/pages/otp_screen.dart';
import '../../features/auth/presentation/pages/profile_completion_screen.dart';

import '../../features/marketplace/presentation/pages/my_products_screen.dart';
import '../../features/marketplace/presentation/pages/add_product_screen.dart';
import '../../features/marketplace/presentation/pages/product_details_screen.dart';
import '../../features/marketplace/presentation/pages/customer_marketplace_screen.dart';
import '../../features/marketplace/presentation/pages/cart_screen.dart';
import '../../features/marketplace/presentation/pages/checkout_screen.dart';
import '../../features/marketplace/presentation/pages/order_confirmation_screen.dart';
import '../../features/marketplace/presentation/pages/my_orders_screen.dart';
import '../../features/marketplace/presentation/pages/order_details_screen.dart';
import '../../features/marketplace/domain/entities/product_entity.dart';
import '../../features/marketplace/domain/entities/order_entity.dart';

import '../../features/marketplace/presentation/pages/create_bulk_requirement_screen.dart';
import '../../features/marketplace/presentation/pages/my_bulk_requirements_screen.dart';
import '../../features/marketplace/presentation/pages/bulk_requirement_details_screen.dart';
import '../../features/marketplace/presentation/pages/buyer_offers_list_screen.dart';
import '../../features/marketplace/presentation/pages/submit_bulk_offer_screen.dart';
import '../../features/marketplace/presentation/pages/farmer_bulk_requirements_screen.dart';
import '../../features/marketplace/presentation/pages/my_bulk_offers_screen.dart';
import '../../features/marketplace/domain/entities/bulk_requirement_entity.dart';

import '../../features/ai_assistant/presentation/pages/ai_assistant_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String languageSelection = '/language';
  static const String roleSelection = '/role';
  static const String phoneAuth = '/phoneAuth';
  static const String otp = '/otp';
  static const String profileCompletion = '/profileCompletion';
  static const String farmer = '/farmer';
  static const String customer = '/customer';
  static const String bulkBuyer = '/bulkBuyer';

  static const String myProducts = '/myProducts';
  static const String addProduct = '/addProduct';
  static const String productDetails = '/productDetails';
  static const String customerMarketplace = '/customerMarketplace';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/orderConfirmation';
  static const String myOrders = '/myOrders';
  static const String orderDetails = '/orderDetails';

  static const String myBulkRequirements = '/myBulkRequirements';
  static const String createBulkRequirement = '/createBulkRequirement';
  static const String bulkRequirementDetails = '/bulkRequirementDetails';
  static const String buyerOffersList = '/buyerOffersList';
  static const String farmerBulkRequirements = '/farmerBulkRequirements';
  static const String submitBulkOffer = '/submitBulkOffer';
  static const String myBulkOffers = '/myBulkOffers';

  static const String aiAssistant = '/aiAssistant';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case languageSelection:
        return MaterialPageRoute(
          builder: (_) => const LanguageSelectionScreen(),
        );
      case roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case phoneAuth:
        return MaterialPageRoute(builder: (_) => const PhoneAuthScreen());
      case otp:
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case profileCompletion:
        return MaterialPageRoute(
          builder: (_) => const ProfileCompletionScreen(),
        );
      case farmer:
        return MaterialPageRoute(builder: (_) => const FarmerHomeScreen());
      case customer:
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());
      case bulkBuyer:
        return MaterialPageRoute(builder: (_) => const BulkBuyerHomeScreen());
      case myProducts:
        return MaterialPageRoute(builder: (_) => const MyProductsScreen());
      case addProduct:
        final product = settings.arguments as ProductEntity?;
        return MaterialPageRoute(
          builder: (_) => AddProductScreen(productToEdit: product),
        );
      case productDetails:
        final product = settings.arguments as ProductEntity;
        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        );
      case customerMarketplace:
        return MaterialPageRoute(
          builder: (_) => const CustomerMarketplaceScreen(),
        );
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case orderConfirmation:
        return MaterialPageRoute(
          builder: (_) => const OrderConfirmationScreen(),
        );
      case myOrders:
        return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
      case orderDetails:
        final order = settings.arguments as OrderEntity;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(order: order),
        );
      case myBulkRequirements:
        return MaterialPageRoute(
          builder: (_) => const MyBulkRequirementsScreen(),
        );
      case createBulkRequirement:
        return MaterialPageRoute(
          builder: (_) => const CreateBulkRequirementScreen(),
        );
      case bulkRequirementDetails:
        final req = settings.arguments as BulkRequirementEntity;
        return MaterialPageRoute(
          builder: (_) => BulkRequirementDetailsScreen(requirement: req),
        );
      case buyerOffersList:
        final req = settings.arguments as BulkRequirementEntity;
        return MaterialPageRoute(
          builder: (_) => BuyerOffersListScreen(requirement: req),
        );
      case farmerBulkRequirements:
        return MaterialPageRoute(
          builder: (_) => const FarmerBulkRequirementsScreen(),
        );
      case submitBulkOffer:
        final req = settings.arguments as BulkRequirementEntity;
        return MaterialPageRoute(
          builder: (_) => SubmitBulkOfferScreen(requirement: req),
        );
      case myBulkOffers:
        return MaterialPageRoute(builder: (_) => const MyBulkOffersScreen());
      case aiAssistant:
        return MaterialPageRoute(builder: (_) => const AiAssistantScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
