import 'package:flutter/material.dart';
import 'package:gemma4/presentation/settings/widgets/general_section.dart';
import 'package:gemma4/presentation/settings/widgets/model_section.dart';

class SettingsPage extends StatelessWidget {
  final String category;

  const SettingsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case 'general':
        return const GeneralSection();
      case 'model':
        return const ModelSection();
      default:
        return _buildEmpty(context);
    }
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings_outlined, size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('Unknown category',
              style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
