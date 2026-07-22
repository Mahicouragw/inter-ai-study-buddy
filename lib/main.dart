import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/accessibility_screen.dart';
import 'screens/license_screen.dart';
import 'services/app_state.dart';
import 'services/speech_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init Supabase for Auth (email, username, password, confirm) - saved safely
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    print('Supabase init failed (will use offline mode): $e');
  }
  final appState = AppState();
  await appState.load();
  final speech = SpeechService();
  // Fire-and-forget: mic/TTS init must never block app start.
  speech.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        Provider.value(value: speech),
      ],
      child: const StudyApp(),
    ),
  );
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return MaterialApp(
      title: 'Inter AI Study Buddy',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppDarkTheme(),
      themeMode: state.themeMode,
      home: const AuthGate(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/accessibility': (context) => const AccessibilityScreen(),
        '/license': (context) => const LicenseScreen(),
      },
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
  void initState() {
    super.initState();
    try {
      SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
        if (mounted) setState(() {});
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session != null) {
        final user = session.user;
        // If email not confirmed, show verification pending but allow?
        // For better TalkBack experience, we allow even if not confirmed but show banner
        return const HomeScreen();
      }
    } catch (e) {
      print('Auth gate error (offline): $e');
      // Fallback to home without auth if Supabase not configured
      return const HomeScreen();
    }
    // If no session, show login but with skip option for accessibility (optional)
    return const LoginScreen();
  }
}

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Semantics(
        label: 'Verification pending screen, check email for verification link',
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.mark_email_read, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Semantics(header: true, child: const Text('Verification email sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            const Text('Please check inbox and click verification link. After verifying, login.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Semantics(
              button: true,
              label: 'Go to login button',
              child: ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Go to Login')),
            ),
            TextButton(onPressed: () async {
              try {
                final email = SupabaseConfig.client.auth.currentUser?.email;
                if (email != null) {
                  await SupabaseConfig.client.auth.resend(type: OtpType.signup, email: email);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resent!')));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $e')));
              }
            }, child: const Text('Resend Verification Email')),
          ]),
        ),
      ),
    );
  }
}
