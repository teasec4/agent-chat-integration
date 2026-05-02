import 'package:flutter/material.dart';

class SettingsCategory {
  final String id;
  final String title;
  final IconData icon;
  final String description;

  const SettingsCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}

class SettingsSidebar extends StatelessWidget {
  final String? activeCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback? onClose;

  static const categories = [
    SettingsCategory(
      id: 'general',
      title: 'General',
      icon: Icons.tune_rounded,
      description: 'Appearance, language, defaults',
    ),
    SettingsCategory(
      id: 'model',
      title: 'Model',
      icon: Icons.smart_toy_outlined,
      description: 'AI model, endpoint, parameters',
    ),
    SettingsCategory(
      id: 'about',
      title: 'About',
      icon: Icons.info_outline_rounded,
      description: 'Version, licenses, credits',
    ),
  ];

  const SettingsSidebar({
    super.key,
    this.activeCategory,
    required this.onCategorySelected,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.settings_outlined, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (onClose != null)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Back to chats',
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Category list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              children: categories.map((cat) {
                final isActive = cat.id == activeCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Material(
                    color: isActive
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        cat.icon,
                        size: 20,
                        color: isActive ? theme.colorScheme.primary : null,
                      ),
                      title: Text(
                        cat.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      subtitle: Text(
                        cat.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () => onCategorySelected(cat.id),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
