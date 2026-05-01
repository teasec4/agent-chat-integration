import 'package:gemma4/presentation/chat/chat_page.dart';
import 'package:gemma4/presentation/start/start_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const StartPage(),
        routes: [
          GoRoute(
            path: 'chat/:chatId',
            builder: (context, state) {
              final chatId = int.tryParse(state.pathParameters['chatId'] ?? '');
              if (chatId == null) {
                return const StartPage();
              }
              return ChatPage(chatId: chatId);
            },
          ),
        ],
      ),
    ],
  );
}
