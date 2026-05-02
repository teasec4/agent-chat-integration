/// Pure value object for token usage stats.
/// Replaces 3 separate scalar parameters in ChatInput.
class TokenCount {
  final int prompt;
  final int completion;
  final int total;

  const TokenCount({
    this.prompt = 0,
    this.completion = 0,
    this.total = 0,
  });

  /// Maximum context window for the model.
  static const int maxContext = 131072;

  TokenCount copyWith({
    int? prompt,
    int? completion,
    int? total,
  }) {
    return TokenCount(
      prompt: prompt ?? this.prompt,
      completion: completion ?? this.completion,
      total: total ?? this.total,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenCount &&
          runtimeType == other.runtimeType &&
          prompt == other.prompt &&
          completion == other.completion &&
          total == other.total;

  @override
  int get hashCode => Object.hash(prompt, completion, total);

  @override
  String toString() =>
      'TokenCount(prompt: $prompt, completion: $completion, total: $total)';
}
