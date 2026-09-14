abstract class VoiceInputService {
  Future<bool> initialize();
  Future<void> startListening({
    required String languageCode,
    required Function(String, bool) onResult,
    required Function(String) onError,
  });
  Future<void> stopListening();
  Future<void> cancelListening();
  bool get isListening;
}
