import 'package:gemma4/domain/entities/chat.dart';
import 'package:gemma4/domain/entities/message.dart';

abstract class ChatRepository {
  /// The AI model name in use.
  String get model;

  /// Send a user message to AI and get a response.
  /// Returns (aiContent, promptTokens, completionTokens, totalTokens).
  Future<(String, int, int, int)> sendToAi({
    required int chatId,
    required String userMessage,
  });

  /// Get a chat by its ID.
  Future<Chat?> getChatById(int id);

  /// Get all messages for a chat.
  Future<List<Message>> getMessagesForChat(int chatId);
}
