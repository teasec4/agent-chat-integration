import 'package:flutter/material.dart';
import 'package:gemma4/presentation/chat/widgets/chat_bubble.dart';
import 'package:gemma4/presentation/chat/widgets/chat_input.dart';
import 'package:gemma4/presentation/view_models/chat_view_model.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final int chatId;
  final VoidCallback? onOpenChatList;

  const ChatPage({
    super.key,
    required this.chatId,
    this.onOpenChatList,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadChat(widget.chatId);
    });
  }

  @override
  void didUpdateWidget(ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId) {
      _previousMessageCount = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatViewModel>().loadChat(widget.chatId);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = context.watch<ChatViewModel>();

    // Scroll to bottom when new messages arrive or during streaming
    final count = chatViewModel.conversationHistory.length;
    if (count > _previousMessageCount || (chatViewModel.isLoading && count > 0)) {
      _previousMessageCount = count;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              if (chatViewModel.isLoading && chatViewModel.conversationHistory.isEmpty)
                const LinearProgressIndicator(),
              if (chatViewModel.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Text(
                    chatViewModel.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              Expanded(
                child: chatViewModel.conversationHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Start a conversation',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Send a message to begin',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        itemCount: chatViewModel.conversationHistory.length,
                        itemBuilder: (context, index) {
                          final msg = chatViewModel.conversationHistory[index];
                          final isFirstInGroup = index == 0 ||
                              chatViewModel.conversationHistory[index - 1].role.name !=
                                  msg.role.name;

                          return Padding(
                            padding: EdgeInsets.only(
                              top: isFirstInGroup ? 8 : 3,
                            ),
                            child: ChatBubble(
                              message: msg,
                              showSender: isFirstInGroup,
                            ),
                          );
                        },
                      ),
              ),
              // Input area with safe area on mobile
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                  child: ChatInput(
                    onSend: (text) {
                      chatViewModel.sendMessage(text);
                      _scrollToBottom();
                    },
                    isLoading: chatViewModel.isLoading,
                    modelName: chatViewModel.model,
                    promptTokens: chatViewModel.promptTokens,
                    completionTokens: chatViewModel.completionTokens,
                    totalTokens: chatViewModel.totalTokens,
                  ),
                ),
              ),
            ],
          ),
          // Floating chat list button (top-left corner)
          if (widget.onOpenChatList != null)
            Positioned(
              top: 8,
              left: 8,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: widget.onOpenChatList,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
