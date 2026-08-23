import os

files = {
    r"lib\features\ai_assistant\data\repositories\mock_ai_action_executor.dart": """
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
  Future<AiActionResult> executeAction(AiIntent intent, Map<String, dynamic> parameters) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay

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

  Future<AiActionResult> _executeSearchProduct(Map<String, dynamic> parameters) async {
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
    final allProducts = await productRepository.getProductsForMarketplace();
    final results = allProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    
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
      if (missing.contains('quantity') && parameters.containsKey('productName')) {
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
        message: 'You are about to list ${parameters['quantity']}kg of ${parameters['productName']} at ₹${parameters['price']}/kg. Do you want to continue?',
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

  AiActionResult _executeCreateBulkRequirement(Map<String, dynamic> parameters) {
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
        message: 'Create requirement for ${parameters['quantity']}kg of ${parameters['productName']}?',
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
""",
    r"lib\features\ai_assistant\data\repositories\mock_ai_assistant_repository.dart": """
import '../../domain/repositories/ai_assistant_repository.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_intent.dart';
import '../../domain/entities/ai_conversation_state.dart';

class MockAiAssistantRepository implements AiAssistantRepository {
  AiConversationState _state = AiConversationState();

  @override
  Future<AiConversationState> getConversationHistory() async {
    return _state;
  }

  @override
  Future<void> clearConversation() async {
    _state = AiConversationState();
  }

  @override
  Future<AiMessageEntity> sendMessage(String text, String language, Map<String, dynamic> userContext) async {
    await Future.delayed(const Duration(seconds: 1));

    AiIntent detectedIntent = _detectIntent(text, language);
    
    // Manage multi-turn context
    if (detectedIntent == AiIntent.unknown && _state.currentIntent != null) {
      detectedIntent = _state.currentIntent!;
    }
    
    _state = _state.copyWith(currentIntent: detectedIntent);

    final msgId = 'ai-${DateTime.now().millisecondsSinceEpoch}';
    return AiMessageEntity(
      id: msgId,
      role: AiMessageRole.assistant,
      content: _getMockResponse(detectedIntent, text, language),
      timestamp: DateTime.now(),
      language: language,
      intent: detectedIntent,
    );
  }

  AiIntent _detectIntent(String text, String language) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('cheapest') || lowerText.contains('wheat') || lowerText.contains('find') || lowerText.contains('खोजें') || lowerText.contains('दिखाओ')) {
      if (lowerText.contains('sell') || lowerText.contains('बेचना')) return AiIntent.createProductListing;
      return AiIntent.searchProduct;
    }
    if (lowerText.contains('cart') || lowerText.contains('कार्ट')) return AiIntent.viewCart;
    if (lowerText.contains('order') || lowerText.contains('ऑर्डर')) return AiIntent.viewOrders;
    if (lowerText.contains('track')) return AiIntent.trackOrder;
    if (lowerText.contains('sell')) return AiIntent.createProductListing;
    if (lowerText.contains('need') || lowerText.contains('चाहिए')) return AiIntent.createBulkRequirement;
    if (lowerText.contains('submit') || lowerText.contains('offer')) return AiIntent.submitBulkOffer;
    
    return AiIntent.unknown;
  }

  String _getMockResponse(AiIntent intent, String text, String language) {
    bool isHindi = language == 'hi';
    switch (intent) {
      case AiIntent.searchProduct:
        return isHindi ? 'यहाँ कुछ उत्पाद दिए गए हैं।' : 'Here are some products I found.';
      case AiIntent.viewCart:
        return isHindi ? 'मैं आपको कार्ट दिखा रहा हूँ।' : 'Fetching your cart...';
      case AiIntent.viewOrders:
        return isHindi ? 'ये रहे आपके ऑर्डर।' : 'Here are your orders.';
      case AiIntent.createProductListing:
        return isHindi ? 'ठीक है, आप क्या बेचना चाहते हैं?' : 'Okay, what product do you want to sell?';
      case AiIntent.createBulkRequirement:
        return isHindi ? 'ठीक है, आपको कितनी मात्रा चाहिए?' : 'Sure, let me help you create a bulk requirement.';
      default:
        return isHindi ? 'माफ़ करें, मैं समझ नहीं पाया।' : 'I am not sure how to help with that yet.';
    }
  }
}
""",
    r"lib\features\ai_assistant\data\repositories\mock_voice_services.dart": """
import '../../domain/repositories/voice_input_service.dart';
import '../../domain/repositories/voice_output_service.dart';

class MockVoiceInputService implements VoiceInputService {
  bool _isListening = false;

  @override
  bool get isListening => _isListening;

  @override
  Future<void> startListening(String languageCode, Function(String) onResult) async {
    _isListening = true;
    
    // Simulate delay
    await Future.delayed(const Duration(seconds: 3));
    
    if (_isListening) {
      if (languageCode == 'hi') {
        onResult('मुझे 1000 किलो आलू चाहिए');
      } else {
        onResult('Find the cheapest wheat');
      }
      _isListening = false;
    }
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
  }
}

class MockVoiceOutputService implements VoiceOutputService {
  @override
  Future<void> speak(String text, String languageCode) async {
    // Just mock TTS
    print('TTS speaking ($languageCode): $text');
  }

  @override
  Future<void> stop() async {
    print('TTS stopped');
  }
}
"""
}

def main():
    for filepath, content in files.items():
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content.strip())
            print(f"Created {filepath}")

if __name__ == '__main__':
    main()
