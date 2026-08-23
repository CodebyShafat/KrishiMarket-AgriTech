import '../../domain/repositories/voice_input_service.dart';
import '../../domain/repositories/voice_output_service.dart';

class MockVoiceInputService implements VoiceInputService {
  bool _isListening = false;

  @override
  bool get isListening => _isListening;

  @override
  Future<void> startListening(
    String languageCode,
    Function(String) onResult,
  ) async {
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
