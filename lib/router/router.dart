import 'package:gemma4/presentation/home/responsive_home_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ResponsiveHomePage(),
      ),
    ],
  );
}
