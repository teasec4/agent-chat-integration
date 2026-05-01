import 'dart:convert';

import 'package:gemma4/data/models/chat_request.dart';
import 'package:gemma4/data/models/chat_response.dart';
import 'package:gemma4/domain/services/ai_service.dart';
import 'package:http/http.dart' as http;

class GemmaApiService implements AiService {
  final String baseUrl;
  @override
  final String model;

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
}
