import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_assistant_provider.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_intent.dart';
import '../../domain/entities/ai_action_result.dart';

import 'package:krishimarket/l10n/app_localizations.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import 'ai_result_cards.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final auth = context.read<AuthProvider>().currentUser;
    final lang = Localizations.localeOf(context).languageCode;

    context.read<AiAssistantProvider>().sendMessage(
      _controller.text,
      lang,
      auth?.role ?? 'Customer',
    );
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiAssistantProvider>();
    final auth = context.watch<AuthProvider>().currentUser;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiAssistant),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.clearConversation,
            onPressed: () {
              provider.clearConversation();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (provider.messages.isEmpty)
            Expanded(
              child: _buildEmptyState(context, l10n, auth?.role ?? 'Customer'),
            ),
          if (provider.messages.isNotEmpty)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: provider.messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(provider.messages[index], l10n);
                },
              ),
            ),
          if (provider.isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(context, l10n, provider, auth?.role ?? 'Customer'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    String role,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.askMeAnything,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _getQuickActions(role, l10n)
                .map(
                  (action) => ActionChip(
                    label: Text(action),
                    onPressed: () {
                      _controller.text = action;
                      _sendMessage();
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  List<String> _getQuickActions(String role, AppLocalizations l10n) {
    if (role == 'Farmer') {
      return [l10n.myProducts, l10n.createListing, l10n.findBulkRequirements];
    }
    if (role == 'Bulk Buyer') {
      return [l10n.createRequirement, l10n.myRequirements, l10n.viewOffers];
    }
    return [l10n.findProducts, l10n.myCart, l10n.myOrders];
  }

  String _translateIfKey(String text, AppLocalizations l10n) {
    switch (text) {
      case 'actionNeedsConfirmation':
        return l10n.actionNeedsConfirmation;
      case 'actionNeedsMoreInformation':
        return l10n.actionNeedsMoreInformation;
      case 'actionSuccess':
        return l10n.actionSuccess;
      case 'actionError':
        return l10n.actionError;

      // New AI keys
      case 'ai_ask_quantity':
        return l10n.ai_ask_quantity;
      case 'ai_ask_price':
        return l10n.ai_ask_price;
      case 'ai_ask_crop':
        return l10n.ai_ask_crop;
      case 'ai_confirm_listing':
        return l10n.ai_confirm_listing;
      case 'ai_confirm_order':
        return l10n.ai_confirm_order;
      case 'ai_confirm_requirement':
        return l10n.ai_confirm_requirement;
      case 'ai_confirm_offer':
        return l10n.ai_confirm_offer;
      case 'ai_greet':
        return l10n.ai_greet;
      case 'ai_network_error':
        return l10n.ai_network_error;
      case 'ai_service_error':
        return l10n.ai_service_error;
      case 'ai_parse_error':
        return l10n.ai_parse_error;
      case 'ai_fallback_response':
        return l10n.ai_fallback_response;
      case 'ai_action_success':
        return l10n.ai_action_success;
      case 'ai_action_error':
        return l10n.ai_action_error;
      case 'ai_confirm_action':
        return l10n.ai_confirm_action;

      default:
        return text;
    }
  }

  Widget _buildMessageBubble(AiMessageEntity msg, AppLocalizations l10n) {
    final isUser = msg.role == AiMessageRole.user;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                bottomLeft: !isUser ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Text(
              _translateIfKey(msg.content, l10n),
              style: TextStyle(color: isUser ? Colors.white : Colors.black87),
            ),
          ),
          if (msg.requiresConfirmation)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<AiAssistantProvider>().confirmAction(msg);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      l10n.confirm,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // Just send a message cancelling it
                      final lang = Localizations.localeOf(context).languageCode;
                      final auth = context.read<AuthProvider>().currentUser;
                      context.read<AiAssistantProvider>().sendMessage(
                        'cancel',
                        lang,
                        auth?.role ?? 'Customer',
                      );
                    },
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
            ),
          if (msg.actionResult != null && msg.actionResult!.data != null)
            _buildResultCard(msg.actionResult!),
        ],
      ),
    );
  }

  Widget _buildResultCard(AiActionResult result) {
    if (result.intent == AiIntent.searchProduct && result.data is List) {
      final products = result.data as List;
      return Column(
        children: products.map((p) => ProductResultCard(product: p)).toList(),
      );
    }
    return const SizedBox();
  }

  Widget _buildVoiceStateOverlay(
    BuildContext context,
    AppLocalizations l10n,
    AiAssistantProvider provider,
    String role,
    String lang,
  ) {
    if (provider.voiceState == AiVoiceState.idle) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (provider.voiceState == AiVoiceState.listening || provider.voiceState == AiVoiceState.transcribing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(
                    "\${l10n.listening}...",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(provider.currentTranscript, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: provider.cancelVoiceInput,
                    child: Text(l10n.cancel),
                  ),
                  ElevatedButton(
                    onPressed: provider.stopVoiceInput,
                    child: const Text("Stop & Review"),
                  ),
                ],
              )
            ],
            if (provider.voiceState == AiVoiceState.transcriptReview) ...[
              Text("Review Transcript", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: provider.currentTranscript)
                  ..selection = TextSelection.collapsed(offset: provider.currentTranscript.length),
                onChanged: provider.setTranscript,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: provider.cancelVoiceInput,
                    child: Text(l10n.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final txt = provider.currentTranscript;
                      provider.cancelVoiceInput(); // resets state
                      provider.sendMessage(txt, lang, role);
                    },
                    child: const Icon(Icons.send),
                  ),
                ],
              )
            ],
            if (provider.voiceState == AiVoiceState.error) ...[
              Text(
                _translateIfKey(provider.errorMessage, l10n),
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: provider.cancelVoiceInput,
                child: Text(l10n.cancel),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    AppLocalizations l10n,
    AiAssistantProvider provider,
    String role,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      children: [
        _buildVoiceStateOverlay(context, l10n, provider, role, lang),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  provider.voiceState == AiVoiceState.listening ? Icons.mic_off : Icons.mic,
                  color: provider.voiceState == AiVoiceState.listening ? Colors.red : null,
                ),
                onPressed: () {
                  if (provider.voiceState == AiVoiceState.listening) {
                    provider.stopVoiceInput();
                  } else {
                    provider.startVoiceInput(lang, role);
                  }
                },
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: l10n.askMeAnything,
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                color: Theme.of(context).primaryColor,
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
