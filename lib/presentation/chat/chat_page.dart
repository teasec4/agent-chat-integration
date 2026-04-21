import 'package:flutter/material.dart';
import 'package:gemma4/presentation/chat/widgets/chat_input.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<String> _messages = [];
  
  void _handleSend(String message) {
    setState(() {
      _messages.add(message);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_right_alt),
          onPressed: () {},
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_messages[index]),
                  );
                },
              ),
            ),
            
            ChatInput(onSend: _handleSend),
          ],
        ),
      ),
    );
  }
}
