import 'package:flutter/material.dart';

class TokenUsageInfo extends StatelessWidget {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  static const int maxContextLength = 131072;

  const TokenUsageInfo({
    super.key,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTokens / maxContextLength;
    final percentage = (progress * 100).clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Context: $totalTokens / $maxContextLength',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: _getProgressColor(progress),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TokenCounter(label: 'Prompt', tokens: promptTokens),
              _TokenCounter(label: 'Response', tokens: completionTokens),
              _TokenCounter(label: 'Free', tokens: maxContextLength - totalTokens),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) return Colors.green;
    if (progress < 0.75) return Colors.orange;
    return Colors.red;
  }
}

class _TokenCounter extends StatelessWidget {
  final String label;
  final int tokens;

  const _TokenCounter({required this.label, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          tokens.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}