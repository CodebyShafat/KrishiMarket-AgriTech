import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/repositories/ai_assistant_repository.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_intent.dart';
import '../../domain/entities/ai_conversation_state.dart';
import '../../../../core/network/api_client.dart';

class ApiAiAssistantRepository implements AiAssistantRepository {
  final http.Client client;
  final ApiClient apiClient;

  AiConversationState _state = AiConversationState();

  ApiAiAssistantRepository({
    required this.client,
    required this.apiClient,
  });

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
    try {
      final headers = {
        'Content-Type': 'application/json',
      };
      final token = await apiClient.secureStorage.read(key: 'access_token'); 
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client
          .post(
            Uri.parse('${apiClient.baseUrl}/ai/chat'),
            headers: headers,
            body: jsonEncode({
              'text': text,
              'language': language,
              'context': userContext,
              'history': _state.messages
                  .map((m) => {'role': m.role.name, 'content': m.content})
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final intentStr = data['intent'] as String?;
        final AiIntent detectedIntent = _parseIntent(intentStr);
        final parameters = data['entities'] as Map<String, dynamic>? ?? {};
        final responseKey = data['response_key'] as String? ?? 'ai_fallback_response';
        final requiresConfirmation = data['requires_confirmation'] as bool? ?? false;

        _state = _state.copyWith(currentIntent: detectedIntent);

        return AiMessageEntity(
          id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
          role: AiMessageRole.assistant,
          content: responseKey,
          timestamp: DateTime.now(),
          language: language,
          intent: detectedIntent,
          parameters: parameters,
          requiresConfirmation: requiresConfirmation,
        );
      } else {
        try {
          final errData = jsonDecode(response.body);
          if (errData['detail'] != null && errData['detail'].toString().contains('Gemini API key is not configured')) {
            return _createErrorMessage(language, 'Gemini API key is not configured');
          }
        } catch (_) {}
        return _createErrorMessage(language, 'ai_service_error');
      }
    } on FormatException {
      return _createErrorMessage(language, 'ai_parse_error');
    } catch (e) {
      return _createErrorMessage(language, 'ai_network_error');
    }
  }

  AiMessageEntity _createErrorMessage(String language, String responseKey) {
    return AiMessageEntity(
      id: 'ai-error-${DateTime.now().millisecondsSinceEpoch}',
      role: AiMessageRole.assistant,
      content: responseKey,
      timestamp: DateTime.now(),
      language: language,
      intent: AiIntent.unknown,
    );
  }

  AiIntent _parseIntent(String? intentStr) {
    if (intentStr == null) return AiIntent.unknown;
    return AiIntent.values.firstWhere(
      (e) => e.name == intentStr,
      orElse: () => AiIntent.unknown,
    );
  }
}
