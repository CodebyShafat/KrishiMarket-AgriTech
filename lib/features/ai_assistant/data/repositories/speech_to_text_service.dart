import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../domain/repositories/voice_input_service.dart';

class SpeechToTextService implements VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }
    
    if (status.isGranted) {
      try {
        bool available = await _speech.initialize(
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              _isListening = false;
            }
          },
          onError: (errorNotification) {
            _isListening = false;
            debugPrint('SpeechToText error: \${errorNotification.errorMsg}');
          },
        );
        return available;
      } catch (e) {
        debugPrint('SpeechToText initialize error: \$e');
        return false;
      }
    }
    return false;
  }

  @override
  Future<void> startListening({
    required String languageCode,
    required Function(String, bool) onResult,
    required Function(String) onError,
  }) async {
    if (!await initialize()) {
      onError('error_mic_permission_denied');
      return;
    }

    _isListening = true;
    try {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
          localeId: languageCode,
        ),
      );
    } catch (e) {
      _isListening = false;
      onError('error_stt_timeout');
    }
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  @override
  Future<void> cancelListening() async {
    await _speech.cancel();
    _isListening = false;
  }
}
