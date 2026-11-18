import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'theme.dart';

enum AuthMode { login, signup }

Future<void> showAuthSheet(BuildContext context, AuthMode mode) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _AuthForm(initial: mode),
  );
}

class _AuthForm extends StatefulWidget {
  final AuthMode initial;
  const _AuthForm({required this.initial});

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  late AuthMode mode = widget.initial;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool busy = false;
  String? error;
  String? info;

  bool get signup => mode == AuthMode.signup;

  @override
  void dispose() {
    for (final c in [_name, _email, _pass, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() fn, {bool closeOnSuccess = true}) async {
    if (!firebaseReady) return;
    setState(() {
      busy = true;
      error = null;
      info = null;
    });
    try {
      await fn();
      if (closeOnSuccess && mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => error = AuthService.message(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _submit() {
    final email = _email.text.trim();
    if (signup) {
      if (_name.text.trim().isEmpty) return setState(() => error = 'Enter your full name.');
      if (_pass.text != _confirm.text) return setState(() => error = 'Passwords do not match.');
    }
    _run(() => signup
        ? AuthService.signUp(_name.text.trim(), email, _pass.text)
        : AuthService.signIn(email, _pass.text));
  }

  void _reset() {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => error = 'Enter your email first, then tap Forgot password.');
      return;
    }
    _run(() async {
      await AuthService.reset(email);
      if (mounted) setState(() => info = 'Password reset link sent. Check your inbox.');
    }, closeOnSuccess: false);
  }

  Widget _field(TextEditingController c, String label,
      {bool obscure = false, TextInputType? type, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _note(String text, Color color) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 13, height: 1.35)),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/logo.png', width: 52, height: 52),
              ),
            ),
            const SizedBox(height: 10),
            Text(signup ? 'Create your account' : 'Welcome back',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              signup
                  ? 'Sign up to apply for admission and access your portal.'
                  : 'Log in to your Indus Virtual School account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.muted, fontSize: 14),
            ),
            const SizedBox(height: 16),
            SegmentedButton<AuthMode>(
              segments: const [
                ButtonSegment(value: AuthMode.login, label: Text('Log in')),
                ButtonSegment(value: AuthMode.signup, label: Text('Sign up')),
              ],
              selected: {mode},
              onSelectionChanged: (s) => setState(() {
                mode = s.first;
                error = null;
                info = null;
              }),
            ),
            const SizedBox(height: 16),
            if (!firebaseReady)
              _note('Firebase is not configured yet. Run `flutterfire configure` (see README).', kAmber2),
            if (signup) _field(_name, 'Full name', hint: 'e.g. Ayesha Khan'),
            _field(_email, 'Email', type: TextInputType.emailAddress, hint: 'you@example.com'),
            _field(_pass, 'Password', obscure: true, hint: 'At least 6 characters'),
            if (signup) _field(_confirm, 'Confirm password', obscure: true),
            if (!signup)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: busy ? null : _reset, child: const Text('Forgot password?')),
              ),
            if (error != null) _note(error!, Colors.red.shade600),
            if (info != null) _note(info!, Colors.green.shade600),
            FilledButton(
              onPressed: busy || !firebaseReady ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: kAmber,
                foregroundColor: kDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              child: Text(busy ? 'Please wait…' : (signup ? 'Create account' : 'Log in')),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Center(child: Text('or'))),
            OutlinedButton(
              onPressed: busy || !firebaseReady ? null : () => _run(AuthService.google),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Continue with Google'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => mode = signup ? AuthMode.login : AuthMode.signup),
              child: Text(signup ? 'Already have an account? Log in' : 'New to Indus Virtual School? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
