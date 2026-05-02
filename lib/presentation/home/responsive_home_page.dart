import 'package:flutter/material.dart';
import 'package:gemma4/presentation/home/chat_sidebar.dart';
import 'package:gemma4/presentation/home/left_tab_bar.dart';
import 'package:gemma4/presentation/chat/chat_page.dart';
import 'package:gemma4/presentation/settings/settings_page.dart';
import 'package:gemma4/presentation/settings/settings_sidebar.dart';
import 'package:gemma4/domain/entities/chat.dart';

class ResponsiveHomePage extends StatefulWidget {
  const ResponsiveHomePage({super.key});

  @override
  State<ResponsiveHomePage> createState() => _ResponsiveHomePageState();
}

class _ResponsiveHomePageState extends State<ResponsiveHomePage> {
  int? _selectedChatId;
  bool _sidebarVisible = true;
  ActiveTab _activeTab = ActiveTab.chat;
  String? _selectedSettingsCategory;

  bool get _isDesktop {
    final width = MediaQuery.of(context).size.width;
    return width >= 600;
  }

  void _selectChat(Chat chat) {
    setState(() {
      _selectedChatId = chat.id;
      _activeTab = ActiveTab.chat;
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

  void _switchTab(ActiveTab tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  void _selectSettingsCategory(String id) {
    setState(() {
      _selectedSettingsCategory = id;
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
            // Thin tab bar — always visible
            LeftTabBar(
              activeTab: _activeTab,
              onTabChanged: _switchTab,
            ),
            // Sidebar panel or collapsed bar
            if (_sidebarVisible)
              SizedBox(width: 280, child: _buildSidebar())
            else
              _buildCollapsedBar(),
            _buildVerticalDivider(),
            // Main content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    switch (_activeTab) {
      case ActiveTab.chat:
        return ChatSidebar(
          activeChatId: _selectedChatId,
          onChatSelected: _selectChat,
          onToggleSidebar: _toggleSidebar,
        );
      case ActiveTab.settings:
        return SettingsSidebar(
          activeCategory: _selectedSettingsCategory,
          onCategorySelected: _selectSettingsCategory,
          onClose: () => _switchTab(ActiveTab.chat),
        );
    }
  }

  Widget _buildContent() {
    switch (_activeTab) {
      case ActiveTab.chat:
        if (_selectedChatId != null) {
          return ChatPage(
            chatId: _selectedChatId!,
            key: ValueKey(_selectedChatId),
          );
        }
        return _buildEmptyState(
          icon: Icons.chat_bubble_outline,
          title: 'Select a chat',
          subtitle: 'or create a new one',
        );
      case ActiveTab.settings:
        if (_selectedSettingsCategory != null) {
          return SettingsPage(
            category: _selectedSettingsCategory!,
            key: ValueKey(_selectedSettingsCategory),
          );
        }
        return _buildEmptyState(
          icon: Icons.settings_outlined,
          title: 'Select a category',
          subtitle: 'Choose from the sidebar',
        );
    }
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
      // Mobile: show full-screen sidebar with settings accessible from app bar
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mini AI Chat'),
          actions: [
            IconButton(
              icon: Icon(
                _activeTab == ActiveTab.settings
                    ? Icons.chat_bubble_outline_rounded
                    : Icons.settings_outlined,
              ),
              tooltip: _activeTab == ActiveTab.settings ? 'Chats' : 'Settings',
              onPressed: () {
                setState(() {
                  _activeTab = _activeTab == ActiveTab.chat
                      ? ActiveTab.settings
                      : ActiveTab.chat;
                });
              },
            ),
          ],
        ),
        body: _activeTab == ActiveTab.chat
            ? ChatSidebar(
                activeChatId: _selectedChatId,
                onChatSelected: _selectChat,
              )
            : SettingsSidebar(
                activeCategory: _selectedSettingsCategory,
                onCategorySelected: (id) {
                  _selectSettingsCategory(id);
                  // On mobile, navigate to full-screen settings page
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: Text(_categoryTitle(id))),
                        body: SettingsPage(category: id),
                      ),
                    ),
                  );
                },
              ),
      );
    }

    // Mobile: full-screen chat page with back button
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBackToChatList();
      },
      child: ChatPage(
        chatId: _selectedChatId!,
        key: ValueKey(_selectedChatId),
        onOpenChatList: _goBackToChatList,
      ),
    );
  }

  String _categoryTitle(String id) {
    const titles = {'general': 'General', 'model': 'Model', 'about': 'About'};
    return titles[id] ?? 'Settings';
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
