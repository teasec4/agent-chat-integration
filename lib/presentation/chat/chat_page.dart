import 'package:flutter/material.dart';
import 'package:gemma4/presentation/chat/widgets/chat_input.dart';
import 'package:gemma4/presentation/chat/widgets/token_usage_info.dart';
import 'package:gemma4/presentation/view_models/chat_view_model.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  final String title;
  const ChatPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final _chatViewModel = Provider.of<ChatViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            if (_chatViewModel.isLoading)
              const LinearProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: _chatViewModel.conversationHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_chatViewModel.conversationHistory[index].content),
                  );
                },
              ),
            ),
            TokenUsageInfo(
              promptTokens: _chatViewModel.promptTokens,
              completionTokens: _chatViewModel.completionTokens,
              totalTokens: _chatViewModel.totalTokens,
            ),
            const SizedBox(height: 8),
            ChatInput(onSend: _chatViewModel.sendMessage),
          ],
        ),
      ),
    );
  }
}


