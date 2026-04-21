import 'package:gemma4/data/models/role.dart';

class ChatRequest {
  final String model;
  final List<Message> messages;
  final double temperature;
  final bool stream;

  ChatRequest({required this.model, required this.messages, required this.temperature, required this.stream});
  
  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((message) => message.toJson()).toList(),
      'temperature': temperature,
      'stream': stream,
    };
  }
}

class Message {
  final Role role;
  final String content;

  Message({required this.role, required this.content});
  
  Map<String, dynamic> toJson() {
    return {
      'role': role.value,
      'content': content,
    };
  }
}
