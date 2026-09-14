import 'package:flutter/foundation.dart';

import '../../domain/repositories/ai_assistant_repository.dart';
import '../../domain/repositories/ai_action_executor.dart';
import '../../domain/repositories/voice_input_service.dart';
import '../../domain/repositories/voice_output_service.dart';
import '../../domain/entities/ai_message_entity.dart';

enum AiVoiceState {
  idle,
  listening,
  transcribing,
  transcriptReview,
  processing,
  confirmation,
  executing,
  success,
  error
}

class AiAssistantProvider with ChangeNotifier {
  final AiAssistantRepository assistantRepository;
  final AiActionExecutor actionExecutor;
  final VoiceInputService voiceInputService;
  final VoiceOutputService voiceOutputService;

  final List<AiMessageEntity> _messages = [];
  bool _isProcessing = false;
  final Map<String, dynamic> _currentContextData = {};

  AiVoiceState _voiceState = AiVoiceState.idle;
  String _currentTranscript = '';
  String _errorMessage = '';

  List<AiMessageEntity> get messages => _messages;
  bool get isProcessing => _isProcessing;
  bool get isListening => voiceInputService.isListening;
  
  AiVoiceState get voiceState => _voiceState;
  String get currentTranscript => _currentTranscript;
  String get errorMessage => _errorMessage;

  AiAssistantProvider({
    required this.assistantRepository,
    required this.actionExecutor,
    required this.voiceInputService,
    required this.voiceOutputService,
  });

  void setTranscript(String text) {
    _currentTranscript = text;
    notifyListeners();
  }

  void _setState(AiVoiceState state) {
    _voiceState = state;
    notifyListeners();
  }

  Future<void> sendMessage(String text, String language, String role) async {
    if (text.trim().isEmpty) return;
    _setState(AiVoiceState.processing);

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

      _messages.add(aiMsg);
      if (aiMsg.requiresConfirmation) {
        _setState(AiVoiceState.confirmation);
      } else {
        _setState(AiVoiceState.idle);
      }
    } catch (e) {
      debugPrint('EXCEPTION IN PROVIDER SENDMESSAGE: $e');
      _errorMessage = 'ai_service_error';
      _setState(AiVoiceState.error);
      _messages.add(
        AiMessageEntity(
          id: 'err-${DateTime.now().millisecondsSinceEpoch}',
          role: AiMessageRole.system,
          content: 'ai_service_error',
          timestamp: DateTime.now(),
          language: language,
        ),
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> confirmAction(AiMessageEntity aiMsg) async {
    if (aiMsg.intent == null || aiMsg.parameters == null) return;

    _isProcessing = true;
    _setState(AiVoiceState.executing);
    notifyListeners();

    try {
      final actionResult = await actionExecutor.executeAction(
        aiMsg.intent!,
        aiMsg.parameters!,
      );

      final resultMsg = AiMessageEntity(
        id: 'sys-${DateTime.now().millisecondsSinceEpoch}',
        role: AiMessageRole.system,
        content:
            actionResult.message, // This should also ideally be a response key
        timestamp: DateTime.now(),
        language: aiMsg.language,
        actionResult: actionResult,
      );

      _messages.add(resultMsg);
      _setState(AiVoiceState.success);
    } catch (e) {
      _errorMessage = 'ai_action_error';
      _setState(AiVoiceState.error);
      _messages.add(
        AiMessageEntity(
          id: 'err-${DateTime.now().millisecondsSinceEpoch}',
          role: AiMessageRole.system,
          content: 'ai_action_error',
          timestamp: DateTime.now(),
          language: aiMsg.language,
        ),
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
      
      Future.delayed(const Duration(seconds: 2), () {
        if (_voiceState == AiVoiceState.success || _voiceState == AiVoiceState.error) {
          _setState(AiVoiceState.idle);
        }
      });
    }
  }
  
  void cancelConfirmation() {
    _setState(AiVoiceState.idle);
  }

  void startVoiceInput(String appLanguage, String role) async {
    _currentTranscript = '';
    _errorMessage = '';
    _setState(AiVoiceState.listening);

    // Map appLanguage to STT locale
    final localeMap = {
      'as': 'as-IN', 'bn': 'bn-IN', 'gu': 'gu-IN', 'hi': 'hi-IN',
      'kn': 'kn-IN', 'ml': 'ml-IN', 'mr': 'mr-IN', 'or': 'or-IN',
      'pa': 'pa-IN', 'ta': 'ta-IN', 'te': 'te-IN', 'en': 'en-IN'
    };
    final locale = localeMap[appLanguage] ?? 'en-IN';

    await voiceInputService.startListening(
      languageCode: locale,
      onResult: (text, isFinal) {
        _currentTranscript = text;
        if (isFinal) {
          _setState(AiVoiceState.transcriptReview);
        } else {
          _setState(AiVoiceState.transcribing);
        }
      },
      onError: (errCode) {
        _errorMessage = errCode;
        _setState(AiVoiceState.error);
      },
    );
  }

  void stopVoiceInput() async {
    await voiceInputService.stopListening();
    if (_voiceState == AiVoiceState.listening || _voiceState == AiVoiceState.transcribing) {
        _setState(AiVoiceState.transcriptReview);
    }
  }
  
  void cancelVoiceInput() async {
    await voiceInputService.cancelListening();
    _currentTranscript = '';
    _setState(AiVoiceState.idle);
  }

  Future<void> clearConversation() async {
    await assistantRepository.clearConversation();
    _messages.clear();
    _currentContextData.clear();
    _setState(AiVoiceState.idle);
    notifyListeners();
  }
}
