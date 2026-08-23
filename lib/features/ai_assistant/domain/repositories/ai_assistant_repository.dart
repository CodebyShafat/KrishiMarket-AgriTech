import '../entities/ai_message_entity.dart';
import '../entities/ai_conversation_state.dart';

abstract class AiAssistantRepository {
  Future<AiMessageEntity> sendMessage(
    String text,
    String language,
    Map<String, dynamic> userContext,
  );
  Future<AiConversationState> getConversationHistory();
  Future<void> clearConversation();
}
