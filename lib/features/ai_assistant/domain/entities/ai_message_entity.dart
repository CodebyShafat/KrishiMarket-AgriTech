import 'ai_intent.dart';
import 'ai_action_result.dart';

enum AiMessageRole { user, assistant, system }

class AiMessageEntity {
  final String id;
  final AiMessageRole role;
  final String content;
  final DateTime timestamp;
  final String language;
  final AiIntent? intent;
  final bool isLoading;
  final AiActionResult? actionResult;

  AiMessageEntity({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    required this.language,
    this.intent,
    this.isLoading = false,
    this.actionResult,
  });

  AiMessageEntity copyWith({
    String? id,
    AiMessageRole? role,
    String? content,
    DateTime? timestamp,
    String? language,
    AiIntent? intent,
    bool? isLoading,
    AiActionResult? actionResult,
  }) {
    return AiMessageEntity(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      language: language ?? this.language,
      intent: intent ?? this.intent,
      isLoading: isLoading ?? this.isLoading,
      actionResult: actionResult ?? this.actionResult,
    );
  }
}
