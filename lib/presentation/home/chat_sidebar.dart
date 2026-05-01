import 'package:flutter/material.dart';
import 'package:gemma4/domain/entities/chat.dart';
import 'package:gemma4/presentation/view_models/list_chat_view_model.dart';
import 'package:provider/provider.dart';

class ChatSidebar extends StatefulWidget {
  final int? activeChatId;
  final void Function(Chat chat) onChatSelected;
  final VoidCallback? onNewChat;
  final VoidCallback? onToggleSidebar;

  const ChatSidebar({
    super.key,
    this.activeChatId,
    required this.onChatSelected,
    this.onNewChat,
    this.onToggleSidebar,
  });

  @override
  State<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListChatViewModel>().loadChats();
    });
  }

  Future<void> _createChat() async {
    final vm = context.read<ListChatViewModel>();
    final chat = await vm.createChat();
    if (chat != null && mounted) {
      widget.onChatSelected(chat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ListChatViewModel>();

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Mini AI Chat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (widget.onToggleSidebar != null)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: widget.onToggleSidebar,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Свернуть боковую панель',
                    ),
                  ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    onPressed: _createChat,
                    icon: const Icon(Icons.add, size: 20),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Новый чат',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Chat list
          Expanded(child: _buildChatList(vm)),
        ],
      ),
    );
  }

  Widget _buildChatList(ListChatViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(vm.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => vm.loadChats(),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Нет чатов', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 4),
            Text('Нажмите + чтобы создать', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: vm.chats.length,
      itemBuilder: (context, index) {
        final chat = vm.chats[index];
        final isActive = chat.id == widget.activeChatId;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Material(
            color: isActive ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              dense: true,
              leading: Icon(Icons.message_outlined, size: 18, color: isActive ? Theme.of(context).colorScheme.primary : null),
              title: Text(
                chat.title.isEmpty ? 'Чат #${chat.id}' : chat.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              onTap: () => widget.onChatSelected(chat),
              onLongPress: () => _confirmDelete(context, vm, chat),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, ListChatViewModel vm, Chat chat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить чат?'),
        content: Text('"${chat.title.isEmpty ? 'Чат #${chat.id}' : chat.title}" будет удалён безвозвратно.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Отмена')),
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
