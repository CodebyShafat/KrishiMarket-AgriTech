import 'package:flutter_test/flutter_test.dart';
import 'package:krishimarket/features/ai_assistant/domain/entities/ai_intent.dart';
import 'package:krishimarket/features/ai_assistant/domain/entities/ai_message_entity.dart';
import 'package:krishimarket/features/ai_assistant/domain/entities/ai_action_result.dart';
import 'package:krishimarket/features/ai_assistant/data/repositories/mock_ai_assistant_repository.dart';
import 'package:krishimarket/features/ai_assistant/data/repositories/mock_ai_action_executor.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_product_repository.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_cart_repository.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_order_repository.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_bulk_requirement_repository.dart';
import 'package:krishimarket/features/marketplace/data/repositories/mock_bulk_offer_repository.dart';
import 'package:krishimarket/features/ai_assistant/presentation/providers/ai_assistant_provider.dart';
import 'package:krishimarket/features/ai_assistant/data/repositories/mock_voice_services.dart';

void main() {
  group('AI Assistant Data Layer', () {
    late MockAiAssistantRepository assistantRepo;
    late MockAiActionExecutor actionExecutor;

    setUp(() {
      assistantRepo = MockAiAssistantRepository();

      final productRepo = MockProductRepository();
      final cartRepo = MockCartRepository();
      final orderRepo = MockOrderRepository(productRepo);
      final reqRepo = MockBulkRequirementRepository();
      final offerRepo = MockBulkOfferRepository();

      actionExecutor = MockAiActionExecutor(
        productRepository: productRepo,
        cartRepository: cartRepo,
        orderRepository: orderRepo,
        bulkRequirementRepository: reqRepo,
        bulkOfferRepository: offerRepo,
      );
    });

    test('Mock STT returns intent searchProduct', () async {
      final msg = await assistantRepo.sendMessage(
        'find cheapest wheat',
        'en',
        {},
      );
      expect(msg.intent, AiIntent.searchProduct);
      expect(msg.role, AiMessageRole.assistant);
    });

    test('Action Executor searchProduct executes', () async {
      final result = await actionExecutor.executeAction(
        AiIntent.searchProduct,
        {'query': 'wheat', 'cheapest': true},
      );
      expect(result.status, AiActionResultStatus.success);
      expect(result.data is List, true);
    });

    test('Action Executor missing info flow (createProductListing)', () async {
      final result = await actionExecutor.executeAction(
        AiIntent.createProductListing,
        {'productName': 'Wheat'},
      );
      expect(result.status, AiActionResultStatus.needsMoreInformation);
      expect(result.missingFields?.contains('quantity'), true);
      expect(result.missingFields?.contains('price'), true);
    });

    test(
      'Action Executor requires confirmation (createProductListing)',
      () async {
        final result = await actionExecutor.executeAction(
          AiIntent.createProductListing,
          {'productName': 'Wheat', 'quantity': 100, 'price': 25},
        );
        // Not confirmed yet
        expect(result.status, AiActionResultStatus.needsConfirmation);
      },
    );
  });

  group('AiAssistantProvider', () {
    late AiAssistantProvider provider;

    setUp(() {
      final productRepo = MockProductRepository();
      final actionExecutor = MockAiActionExecutor(
        productRepository: productRepo,
        cartRepository: MockCartRepository(),
        orderRepository: MockOrderRepository(productRepo),
        bulkRequirementRepository: MockBulkRequirementRepository(),
        bulkOfferRepository: MockBulkOfferRepository(),
      );

      provider = AiAssistantProvider(
        assistantRepository: MockAiAssistantRepository(),
        actionExecutor: actionExecutor,
        voiceInputService: MockVoiceInputService(),
        voiceOutputService: MockVoiceOutputService(),
      );
    });

    test('Send message adds to history', () async {
      final future = provider.sendMessage('hello', 'en', 'Customer');
      expect(provider.messages.length, 1);
      expect(provider.messages.first.role, AiMessageRole.user);

      await future;
      expect(provider.messages.length, 2);
      expect(provider.messages.last.role, AiMessageRole.assistant);
    });

    test('Contextual entity extraction handles Hindi correctly', () async {
      await provider.sendMessage(
        'मुझे 1000 किलो आलू चाहिए',
        'hi',
        'Bulk Buyer',
      );
      final lastMsg = provider.messages.last;

      // Should detect Potato and 1000
      expect(lastMsg.intent, AiIntent.createBulkRequirement);
      expect(
        lastMsg.actionResult?.status,
        AiActionResultStatus.needsConfirmation,
      );
      // Because we mocked extraction logic: 'आलू' -> 'Potato', '1000' -> 1000
    });
  });
}
