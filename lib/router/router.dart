import 'package:gemma4/presentation/chat/chat_page.dart';
import 'package:gemma4/presentation/start/start_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => StartPage(),
        routes: [
          GoRoute(path: '/chat/:title', builder: (context, state) {
            final title = state.pathParameters['title'];
            if (title == null) {
              return ChatPage(title: "Not Found");
            }
            return ChatPage(title: title);
          }),
        ]
      ),
    ],
  );
}
