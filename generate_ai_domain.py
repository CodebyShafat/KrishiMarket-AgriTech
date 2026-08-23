import os

files = {
    r"lib\features\ai_assistant\domain\entities\ai_intent.dart": """
enum AiIntent {
  searchProduct,
  viewProduct,
  compareProducts,
  addToCart,
  viewCart,
  viewOrders,
  trackOrder,
  createProductListing,
  updateProduct,
  createBulkRequirement,
  viewBulkRequirements,
  submitBulkOffer,
  viewBulkOffers,
  generalQuestion,
  unknown
}
""",
    r"lib\features\ai_assistant\domain\entities\ai_action_result.dart": """
import 'ai_intent.dart';

enum AiActionResultStatus {
  success,
  needsConfirmation,
  needsMoreInformation,
  error
}

class AiActionResult {
  final AiActionResultStatus status;
  final String message;
  final AiIntent intent;
  final dynamic data;
  final List<String>? missingFields;

  AiActionResult({
    required this.status,
    required this.message,
    required this.intent,
    this.data,
    this.missingFields,
  });
}
""",
    r"lib\features\ai_assistant\domain\entities\ai_message_entity.dart": """
import 'ai_intent.dart';
import 'ai_action_result.dart';

enum AiMessageRole { user, assistant, system }

class AiMessageEntity {
  final String id;
  final AiMessageRole role;
  final String content;
  final DateTime timestamp;
  final String language;
  final AiIntent? intent;
  final bool isLoading;
  final AiActionResult? actionResult;

  AiMessageEntity({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    required this.language,
    this.intent,
    this.isLoading = false,
    this.actionResult,
  });

  AiMessageEntity copyWith({
    String? id,
    AiMessageRole? role,
    String? content,
    DateTime? timestamp,
    String? language,
    AiIntent? intent,
    bool? isLoading,
    AiActionResult? actionResult,
  }) {
    return AiMessageEntity(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      language: language ?? this.language,
      intent: intent ?? this.intent,
      isLoading: isLoading ?? this.isLoading,
      actionResult: actionResult ?? this.actionResult,
    );
  }
}
""",
    r"lib\features\ai_assistant\domain\entities\ai_conversation_state.dart": """
import 'ai_message_entity.dart';
import 'ai_intent.dart';

class AiConversationState {
  final List<AiMessageEntity> messages;
  final AiIntent? currentIntent;
  final String? pendingAction;
  final List<String>? missingFields;
  final Map<String, dynamic> contextData;
  final bool isProcessing;

  AiConversationState({
    this.messages = const [],
    this.currentIntent,
    this.pendingAction,
    this.missingFields,
    this.contextData = const {},
    this.isProcessing = false,
  });

  AiConversationState copyWith({
    List<AiMessageEntity>? messages,
    AiIntent? currentIntent,
    String? pendingAction,
    List<String>? missingFields,
    Map<String, dynamic>? contextData,
    bool? isProcessing,
  }) {
    return AiConversationState(
      messages: messages ?? this.messages,
      currentIntent: currentIntent ?? this.currentIntent,
      pendingAction: pendingAction ?? this.pendingAction,
      missingFields: missingFields ?? this.missingFields,
      contextData: contextData ?? this.contextData,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
""",
    r"lib\features\ai_assistant\domain\repositories\ai_action_executor.dart": """
import '../entities/ai_action_result.dart';
import '../entities/ai_intent.dart';

abstract class AiActionExecutor {
  Future<AiActionResult> executeAction(AiIntent intent, Map<String, dynamic> parameters);
}
""",
    r"lib\features\ai_assistant\domain\repositories\ai_assistant_repository.dart": """
import '../entities/ai_message_entity.dart';
import '../entities/ai_conversation_state.dart';

abstract class AiAssistantRepository {
  Future<AiMessageEntity> sendMessage(String text, String language, Map<String, dynamic> userContext);
  Future<AiConversationState> getConversationHistory();
  Future<void> clearConversation();
}
""",
    r"lib\features\ai_assistant\domain\repositories\voice_input_service.dart": """
abstract class VoiceInputService {
  Future<void> startListening(String languageCode, Function(String) onResult);
  Future<void> stopListening();
  bool get isListening;
}
""",
    r"lib\features\ai_assistant\domain\repositories\voice_output_service.dart": """
abstract class VoiceOutputService {
  Future<void> speak(String text, String languageCode);
  Future<void> stop();
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
