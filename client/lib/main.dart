import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'pages/auth/auth_page.dart';
import 'pages/home/home_page.dart';
import 'routes/app_router.dart';
import 'services/supabase/auth_service.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables safely
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (_) {
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {
      debugPrint("Note: .env file not found or couldn't be loaded, using defaults.");
    }
  }

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const NexaApp());
}

class NexaApp extends StatelessWidget {
  const NexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ??
            (SupabaseService.isInitialized
                ? Supabase.instance.client.auth.currentSession
                : null);

        if (session != null) {
          return HomePage(
            onSignOut: () {
              setState(() {});
            },
          );
        } else {
          return AuthPage(
            onAuthenticated: () {
              setState(() {});
            },
          );
        }
      },
    );
  }
}
