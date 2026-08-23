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
