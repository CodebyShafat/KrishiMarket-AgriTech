import 'package:flutter/foundation.dart';

import '../../domain/repositories/ai_assistant_repository.dart';
import '../../domain/repositories/ai_action_executor.dart';
import '../../domain/repositories/voice_input_service.dart';
import '../../domain/repositories/voice_output_service.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_intent.dart';
import '../../domain/entities/ai_action_result.dart';

class AiAssistantProvider with ChangeNotifier {
  final AiAssistantRepository assistantRepository;
  final AiActionExecutor actionExecutor;
  final VoiceInputService voiceInputService;
  final VoiceOutputService voiceOutputService;

  List<AiMessageEntity> _messages = [];
  bool _isProcessing = false;
  Map<String, dynamic> _currentContextData = {};

  List<AiMessageEntity> get messages => _messages;
  bool get isProcessing => _isProcessing;
  bool get isListening => voiceInputService.isListening;

  AiAssistantProvider({
    required this.assistantRepository,
    required this.actionExecutor,
    required this.voiceInputService,
    required this.voiceOutputService,
  });

  Future<void> sendMessage(String text, String language, String role) async {
    if (text.trim().isEmpty) return;

    final userMsg = AiMessageEntity(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      role: AiMessageRole.user,
      content: text,
      timestamp: DateTime.now(),
      language: language,
    );

    _messages.add(userMsg);
    _isProcessing = true;
    notifyListeners();

    try {
      final userContext = {'role': role};
      final aiMsg = await assistantRepository.sendMessage(
        text,
        language,
        userContext,
      );

      if (aiMsg.intent != null &&
          aiMsg.intent != AiIntent.unknown &&
          aiMsg.intent != AiIntent.generalQuestion) {
        _currentContextData = _extractEntities(text, _currentContextData);
        final actionResult = await actionExecutor.executeAction(
          aiMsg.intent!,
          _currentContextData,
        );

        final finalMsg = aiMsg.copyWith(
          content: actionResult.message,
          actionResult: actionResult,
        );
        _messages.add(finalMsg);
        voiceOutputService.speak(finalMsg.content, language);

        if (actionResult.status == AiActionResultStatus.success ||
            actionResult.status == AiActionResultStatus.error) {
          _currentContextData.clear(); // Reset context
        }
      } else {
        _messages.add(aiMsg);
        voiceOutputService.speak(aiMsg.content, language);
      }
    } catch (e) {
      _messages.add(
        AiMessageEntity(
          id: 'err-${DateTime.now().millisecondsSinceEpoch}',
          role: AiMessageRole.system,
          content: 'Error: $e',
          timestamp: DateTime.now(),
          language: language,
        ),
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Dummy extraction
  Map<String, dynamic> _extractEntities(
    String text,
    Map<String, dynamic> current,
  ) {
    final Map<String, dynamic> updated = Map.from(current);
    final lower = text.toLowerCase();

    if (lower.contains('wheat') || lower.contains('गेहूं'))
      updated['productName'] = 'Wheat';
    if (lower.contains('potato') || lower.contains('आलू'))
      updated['productName'] = 'Potato';
    if (lower.contains('cheapest')) updated['cheapest'] = true;
    if (lower.contains('1000') || lower.contains('1000 kg'))
      updated['quantity'] = '1000';
    if (lower.contains('500') || lower.contains('500 kg'))
      updated['quantity'] = '500';
    if (lower.contains('28')) updated['price'] = '28';
    if (lower.contains('yes') ||
        lower.contains('हाँ') ||
        lower.contains('confirm'))
      updated['confirmed'] = true;

    if (updated['productName'] != null)
      updated['query'] = updated['productName'];
    return updated;
  }

  void startVoiceInput(String language, String role) {
    voiceInputService.startListening(language, (result) {
      sendMessage(result, language, role);
      notifyListeners();
    });
    notifyListeners();
  }

  void stopVoiceInput() {
    voiceInputService.stopListening();
    notifyListeners();
  }

  Future<void> clearConversation() async {
    await assistantRepository.clearConversation();
    _messages.clear();
    _currentContextData.clear();
    notifyListeners();
  }
}
