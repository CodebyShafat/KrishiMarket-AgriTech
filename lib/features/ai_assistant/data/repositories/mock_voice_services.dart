import '../../domain/repositories/voice_input_service.dart';
import '../../domain/repositories/voice_output_service.dart';

import 'package:flutter/foundation.dart';

class MockVoiceInputService implements VoiceInputService {
  bool _isListening = false;

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize() async {
    return true;
  }

  @override
  Future<void> startListening({
    required String languageCode,
    required Function(String, bool) onResult,
    required Function(String) onError,
  }) async {
    _isListening = true;

    // Simulate delay
    await Future.delayed(const Duration(seconds: 3));

    if (_isListening) {
      if (languageCode == 'hi' || languageCode == 'hi-IN') {
        onResult('मुझे 1000 किलो आलू चाहिए', true);
      } else {
        onResult('Find the cheapest wheat', true);
      }
      _isListening = false;
    }
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
  }
  
  @override
  Future<void> cancelListening() async {
    _isListening = false;
  }
}

class MockVoiceOutputService implements VoiceOutputService {
  @override
  Future<void> speak(String text, String languageCode) async {
    // Just mock TTS
    debugPrint('TTS speaking ($languageCode): $text');
  }

  @override
  Future<void> stop() async {
    debugPrint('TTS stopped');
  }
}
