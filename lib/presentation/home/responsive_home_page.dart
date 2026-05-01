import 'package:flutter/material.dart';
import 'package:gemma4/presentation/home/chat_sidebar.dart';
import 'package:gemma4/presentation/chat/chat_page.dart';
import 'package:gemma4/domain/entities/chat.dart';

class ResponsiveHomePage extends StatefulWidget {
  const ResponsiveHomePage({super.key});

  @override
  State<ResponsiveHomePage> createState() => _ResponsiveHomePageState();
}

class _ResponsiveHomePageState extends State<ResponsiveHomePage> {
  int? _selectedChatId;
  bool _sidebarVisible = true;

  @override
  void initState() {
    super.initState();
  }

  bool get _isDesktop {
    final width = MediaQuery.of(context).size.width;
    return width >= 600;
  }

  void _selectChat(Chat chat) {
    setState(() {
      _selectedChatId = chat.id;
    });
  }

  void _goBackToChatList() {
    setState(() {
      _selectedChatId = null;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarVisible = !_sidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDesktop) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (_sidebarVisible)
              SizedBox(
                width: 280,
                child: ChatSidebar(
                  activeChatId: _selectedChatId,
                  onChatSelected: _selectChat,
                  onToggleSidebar: _toggleSidebar,
                ),
              )
            else
              _buildCollapsedBar(),
            _buildVerticalDivider(),
            Expanded(
              child: _selectedChatId != null
                  ? ChatPage(
                      chatId: _selectedChatId!,
                      key: ValueKey(_selectedChatId),
                    )
                  : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedBar() {
    return SizedBox(
      width: 24,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Column(
          children: [
            const SizedBox(height: 12),
            IconButton(
              onPressed: _toggleSidebar,
              icon: const Icon(Icons.chevron_right, size: 20),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tooltip: 'Expand sidebar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return const VerticalDivider(width: 1, thickness: 1);
  }

  Widget _buildMobileLayout() {
    if (_selectedChatId == null) {
      return Scaffold(
        body: ChatSidebar(
          activeChatId: _selectedChatId,
          onChatSelected: _selectChat,
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBackToChatList();
      },
      child: ChatPage(
        chatId: _selectedChatId!,
        key: ValueKey(_selectedChatId),
        showBackButton: true,
        onBack: _goBackToChatList,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Select a chat',
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'or create a new one',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
