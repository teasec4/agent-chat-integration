import 'package:flutter/material.dart';
import 'package:gemma4/domain/entities/chat.dart';
import 'package:gemma4/presentation/view_models/list_chat_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListChatViewModel>().loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listVm = context.watch<ListChatViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini AI Chat'),
      ),
      body: _buildBody(listVm),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final navigator = GoRouter.of(context);
          final chat = await context
              .read<ListChatViewModel>()
              .createChat();
          if (chat != null && mounted) {
            navigator.go('/chat/${chat.id}');
          }
        },
        tooltip: 'Новый чат',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ListChatViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<ListChatViewModel>().loadChats(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (vm.chats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Нет чатов',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Нажмите + чтобы создать новый',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: vm.chats.length,
      itemBuilder: (context, index) {
        final chat = vm.chats[index];
        return ListTile(
          leading: const Icon(Icons.chat),
          title: Text(
            chat.title.isEmpty ? 'Чат #${chat.id}' : chat.title,
          ),
          subtitle: Text('ID: ${chat.id}'),
          onTap: () {
            context.go('/chat/${chat.id}');
          },
          onLongPress: () => _confirmDelete(context, vm, chat),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ListChatViewModel vm,
    Chat chat,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить чат?'),
        content: Text('Чат "${chat.title.isEmpty ? 'Чат #${chat.id}' : chat.title}" будет удалён безвозвратно.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await vm.deleteChat(chat.id);
    }
  }
}
