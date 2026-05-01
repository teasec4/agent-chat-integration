import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;
  final String modelName;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  static const int maxContextLength = 131072;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.modelName = '',
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.totalTokens = 0,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || widget.isLoading) return;
    widget.onSend(trimmed);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info bar: model + tokens
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    // TODO: model selection dialog
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.smart_toy_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          widget.modelName.isEmpty ? 'Model' : widget.modelName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey[500]),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.totalTokens > 0)
                  Text(
                    'Tokens: ${widget.totalTokens} / ${ChatInput.maxContextLength}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          // Divider
          Container(height: 1, color: Colors.grey.shade300),
          // Input row with send button inside
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      suffixIcon: IconButton(
                        icon: widget.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                        onPressed: () => _handleSubmit(_controller.text),
                        tooltip: 'Send',
                      ),
                    ),
                    onSubmitted: _handleSubmit,
                    enabled: !widget.isLoading,
                    textInputAction: TextInputAction.send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
