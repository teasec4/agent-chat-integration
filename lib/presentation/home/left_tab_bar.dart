import 'package:flutter/material.dart';

enum ActiveTab { chat, settings }

class LeftTabBar extends StatelessWidget {
  final ActiveTab activeTab;
  final ValueChanged<ActiveTab> onTabChanged;

  const LeftTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _TabIcon(
            icon: Icons.chat_bubble_outline_rounded,
            isActive: activeTab == ActiveTab.chat,
            onTap: () => onTabChanged(ActiveTab.chat),
            tooltip: 'Chats',
          ),
          const Spacer(),
          _TabIcon(
            icon: Icons.settings_outlined,
            isActive: activeTab == ActiveTab.settings,
            onTap: () => onTabChanged(ActiveTab.settings),
            tooltip: 'Settings',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _TabIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      margin: const EdgeInsets.only(left: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}
