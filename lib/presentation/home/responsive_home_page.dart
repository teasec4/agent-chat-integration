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
  ActiveTab _activeTab = ActiveTab.chat;
  int? _selectedChatId;
  String? _selectedSettingsCategory;
  bool _sidebarVisible = false;

  void _selectChat(Chat chat) {
    setState(() {
      _selectedChatId = chat.id;
      _sidebarVisible = false;
    });
  }

  void _goBackToChatList() {
    setState(() {
      _selectedChatId = null;
    });
  }

  void _toggleSidebar() {
    setState(() => _sidebarVisible = !_sidebarVisible);
  }

  void _selectSettingsCategory(String id) {
    setState(() {
      _selectedSettingsCategory = id;
      _sidebarVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 768) return _buildWideLayout();
        if (width >= 480) return _buildMidLayout();
        return _buildNarrowLayout();
      },
    );
  }

  // ──────────────────────────────────────────────
  // Wide (>=768): 3-column desktop
  // ──────────────────────────────────────────────
  Widget _buildWideLayout() {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            LeftTabBar(
              activeTab: _activeTab,
              onTabChanged: _switchTabWide,
            ),
            if (_sidebarVisible)
              SizedBox(width: 280, child: _buildSidebar())
            else
              _buildCollapsedBar(),
            _buildVerticalDivider(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // On wide, switching tabs resets the sidebar visible state
  void _switchTabWide(ActiveTab tab) {
    setState(() {
      _activeTab = tab;
      _sidebarVisible = true;
    });
  }

  // ──────────────────────────────────────────────
  // Mid (480-768): tab bar + sidebar as overlay
  // ──────────────────────────────────────────────
  Widget _buildMidLayout() {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                LeftTabBar(
                  activeTab: _activeTab,
                  onTabChanged: _switchTabMid,
                  compact: true,
                ),
                Expanded(child: _buildContent()),
              ],
            ),
            // Scrim behind overlay sidebar
            if (_sidebarVisible)
              GestureDetector(
                onTap: () => setState(() => _sidebarVisible = false),
                child: Container(color: Colors.black38),
              ),
            // Sidebar overlay — slides in from left after tab bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: _sidebarVisible ? 40 : -280,
              top: 0,
              bottom: 0,
              width: 280,
              child: Material(
                elevation: 8,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: _buildSidebar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // On mid, tapping the active tab toggles the sidebar overlay
  void _switchTabMid(ActiveTab tab) {
    setState(() {
      if (_activeTab == tab) {
        _sidebarVisible = !_sidebarVisible;
      } else {
        _activeTab = tab;
        _selectedSettingsCategory = null;
        _sidebarVisible = true;
      }
    });
  }

  // ──────────────────────────────────────────────
  // Narrow (<480): bottom nav + full-screen panels
  // ──────────────────────────────────────────────
  Widget _buildNarrowLayout() {
    // When a chat is selected, show full-screen chat page with back button
    if (_selectedChatId != null) {
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

    return Scaffold(
      body: _buildNarrowPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _activeTab == ActiveTab.chat ? 0 : 1,
        onDestinationSelected: (index) {
          setState(() {
            _activeTab = index == 0 ? ActiveTab.chat : ActiveTab.settings;
            _selectedSettingsCategory = null;
          });
        },
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowPage() {
    switch (_activeTab) {
      case ActiveTab.chat:
        return ChatSidebar(
          activeChatId: _selectedChatId,
          onChatSelected: _selectChat,
        );
      case ActiveTab.settings:
        return SettingsSidebar(
          activeCategory: _selectedSettingsCategory,
          onCategorySelected: (id) {
            _selectSettingsCategory(id);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: Text(_categoryTitle(id)),
                  ),
                  body: SettingsPage(category: id),
                ),
              ),
            );
          },
        );
    }
  }

  // ──────────────────────────────────────────────
  // Shared widgets
  // ──────────────────────────────────────────────

  Widget _buildSidebar() {
    switch (_activeTab) {
      case ActiveTab.chat:
        return ChatSidebar(
          activeChatId: _selectedChatId,
          onChatSelected: _selectChat,
        );
      case ActiveTab.settings:
        return SettingsSidebar(
          activeCategory: _selectedSettingsCategory,
          onCategorySelected: _selectSettingsCategory,
          onClose: () => _switchTabMid(ActiveTab.chat),
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
            onOpenChatList: () {
              setState(() => _sidebarVisible = true);
            },
          );
        }
        return _buildEmptyState(
          icon: Icons.chat_bubble_outline_rounded,
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

  String _categoryTitle(String id) {
    const titles = {'general': 'General', 'model': 'Model', 'about': 'About'};
    return titles[id] ?? 'Settings';
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
