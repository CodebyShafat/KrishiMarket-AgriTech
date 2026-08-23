import '../../domain/repositories/ai_action_executor.dart';
import '../../domain/entities/ai_action_result.dart';
import '../../domain/entities/ai_intent.dart';
import '../../../marketplace/domain/repositories/product_repository.dart';
import '../../../marketplace/domain/repositories/cart_repository.dart';
import '../../../marketplace/domain/repositories/order_repository.dart';
import '../../../marketplace/domain/repositories/bulk_requirement_repository.dart';
import '../../../marketplace/domain/repositories/bulk_offer_repository.dart';

class MockAiActionExecutor implements AiActionExecutor {
  final ProductRepository productRepository;
  final CartRepository cartRepository;
  final OrderRepository orderRepository;
  final BulkRequirementRepository bulkRequirementRepository;
  final BulkOfferRepository bulkOfferRepository;

  MockAiActionExecutor({
    required this.productRepository,
    required this.cartRepository,
    required this.orderRepository,
    required this.bulkRequirementRepository,
    required this.bulkOfferRepository,
  });

  @override
  Future<AiActionResult> executeAction(
    AiIntent intent,
    Map<String, dynamic> parameters,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API delay

    try {
      switch (intent) {
        case AiIntent.searchProduct:
          return await _executeSearchProduct(parameters);
        case AiIntent.createProductListing:
          return _executeCreateProductListing(parameters);
        case AiIntent.createBulkRequirement:
          return _executeCreateBulkRequirement(parameters);
        default:
          return AiActionResult(
            status: AiActionResultStatus.error,
            message: 'Action not supported yet.',
            intent: intent,
          );
      }
    } catch (e) {
      return AiActionResult(
        status: AiActionResultStatus.error,
        message: 'Execution error: $e',
        intent: intent,
      );
    }
  }

  Future<AiActionResult> _executeSearchProduct(
    Map<String, dynamic> parameters,
  ) async {
    final query = parameters['query'] as String?;
    if (query == null) {
      return AiActionResult(
        status: AiActionResultStatus.needsMoreInformation,
        message: 'What product are you looking for?',
        intent: AiIntent.searchProduct,
        missingFields: ['query'],
      );
    }

    // Simulate hitting the Product Repository
    final allProducts = await productRepository.getAllAvailableProducts();
    final results = allProducts
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Sort logic (mocking "cheapest")
    if (parameters['cheapest'] == true) {
      results.sort((a, b) => a.price.compareTo(b.price));
    }

    return AiActionResult(
      status: AiActionResultStatus.success,
      message: 'Found ${results.length} products for "$query".',
      intent: AiIntent.searchProduct,
      data: results,
    );
  }

  AiActionResult _executeCreateProductListing(Map<String, dynamic> parameters) {
    List<String> missing = [];
    if (!parameters.containsKey('productName')) missing.add('productName');
    if (!parameters.containsKey('quantity')) missing.add('quantity');
    if (!parameters.containsKey('price')) missing.add('price');

    if (missing.isNotEmpty) {
      String msg = 'I need more details: ${missing.join(', ')}.';
      if (missing.contains('quantity') &&
          parameters.containsKey('productName')) {
        msg = 'How much ${parameters['productName']} do you want to sell?';
      } else if (missing.contains('price')) {
        msg = 'What price per kg would you like?';
      }
      return AiActionResult(
        status: AiActionResultStatus.needsMoreInformation,
        message: msg,
        intent: AiIntent.createProductListing,
        missingFields: missing,
      );
    }

    if (parameters['confirmed'] != true) {
      return AiActionResult(
        status: AiActionResultStatus.needsConfirmation,
        message:
            'You are about to list ${parameters['quantity']}kg of ${parameters['productName']} at ₹${parameters['price']}/kg. Do you want to continue?',
        intent: AiIntent.createProductListing,
      );
    }

    return AiActionResult(
      status: AiActionResultStatus.success,
      message: 'Product listing created successfully!',
      intent: AiIntent.createProductListing,
      data: parameters,
    );
  }

  AiActionResult _executeCreateBulkRequirement(
    Map<String, dynamic> parameters,
  ) {
    List<String> missing = [];
    if (!parameters.containsKey('productName')) missing.add('productName');
    if (!parameters.containsKey('quantity')) missing.add('quantity');

    if (missing.isNotEmpty) {
      return AiActionResult(
        status: AiActionResultStatus.needsMoreInformation,
        message: 'Please tell me the product name and quantity you require.',
        intent: AiIntent.createBulkRequirement,
        missingFields: missing,
      );
    }

    if (parameters['confirmed'] != true) {
      return AiActionResult(
        status: AiActionResultStatus.needsConfirmation,
        message:
            'Create requirement for ${parameters['quantity']}kg of ${parameters['productName']}?',
        intent: AiIntent.createBulkRequirement,
      );
    }

    return AiActionResult(
      status: AiActionResultStatus.success,
      message: 'Bulk requirement published!',
      intent: AiIntent.createBulkRequirement,
      data: parameters,
    );
  }
}
