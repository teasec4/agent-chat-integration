import 'package:flutter/material.dart';

// --- Model data struct (local state, no persistence) ---
class _CustomModel {
  final String id;
  String name;
  String baseUrl;
  String modelName;
  int maxTokens = 4096;
  double temperature = 0.7;

  _CustomModel({
    required this.id,
    this.name = '',
    this.baseUrl = 'http://localhost:1234/v1',
    this.modelName = 'google/gemma-4-e4b',
  });
}

class SettingsPage extends StatefulWidget {
  final String category;

  const SettingsPage({super.key, required this.category});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // --- General state ---
  bool _darkMode = false;
  bool _autoTitle = true;
  bool _streamResponses = true;
  String _language = 'System';

  // --- Model state ---
  final _baseUrlController = TextEditingController(text: 'http://localhost:1234/v1');
  final _modelNameController = TextEditingController(text: 'google/gemma-4-e4b');
  final _newBaseUrlController = TextEditingController();
  final _newModelNameController = TextEditingController();
  final _newCustomNameController = TextEditingController();
  double _temperature = 0.7;
  int _maxTokens = 4096;
  final List<_CustomModel> _customModels = [];

  @override
  void dispose() {
    _baseUrlController.dispose();
    _modelNameController.dispose();
    _newBaseUrlController.dispose();
    _newModelNameController.dispose();
    _newCustomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.category) {
      case 'general':
        return _buildGeneralSettings();
      case 'model':
        return _buildModelSettings();
      case 'about':
        return _buildAboutPage();
      default:
        return _buildEmpty();
    }
  }

  // ===================================================================
  // GENERAL SETTINGS
  // ===================================================================
  Widget _buildGeneralSettings() {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(theme, 'Appearance'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                  secondary: Icon(
                    _darkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Language'),
                  subtitle: Text(_language),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _pickLanguage(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(theme, 'Chat Defaults'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-generate titles'),
                  subtitle: const Text('Create chat title from first message'),
                  value: _autoTitle,
                  onChanged: (v) => setState(() => _autoTitle = v),
                  secondary: const Icon(Icons.auto_awesome_outlined),
                ),
                const Divider(height: 1, indent: 72),
                SwitchListTile(
                  title: const Text('Stream responses'),
                  subtitle: const Text('Show text as it arrives'),
                  value: _streamResponses,
                  onChanged: (v) => setState(() => _streamResponses = v),
                  secondary: const Icon(Icons.stream_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickLanguage() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['System', 'English', 'Русский', '中文']
              .map((lang) => ListTile(
                    title: Text(lang),
                    trailing: _language == lang
                        ? const Icon(Icons.check, size: 18)
                        : null,
                    onTap: () {
                      setState(() => _language = lang);
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ===================================================================
  // MODEL SETTINGS
  // ===================================================================
  Widget _buildModelSettings() {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Active Endpoint ---
          _buildSectionHeader(theme, 'Endpoint'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'http://localhost:1234/v1',
                  prefixIcon: Icon(Icons.link_outlined, size: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                  helperText: 'OpenAI-compatible API endpoint',
                ),
                style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Active Model ---
          _buildSectionHeader(theme, 'Model'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _modelNameController,
                    decoration: const InputDecoration(
                      labelText: 'Model Name',
                      hintText: 'google/gemma-4-e4b',
                      prefixIcon: Icon(Icons.smart_toy_outlined, size: 20),
                      border: OutlineInputBorder(),
                      isDense: true,
                      helperText: 'Model ID from the API',
                    ),
                    style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Parameters ---
          _buildSectionHeader(theme, 'Parameters'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Temperature slider
                  Row(
                    children: [
                      const Icon(Icons.thermostat_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text('Temperature', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _temperature.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    label: _temperature.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _temperature = v),
                  ),
                  const SizedBox(height: 8),

                  // Max tokens
                  Row(
                    children: [
                      const Icon(Icons.format_list_numbered_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text('Max Tokens', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                      const Spacer(),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: TextEditingController(text: _maxTokens.toString()),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onChanged: (v) {
                            final parsed = int.tryParse(v);
                            if (parsed != null && parsed > 0) {
                              setState(() => _maxTokens = parsed);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Custom Models ---
          _buildSectionHeader(theme, 'Saved Models'),
          const SizedBox(height: 4),
          Text(
            'Add custom model configurations to quickly switch between endpoints.',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),

          // List of saved models
          ..._customModels.map((model) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildCustomModelCard(model),
              )),

          // Add new model button
          OutlinedButton.icon(
            onPressed: _showAddModelDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Model'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),

          const SizedBox(height: 32),

          // Test connection button
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Test Connection'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCustomModelCard(_CustomModel model) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.smart_toy_outlined, size: 16, color: theme.colorScheme.primary),
        ),
        title: Text(
          model.name.isNotEmpty ? model.name : model.modelName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          model.modelName,
          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant, fontFamily: 'monospace'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              tooltip: 'Use this model',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                _baseUrlController.text = model.baseUrl;
                _modelNameController.text = model.modelName;
                _temperature = model.temperature;
                _maxTokens = model.maxTokens;
                setState(() {});
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
              tooltip: 'Remove',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                setState(() => _customModels.remove(model));
              },
            ),
          ],
        ),
        onTap: () => _showEditModelDialog(model),
      ),
    );
  }

  void _showAddModelDialog() {
    _newCustomNameController.clear();
    _newBaseUrlController.text = 'http://localhost:1234/v1';
    _newModelNameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Model'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newCustomNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'e.g. Local LLM',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newBaseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'http://localhost:1234/v1',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.link_outlined, size: 20),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newModelNameController,
                decoration: const InputDecoration(
                  labelText: 'Model Name',
                  hintText: 'google/gemma-4-e4b',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.smart_toy_outlined, size: 20),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = _newCustomNameController.text.trim();
              final url = _newBaseUrlController.text.trim();
              final modelName = _newModelNameController.text.trim();
              if (url.isNotEmpty && modelName.isNotEmpty) {
                setState(() {
                  _customModels.add(_CustomModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    baseUrl: url,
                    modelName: modelName,
                  ));
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditModelDialog(_CustomModel model) {
    final nameCtrl = TextEditingController(text: model.name);
    final urlCtrl = TextEditingController(text: model.baseUrl);
    final modelCtrl = TextEditingController(text: model.modelName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Model'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.link_outlined, size: 20),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Model Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.smart_toy_outlined, size: 20),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              model.name = nameCtrl.text.trim();
              model.baseUrl = urlCtrl.text.trim();
              model.modelName = modelCtrl.text.trim();
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // ABOUT PAGE
  // ===================================================================
  Widget _buildAboutPage() {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.smart_toy_outlined,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Mini AI Chat',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'A local AI chat app powered by\nLM Studio & Flutter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.code_outlined, size: 18),
                label: const Text('Open Source Licenses'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.bug_report_outlined, size: 16),
                label: const Text('Report an Issue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================================================================
  // HELPERS
  // ===================================================================
  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.settings_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Unknown category',
            style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
