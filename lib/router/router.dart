import 'package:gemma4/presentation/chat/chat_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/chat',
    routes: [
      GoRoute(path: '/chat', builder: (context, state) => ChatPage()),
    ],
  );
}
