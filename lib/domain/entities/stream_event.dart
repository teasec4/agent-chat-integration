class StreamEvent {
  /// New text content delta from the stream
  final String delta;

  /// Whether the stream has finished
  final bool isFinished;

  /// Token usage (only available when isFinished is true)
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const StreamEvent({
    this.delta = '',
    this.isFinished = false,
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.totalTokens = 0,
  });
}
