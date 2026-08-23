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
    final l10n = AppLocalizations.of(context)!;
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
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AiAssistantProvider>();
    final auth = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiAssistant ?? 'AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.clearConversation ?? 'Clear Conversation',
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
                  return _buildMessageBubble(provider.messages[index]);
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
            l10n.askMeAnything ?? 'Ask me anything...',
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
    if (role == 'Farmer')
      return [
        l10n.myProducts ?? 'My Products',
        l10n.createListing ?? 'Create Listing',
        l10n.findBulkRequirements ?? 'Find Bulk Requirements',
      ];
    if (role == 'Bulk Buyer')
      return [
        l10n.createRequirement ?? 'Create Requirement',
        l10n.myRequirements ?? 'My Requirements',
        l10n.viewOffers ?? 'View Offers',
      ];
    return [
      l10n.findProducts ?? 'Find Products',
      l10n.myCart ?? 'My Cart',
      l10n.myOrders ?? 'My Orders',
    ];
  }

  Widget _buildMessageBubble(AiMessageEntity msg) {
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
              msg.content,
              style: TextStyle(color: isUser ? Colors.white : Colors.black87),
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

  Widget _buildInputArea(
    BuildContext context,
    AppLocalizations l10n,
    AiAssistantProvider provider,
    String role,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              provider.isListening ? Icons.mic : Icons.mic_none,
              color: provider.isListening ? Colors.red : null,
            ),
            onPressed: () {
              if (provider.isListening) {
                provider.stopVoiceInput();
              } else {
                provider.startVoiceInput(
                  Localizations.localeOf(context).languageCode,
                  role,
                );
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: provider.isListening
                    ? (l10n.listening ?? 'Listening...')
                    : (l10n.askMeAnything ?? 'Ask me anything...'),
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
    );
  }
}
