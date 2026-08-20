import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../pages/auth/auth_page.dart';
import '../pages/gym/gym_page.dart';
import '../pages/home/home_page.dart';
import '../pages/todo/todo_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.auth:
        return MaterialPageRoute(
          builder: (ctx) => AuthPage(
            onAuthenticated: () {
              Navigator.of(ctx).pushReplacementNamed(AppRoutes.home);
            },
          ),
          settings: settings,
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (ctx) => HomePage(
            onSignOut: () {
              Navigator.of(ctx).pushReplacementNamed(AppRoutes.auth);
            },
          ),
          settings: settings,
        );
      case AppRoutes.todo:
        return MaterialPageRoute(
          builder: (_) => const TodoPage(),
          settings: settings,
        );
      case AppRoutes.gym:
        return MaterialPageRoute(
          builder: (_) => const GymPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (ctx) => HomePage(
            onSignOut: () {
              Navigator.of(ctx).pushReplacementNamed(AppRoutes.auth);
            },
          ),
          settings: settings,
        );
    }
  }
}
