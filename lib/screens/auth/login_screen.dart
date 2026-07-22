import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  final _service = SupabaseStudyService();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await _service.signIn(email: _emailCtrl.text, password: _passwordCtrl.text);
      if (res.session != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TalkBack: Scaffold with semantic label
      body: Semantics(
        label: 'Login screen for Inter AI Study Buddy. Enter email and password to login.',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Semantics(
                    header: true,
                    child: Icon(Icons.school, size: 80, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    header: true,
                    child: const Text('Inter AI Study Buddy', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const Text('Login with Email & Password - Saved safely in Supabase', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),

                  // Email - TalkBack label
                  Semantics(
                    label: 'Email field, required',
                    textField: true,
                    child: TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'your.email@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Email required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Semantics(
                    label: 'Password field, required',
                    textField: true,
                    child: TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: Semantics(
                          label: _obscure ? 'Show password' : 'Hide password',
                          button: true,
                          child: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Password required' : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login button with TalkBack
                  Semantics(
                    button: true,
                    label: 'Login button, double tap to login',
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    label: 'Go to sign up, create new account',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have account?"),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_emailCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter email first')));
                        return;
                      }
                      try {
                        await _service.resendVerification(_emailCtrl.text);
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email resent!')));
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: const Text('Resend verification email'),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    button: true,
                    label: 'Accessibility settings, open TalkBack guide',
                    child: TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/accessibility'),
                      icon: const Icon(Icons.accessibility_new),
                      label: const Text('TalkBack & Accessibility Guide'),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/license'),
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Licenses & Privacy'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
