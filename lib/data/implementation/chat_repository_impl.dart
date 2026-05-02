import 'package:gemma4/data/db_models/db_entries.dart' as db;
import 'package:gemma4/data/models/chat_request.dart';
import 'package:gemma4/domain/entities/chat.dart';
import 'package:gemma4/domain/entities/message.dart';
import 'package:gemma4/domain/entities/stream_event.dart';
import 'package:gemma4/domain/repositories/chat_repository.dart';
import 'package:gemma4/domain/services/ai_service.dart';
import 'package:isar_community/isar.dart';

class ChatRepositoryImpl implements ChatRepository {
  final AiService _aiService;
  final Isar _isar;

  ChatRepositoryImpl({
    required AiService aiService,
    required Isar isar,
  }) : _aiService = aiService,
       _isar = isar;

  // --- mappers ---

  Chat _toDomain(db.ChatEntry entry) => Chat(
    id: entry.id,
    title: entry.title,
  );

  List<Message> _messagesToDomain(List<db.Message> msgs) => msgs
    .map((m) => Message(role: m.role, content: m.content))
    .toList();

  // --- private helpers ---

  Future<int> _saveMessage({
    required int chatId,
    required String content,
    required Role role,
  }) async {
    final message = db.Message()
      ..role = role
      ..content = content
      ..createdAt = DateTime.now()
      ..chatId = chatId;

    await _isar.writeTxn(() async {
      final newId = await _isar.messages.put(message);
      message.id = newId;
    });
    return message.id;
  }

  Future<List<ApiMessage>> _buildChatMessages(int chatId) async {
    final messages = await _isar.messages
        .filter()
        .chatIdEqualTo(chatId)
        .sortByCreatedAt()
        .findAll();

    return messages
        .map((m) => ApiMessage(role: m.role, content: m.content))
        .toList();
  }

  // --- interface implementation ---

  @override
  String get model => _aiService.model;

  @override
  Future<Chat?> getChatById(int id) async {
    final entry = await _isar.chatEntrys.get(id);
    return entry != null ? _toDomain(entry) : null;
  }

  @override
  Future<List<Message>> getMessagesForChat(int chatId) async {
    final result = await _isar.messages
        .filter()
        .chatIdEqualTo(chatId)
        .sortByCreatedAt()
        .findAll();
    return _messagesToDomain(result);
  }

  @override
  Future<void> updateChatTitle(int chatId, String title) async {
    await _isar.writeTxn(() async {
      final chat = await _isar.chatEntrys.get(chatId);
      if (chat != null) {
        chat.title = title;
        await _isar.chatEntrys.put(chat);
      }
    });
  }

  @override
  Future<(String, int, int, int)> sendToAi({
    required int chatId,
    required String userMessage,
    double temperature = 0.7,
  }) async {
    // Save user message first
    final userMsgId = await _saveMessage(
      chatId: chatId,
      content: userMessage,
      role: Role.user,
    );

    try {
      final chatMessages = await _buildChatMessages(chatId);

      // Always prepend system prompt to ensure context is never empty
      final requestMessages = [
        ApiMessage(
          role: Role.system,
          content: 'You are a helpful AI assistant.',
        ),
        ...chatMessages,
      ];

      final request = ChatRequest(
        model: _aiService.model,
        messages: requestMessages,
        temperature: temperature,
        stream: false,
      );

      final response = await _aiService.getAiResponse(request);

      final aiContent =
          response.choices.firstOrNull?.message.content ??
          'Error: Empty response from AI.';

      // Save AI response
      await _saveMessage(
        chatId: chatId,
        content: aiContent,
        role: Role.assistant,
      );

      return (
        aiContent,
        response.promptTokens,
        response.completionTokens,
        response.totalTokens,
      );
    } catch (e) {
      // Rollback: delete the orphan user message
      await _isar.writeTxn(() async {
        await _isar.messages.delete(userMsgId);
      });
      rethrow;
    }
  }

  @override
  Stream<StreamEvent> sendToAiStream({
    required int chatId,
    required String userMessage,
    double temperature = 0.7,
  }) async* {
    // Save user message first
    final userMsgId = await _saveMessage(
      chatId: chatId,
      content: userMessage,
      role: Role.user,
    );

    StringBuffer? fullAiContent;
    int finalPromptTokens = 0;
    int finalCompletionTokens = 0;
    int finalTotalTokens = 0;

    try {
      final chatMessages = await _buildChatMessages(chatId);

      final requestMessages = [
        ApiMessage(
          role: Role.system,
          content: 'You are a helpful AI assistant.',
        ),
        ...chatMessages,
      ];

      final request = ChatRequest(
        model: _aiService.model,
        messages: requestMessages,
        temperature: temperature,
        stream: true,
      );

      fullAiContent = StringBuffer();

      // Stream the response from the AI service
      await for (final event in _aiService.streamChat(request)) {
        if (event.delta.isNotEmpty) {
          fullAiContent.write(event.delta);
          yield StreamEvent(delta: event.delta); // forward delta
        }

        if (event.isFinished) {
          finalPromptTokens = event.promptTokens;
          finalCompletionTokens = event.completionTokens;
          finalTotalTokens = event.totalTokens;
        }
      }

      // Save the complete AI response to Isar
      if (fullAiContent.isNotEmpty) {
        await _saveMessage(
          chatId: chatId,
          content: fullAiContent.toString(),
          role: Role.assistant,
        );
      }

      // Yield final event with token usage
      yield StreamEvent(
        delta: '',
        isFinished: true,
        promptTokens: finalPromptTokens,
        completionTokens: finalCompletionTokens,
        totalTokens: finalTotalTokens,
      );
    } catch (e) {
      // Rollback: delete the orphan user message
      await _isar.writeTxn(() async {
        await _isar.messages.delete(userMsgId);
      });
      rethrow;
    }
  }
}
