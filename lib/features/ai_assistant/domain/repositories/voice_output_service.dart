abstract class VoiceOutputService {
  Future<void> speak(String text, String languageCode);
  Future<void> stop();
}
