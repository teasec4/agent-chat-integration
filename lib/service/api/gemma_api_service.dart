import 'dart:convert';

import 'package:gemma4/data/models/chat_request.dart';
import 'package:gemma4/data/models/chat_response.dart';
import 'package:http/http.dart' as http;

class GemmaApiService {
  static const String _baseUrl = "http://localhost:1234";
  
  Future<ChatResponse> getAiResponse(ChatRequest request) async{
    final url = Uri.parse('$_baseUrl/v1/chat/completions');
    
    try{
      Map<String, dynamic> payload = request.toJson();
      String jsonBody = jsonEncode(payload);
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
      
      final jsonResponse = jsonDecode(response.body);
      
      return ChatResponse.fromJson(jsonResponse);
    } catch (e){
      throw Exception('Failed to get AI response: $e');
    }
  }
}
