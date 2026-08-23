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

    if (lowerText.contains('cheapest') ||
        lowerText.contains('wheat') ||
        lowerText.contains('find') ||
        lowerText.contains('खोजें') ||
        lowerText.contains('दिखाओ')) {
      if (lowerText.contains('sell') || lowerText.contains('बेचना'))
        return AiIntent.createProductListing;
      return AiIntent.searchProduct;
    }
    if (lowerText.contains('cart') || lowerText.contains('कार्ट'))
      return AiIntent.viewCart;
    if (lowerText.contains('order') || lowerText.contains('ऑर्डर'))
      return AiIntent.viewOrders;
    if (lowerText.contains('track')) return AiIntent.trackOrder;
    if (lowerText.contains('sell')) return AiIntent.createProductListing;
    if (lowerText.contains('need') || lowerText.contains('चाहिए'))
      return AiIntent.createBulkRequirement;
    if (lowerText.contains('submit') || lowerText.contains('offer'))
      return AiIntent.submitBulkOffer;

    return AiIntent.unknown;
  }

  String _getMockResponse(AiIntent intent, String text, String language) {
    bool isHindi = language == 'hi';
    switch (intent) {
      case AiIntent.searchProduct:
        return isHindi
            ? 'यहाँ कुछ उत्पाद दिए गए हैं।'
            : 'Here are some products I found.';
      case AiIntent.viewCart:
        return isHindi
            ? 'मैं आपको कार्ट दिखा रहा हूँ।'
            : 'Fetching your cart...';
      case AiIntent.viewOrders:
        return isHindi ? 'ये रहे आपके ऑर्डर।' : 'Here are your orders.';
      case AiIntent.createProductListing:
        return isHindi
            ? 'ठीक है, आप क्या बेचना चाहते हैं?'
            : 'Okay, what product do you want to sell?';
      case AiIntent.createBulkRequirement:
        return isHindi
            ? 'ठीक है, आपको कितनी मात्रा चाहिए?'
            : 'Sure, let me help you create a bulk requirement.';
      default:
        return isHindi
            ? 'माफ़ करें, मैं समझ नहीं पाया।'
            : 'I am not sure how to help with that yet.';
    }
  }
}
