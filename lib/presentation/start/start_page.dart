import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartPage extends StatelessWidget {
  StartPage({super.key});

  final List<ChatItem> _chatList = [
    ChatItem('Chat 1'),
    ChatItem('Chat 2'),
    ChatItem('Chat 3'),
    ChatItem('Chat 4'),
    ChatItem('Chat 5'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List of Chats')),
      body: Container(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: _chatList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_chatList[index].title),
              onTap: () {
                context.go('/chat/${_chatList[index].title}');
              },
            );
          },
        ),
      ),
    );
  }
}

class ChatItem {
  final String title;
  ChatItem(this.title);
}
