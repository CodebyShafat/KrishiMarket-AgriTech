import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:krishimarket/core/theme/app_theme.dart';
import 'package:krishimarket/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_router.dart';
import 'core/utils/language_provider.dart';
import 'core/utils/theme_provider.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/repositories/api_auth_repository.dart';
import 'core/network/api_client.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/marketplace/data/repositories/mock_product_repository.dart';
import 'features/marketplace/data/repositories/local_cart_repository.dart';
import 'features/marketplace/data/repositories/mock_order_repository.dart';
import 'features/marketplace/presentation/providers/product_provider.dart';
import 'features/marketplace/presentation/providers/marketplace_provider.dart';
import 'features/marketplace/presentation/providers/cart_provider.dart';
import 'features/marketplace/presentation/providers/order_provider.dart';
import 'features/marketplace/data/repositories/mock_bulk_requirement_repository.dart';
import 'features/marketplace/data/repositories/mock_bulk_offer_repository.dart';
import 'features/marketplace/presentation/providers/bulk_requirement_provider.dart';
import 'features/marketplace/presentation/providers/bulk_offer_provider.dart';

import 'features/ai_assistant/domain/repositories/ai_assistant_repository.dart';
import 'features/ai_assistant/domain/repositories/voice_input_service.dart';
import 'features/ai_assistant/data/repositories/mock_ai_action_executor.dart';
import 'features/ai_assistant/data/repositories/mock_ai_assistant_repository.dart';
import 'features/ai_assistant/data/repositories/api_ai_assistant_repository.dart';
import 'features/ai_assistant/data/repositories/speech_to_text_service.dart';
import 'features/ai_assistant/data/repositories/mock_voice_services.dart';
import 'features/ai_assistant/presentation/providers/ai_assistant_provider.dart';

import 'features/marketplace/data/repositories/api_product_repository.dart';
import 'features/marketplace/data/repositories/api_bulk_requirement_repository.dart';
import 'features/marketplace/data/repositories/api_bulk_offer_repository.dart';
import 'features/marketplace/data/repositories/api_order_repository.dart';
import 'features/marketplace/domain/repositories/product_repository.dart';
import 'features/marketplace/domain/repositories/order_repository.dart';
import 'features/marketplace/domain/repositories/bulk_requirement_repository.dart';
import 'features/marketplace/domain/repositories/bulk_offer_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageProvider = LanguageProvider();
  final themeProvider = ThemeProvider();

  // If USE_API is true, we connect to FastAPI backend. Otherwise we use mocks.
  const useApiBackend = bool.fromEnvironment(
    'USE_API',
    defaultValue: true,
  );

  late final AuthRepository authRepository;
  late final ProductRepository productRepository;
  late final OrderRepository orderRepository;
  late final BulkRequirementRepository bulkReqRepository;
  late final BulkOfferRepository bulkOfferRepository;
  late final AiAssistantRepository aiAssistantRepository;
  late final VoiceInputService voiceInputService;

  final cartRepository = LocalCartRepository(); // Cart is strictly local
  final apiClient = ApiClient();

  if (useApiBackend) {
    authRepository = ApiAuthRepository(apiClient: apiClient);
    productRepository = ApiProductRepository(apiClient: apiClient);
    bulkReqRepository = ApiBulkRequirementRepository(apiClient: apiClient);
    bulkOfferRepository = ApiBulkOfferRepository(apiClient: apiClient);
    orderRepository = ApiOrderRepository(apiClient: apiClient);
    aiAssistantRepository = ApiAiAssistantRepository(client: http.Client(), apiClient: apiClient);
    voiceInputService = SpeechToTextService();
  } else {
    authRepository = AuthRepositoryImpl(
      remoteDataSource: MockAuthRemoteDataSourceImpl(),
      localDataSource: AuthLocalDataSourceImpl(),
    );
    productRepository = MockProductRepository();
    orderRepository = MockOrderRepository(
      productRepository as MockProductRepository,
    );
    bulkReqRepository = MockBulkRequirementRepository();
    bulkOfferRepository = MockBulkOfferRepository();
    aiAssistantRepository = MockAiAssistantRepository();
    voiceInputService = MockVoiceInputService();
  }

  final aiActionExecutor = MockAiActionExecutor(
    productRepository: productRepository,
    cartRepository: cartRepository,
    orderRepository: orderRepository,
    bulkRequirementRepository: bulkReqRepository,
    bulkOfferRepository: bulkOfferRepository,
  );

  final voiceOutputService = MockVoiceOutputService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketplaceProvider(productRepository),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider(cartRepository)),
        ChangeNotifierProvider(create: (_) => OrderProvider(orderRepository)),
        ChangeNotifierProvider(
          create: (_) => BulkRequirementProvider(bulkReqRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              BulkOfferProvider(bulkOfferRepository, bulkReqRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AiAssistantProvider(
            assistantRepository: aiAssistantRepository,
            actionExecutor: aiActionExecutor,
            voiceInputService: voiceInputService,
            voiceOutputService: voiceOutputService,
          ),
        ),
      ],
      child: AppThemeNotifier(
        notifier: themeProvider,
        child: AppLanguage(
          notifier: languageProvider,
          child: const KrishiMarketApp(),
        ),
      ),
    ),
  );
}

class KrishiMarketApp extends StatelessWidget {
  const KrishiMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = AppLanguage.of(context);
    final themeProvider = AppThemeNotifier.of(context);

    return MaterialApp(
      title: 'KrishiMarket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: languageProvider.currentLocale,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
