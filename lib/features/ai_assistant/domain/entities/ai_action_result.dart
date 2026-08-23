import 'ai_intent.dart';

enum AiActionResultStatus {
  success,
  needsConfirmation,
  needsMoreInformation,
  error,
}

class AiActionResult {
  final AiActionResultStatus status;
  final String message;
  final AiIntent intent;
  final dynamic data;
  final List<String>? missingFields;

  AiActionResult({
    required this.status,
    required this.message,
    required this.intent,
    this.data,
    this.missingFields,
  });
}
