import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/services/auth_service.dart';
import 'package:istakibim/widgets/language_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.sizeOf(context).width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [LanguageSelector()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 420 : double.infinity),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction, size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(l10n.appTitle, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: l10n.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.isEmpty ? l10n.email : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: l10n.password),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty ? l10n.password : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.login),
                    ),
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
