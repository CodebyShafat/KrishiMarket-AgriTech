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
  Future<AiMessageEntity> sendMessage(
    String text,
    String language,
    Map<String, dynamic> userContext,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    if (text == 'simulate_network_error') {
      throw Exception('Network error');
    }
    if (text == 'simulate_timeout') {
      throw Exception('Timeout');
    }
    if (text == 'simulate_parse_error') {
      throw FormatException('Parse error');
    }

    AiIntent detectedIntent = _detectIntent(text, language);

    // Manage multi-turn context
    if (detectedIntent == AiIntent.unknown && _state.currentIntent != null) {
      detectedIntent = _state.currentIntent!;
    }

    _state = _state.copyWith(currentIntent: detectedIntent);

    final mockResponse = _getMockResponse(detectedIntent, text, language);

    final msgId = 'ai-${DateTime.now().millisecondsSinceEpoch}';
    return AiMessageEntity(
      id: msgId,
      role: AiMessageRole.assistant,
      content: mockResponse['response_key'],
      timestamp: DateTime.now(),
      language: language,
      intent: detectedIntent,
      parameters: mockResponse['parameters'],
      requiresConfirmation: mockResponse['requires_confirmation'] ?? false,
    );
  }

  AiIntent _detectIntent(String text, String language) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('1000') || lowerText.contains('bulk')) {
      return AiIntent.createBulkRequirement;
    }
    if (lowerText.contains('sell') || lowerText.contains('list')) {
      return AiIntent.createProductListing;
    }
    if (lowerText.contains('cart')) {
      return AiIntent.viewCart;
    }
    if (lowerText.contains('order')) {
      return AiIntent.viewOrders;
    }
    if (lowerText.contains('offer')) {
      return AiIntent.submitBulkOffer;
    }

    if (lowerText.length > 3) {
      return AiIntent.searchProduct;
    }

    return AiIntent.unknown;
  }

  Map<String, dynamic> _getMockResponse(
    AiIntent intent,
    String text,
    String language,
  ) {
    switch (intent) {
      case AiIntent.searchProduct:
      case AiIntent.viewCart:
      case AiIntent.viewOrders:
        return {
          'response_key': 'ai_action_success',
          'parameters': <String, dynamic>{'query': 'wheat'},
          'requires_confirmation':
              true, // Mock asking for confirmation for some
        };
      case AiIntent.createProductListing:
      case AiIntent.createBulkRequirement:
        return {
          'response_key': 'ai_ask_quantity',
          'parameters': <String, dynamic>{
            'missingFields': ['quantity'],
          },
          'requires_confirmation': false,
        };
      default:
        return {
          'response_key': 'ai_fallback_response',
          'parameters': <String, dynamic>{},
          'requires_confirmation': false,
        };
    }
  }
}
