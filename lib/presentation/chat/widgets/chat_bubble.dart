import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:gemma4/domain/entities/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool showSender;

  const ChatBubble({
    super.key,
    required this.message,
    this.showSender = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == Role.user;
    final theme = Theme.of(context);
    final styleSheet = _buildStyleSheet(theme);

    if (isUser) {
      return _buildUserBubble(context, theme, styleSheet);
    }
    return _buildAiMessage(context, theme, styleSheet);
  }

  double _maxBubbleWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.80;
  }

  Widget _buildUserBubble(
      BuildContext context, ThemeData theme, MarkdownStyleSheet styleSheet) {
    final maxW = _maxBubbleWidth(context);
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showSender)
              Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 2),
                child: Text(
                  'You',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: styleSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiMessage(
      BuildContext context, ThemeData theme, MarkdownStyleSheet styleSheet) {
    final maxW = _maxBubbleWidth(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSender)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                'Gemma',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: MarkdownBody(
              data: message.content,
              selectable: true,
              styleSheet: styleSheet,
            ),
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _buildStyleSheet(ThemeData theme) {
    final brightness = theme.brightness;
    final surfaceColor = brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.grey.shade100;
    final codeTextColor = brightness == Brightness.dark
        ? Colors.green.shade300
        : Colors.red.shade800;

    return MarkdownStyleSheet(
      p: TextStyle(fontSize: 15, height: 1.4, color: theme.colorScheme.onSurface),
      h1: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, height: 1.6),
      h2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, height: 1.5),
      h3: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, height: 1.4),
      code: TextStyle(fontSize: 13, fontFamily: 'monospace', color: codeTextColor, backgroundColor: surfaceColor),
      codeblockDecoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8)),
      codeblockPadding: const EdgeInsets.all(12),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 3)),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
      listBullet: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1)),
      ),
      tableHead: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface),
      tableBody: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
      tableBorder: TableBorder.all(color: theme.colorScheme.outlineVariant, width: 1),
      tableColumnWidth: const FlexColumnWidth(),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      strong: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
      em: TextStyle(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface),
      del: TextStyle(decoration: TextDecoration.lineThrough, color: theme.colorScheme.onSurface),
      a: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
    );
  }
}
