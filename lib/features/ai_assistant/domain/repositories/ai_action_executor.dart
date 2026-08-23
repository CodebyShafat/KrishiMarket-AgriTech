import '../entities/ai_action_result.dart';
import '../entities/ai_intent.dart';

abstract class AiActionExecutor {
  Future<AiActionResult> executeAction(
    AiIntent intent,
    Map<String, dynamic> parameters,
  );
}
