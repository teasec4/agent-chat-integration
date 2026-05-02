import 'dart:async';
import 'dart:convert';

import 'package:gemma4/data/models/chat_request.dart';
import 'package:gemma4/data/models/chat_response.dart';
import 'package:gemma4/domain/entities/stream_event.dart';
import 'package:gemma4/domain/services/ai_service.dart';
import 'package:http/http.dart' as http;

class GemmaApiService implements AiService {
  String baseUrl;
  @override
  String model;

  GemmaApiService({
    this.baseUrl = 'http://localhost:1234',
    this.model = 'google/gemma-4-e4b',
  });

  @override
  Future<ChatResponse> getAiResponse(ChatRequest request) async {
    final url = Uri.parse('$baseUrl/v1/chat/completions');

    try {
      Map<String, dynamic> payload = request.toJson();
      String jsonBody = jsonEncode(payload);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'AI API error ${response.statusCode}: ${response.body}',
        );
      }

      final jsonResponse = jsonDecode(response.body);
      return ChatResponse.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('AI request failed: $e');
    }
  }

  @override
  Stream<StreamEvent> streamChat(ChatRequest request) async* {
    final url = Uri.parse('$baseUrl/v1/chat/completions');

    // Build payload with streaming enabled
    final payload = {
      ...request.toJson(),
      'stream': true,
      'stream_options': {'include_usage': true},
    };

    final jsonBody = jsonEncode(payload);

    final client = http.Client();
    try {
      final httpRequest = http.StreamedRequest('POST', url);
      httpRequest.headers['Content-Type'] = 'application/json';
      httpRequest.sink.add(utf8.encode(jsonBody));
      await httpRequest.sink.close();

      final response = await client.send(httpRequest);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw Exception('AI streaming error ${response.statusCode}: $body');
      }

      await for (final line in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (!line.startsWith('data: ')) continue;

        final data = line.substring(6).trim();
        if (data == '[DONE]') break;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List?;
          if (choices == null || choices.isEmpty) continue;

          final choice = choices[0] as Map<String, dynamic>;
          final delta = choice['delta'] as Map<String, dynamic>?;
          final content = delta?['content'] as String? ?? '';

          // Check for token usage (usually in the last chunk)
          final usage = json['usage'] as Map<String, dynamic>?;

          // finish_reason signals the end of stream (barring [DONE])
          final finishReason = choice['finish_reason'];
          final isFinished =
              finishReason != null &&
              finishReason is String &&
              finishReason.isNotEmpty;

          yield StreamEvent(
            delta: content,
            isFinished: isFinished,
            promptTokens: usage?['prompt_tokens'] as int? ?? 0,
            completionTokens: usage?['completion_tokens'] as int? ?? 0,
            totalTokens: usage?['total_tokens'] as int? ?? 0,
          );
        } catch (_) {
          // Skip malformed JSON chunks
        }
      }
    } finally {
      client.close();
    }
  }
}
