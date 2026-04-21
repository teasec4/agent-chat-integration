import 'package:gemma4/data/models/role.dart';

class MessageContent {
  final Role role;
  final String content;

  MessageContent({required this.role, required this.content});

  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      role: Role.values.firstWhere((e) => e.value == json['role']),
      content: json['content'] as String? ?? "",
    );
  }
}

class ChatChoice {
  final MessageContent message;
  final String finishReason;

  ChatChoice({required this.message, required this.finishReason});

  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      message: MessageContent.fromJson(json['message'] as Map<String, dynamic>),
      finishReason: json['finish_reason'] as String? ?? "",
    );
  }
}


class ChatResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<ChatChoice> choices;
  final Map<String, dynamic>? usage;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  ChatResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.totalTokens = 0,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {

    List<dynamic>? choicesJson = json['choices'] as List?;
    List<ChatChoice> parsedChoices;

    if (choicesJson != null) {
      parsedChoices = choicesJson
          .map((jsonItem) => ChatChoice.fromJson(jsonItem))
          .toList();
    } else {
        parsedChoices = [];
    }

    final usage = json['usage'] as Map<String, dynamic>?;

    return ChatResponse(
      id: json['id'] as String? ?? '',
      object: json['object'] as String? ?? '',
      created: json['created'] as int? ?? 0,
      model: json['model'] as String? ?? '',
      choices: parsedChoices,
      usage: usage,
      promptTokens: usage?['prompt_tokens'] as int? ?? 0,
      completionTokens: usage?['completion_tokens'] as int? ?? 0,
      totalTokens: usage?['total_tokens'] as int? ?? 0,
    );
  }
}

