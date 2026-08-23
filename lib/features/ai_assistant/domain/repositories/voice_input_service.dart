abstract class VoiceInputService {
  Future<void> startListening(String languageCode, Function(String) onResult);
  Future<void> stopListening();
  bool get isListening;
}
