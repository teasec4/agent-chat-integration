import 'package:gemma4/domain/entities/chat.dart';
import 'package:gemma4/domain/entities/message.dart';
import 'package:gemma4/domain/entities/stream_event.dart';

abstract class ChatRepository {
  /// The AI model name in use.
  String get model;

  /// Send a user message to AI and get a response.
  /// Returns (aiContent, promptTokens, completionTokens, totalTokens).
  Future<(String, int, int, int)> sendToAi({
    required int chatId,
    required String userMessage,
    double temperature = 0.7,
  });

  /// Send a user message to AI and stream the response.
  /// The stream yields content deltas and a final event with token usage.
  Stream<StreamEvent> sendToAiStream({
    required int chatId,
    required String userMessage,
    double temperature = 0.7,
  });

  /// Get a chat by its ID.
  Future<Chat?> getChatById(int id);

  /// Get all messages for a chat.
  Future<List<Message>> getMessagesForChat(int chatId);

  /// Update the title of a chat.
  Future<void> updateChatTitle(int chatId, String title);
}
