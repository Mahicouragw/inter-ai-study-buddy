import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  final _service = SupabaseStudyService();

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await _service.signUp(
        email: _emailCtrl.text,
        username: _usernameCtrl.text,
        password: _passwordCtrl.text,
        name: _usernameCtrl.text,
      );

      if (res.user != null && mounted) {
        final needsVerification = res.user!.emailConfirmedAt == null && res.session == null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(needsVerification
                ? 'Account created! Verification email sent to ${_emailCtrl.text}. Please verify.'
                : 'Account created!'),
            backgroundColor: Colors.green,
          ),
        );
        if (needsVerification) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label: 'Sign up screen. Enter email, username, password, confirm password.',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Semantics(header: true, child: Icon(Icons.person_add, size: 70, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 8),
                  Semantics(header: true, child: const Text('Create Account', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                  const Text('Email, Username, Password, Confirm Password - Saved in Supabase safely', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),

                  // Email
                  Semantics(
                    label: 'Email field, required, unique',
                    textField: true,
                    child: TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email (unique)', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email required';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Invalid email';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Username
                  Semantics(
                    label: 'Username field, required, unique, minimum 3 characters',
                    textField: true,
                    child: TextFormField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Username (unique)', prefixIcon: Icon(Icons.alternate_email), border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Username required';
                        if (v.trim().length < 3) return 'Min 3 chars';
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) return 'Only letters, numbers, _';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password
                  Semantics(
                    label: 'Password field, required, minimum 6 characters',
                    textField: true,
                    child: TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure1,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure1 = !_obscure1)),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password required';
                        if (v.length < 6) return 'Min 6 chars';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Confirm Password
                  Semantics(
                    label: 'Confirm password field, must match password',
                    textField: true,
                    child: TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscure2,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure2 = !_obscure2)),
                      ),
                      validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Semantics(
                    button: true,
                    label: 'Sign up button, creates account and sends verification email',
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signup,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _loading ? const CircularProgressIndicator() : const Text('Sign Up & Send Verification', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have account?'),
                      TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Login')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('✓ Username unique check\n✓ Email unique check\n✓ Verification email via Supabase\n✓ Password bcrypt safe\n✓ TalkBack accessible', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/accessibility'),
                    icon: const Icon(Icons.accessibility_new, size: 16),
                    label: const Text('TalkBack Guide', style: TextStyle(fontSize: 12)),
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
