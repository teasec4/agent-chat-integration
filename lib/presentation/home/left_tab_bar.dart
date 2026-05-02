import 'package:flutter/material.dart';

enum ActiveTab { chat, settings }

class LeftTabBar extends StatelessWidget {
  final ActiveTab activeTab;
  final ValueChanged<ActiveTab> onTabChanged;
  final bool compact;

  const LeftTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    this.compact = false,
  });

  double get _width => compact ? 40 : 48;
  double get _iconSize => compact ? 20 : 22;
  double get _hitSize => compact ? 32 : 36;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: _width,
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
            iconSize: _iconSize,
            hitSize: _hitSize,
            compact: compact,
          ),
          const Spacer(),
          _TabIcon(
            icon: Icons.settings_outlined,
            isActive: activeTab == ActiveTab.settings,
            onTap: () => onTabChanged(ActiveTab.settings),
            tooltip: 'Settings',
            iconSize: _iconSize,
            hitSize: _hitSize,
            compact: compact,
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
  final double iconSize;
  final double hitSize;
  final bool compact;

  const _TabIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
    required this.iconSize,
    required this.hitSize,
    required this.compact,
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
      margin: EdgeInsets.only(left: compact ? 44 : 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: hitSize,
            height: hitSize,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: iconSize, color: color),
          ),
        ),
      ),
    );
  }
}
