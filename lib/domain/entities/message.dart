enum Role { system, user, assistant }

extension RoleToString on Role {
  String get value {
    switch (this) {
      case Role.system:
        return 'system';
      case Role.user:
        return 'user';
      case Role.assistant:
        return 'assistant';
    }
  }
}

class Message {
  final Role role;
  final String content;

  const Message({required this.role, required this.content});
}
