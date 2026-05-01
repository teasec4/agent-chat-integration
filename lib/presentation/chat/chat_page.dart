import 'package:flutter/material.dart';
import 'package:gemma4/presentation/chat/widgets/chat_input.dart';
import 'package:gemma4/presentation/view_models/chat_view_model.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final int chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadChat(widget.chatId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = context.watch<ChatViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(chatViewModel.currentChat?.title ?? 'Загрузка...'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            if (chatViewModel.isLoading)
              const LinearProgressIndicator(),
            if (chatViewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  chatViewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: chatViewModel.conversationHistory.isEmpty
                  ? const Center(child: Text('Начните диалог'))
                  : ListView.builder(
                      itemCount: chatViewModel.conversationHistory.length,
                      itemBuilder: (context, index) {
                        final msg = chatViewModel.conversationHistory[index];
                        final isUser = msg.role.name == 'user';
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2, right: 10),
                                child: Icon(
                                  isUser ? Icons.person : Icons.smart_toy,
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isUser ? 'Вы' : 'Gemma',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      msg.content,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            ChatInput(
              onSend: chatViewModel.sendMessage,
              isLoading: chatViewModel.isLoading,
              modelName: chatViewModel.model,
              promptTokens: chatViewModel.promptTokens,
              completionTokens: chatViewModel.completionTokens,
              totalTokens: chatViewModel.totalTokens,
            ),
          ],
        ),
      ),
    );
  }
}
