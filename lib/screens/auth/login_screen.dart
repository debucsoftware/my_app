import 'package:flutter/material.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/services/auth_service.dart';
import 'package:istakibim/widgets/language_selector.dart';

enum _LoginType { admin, worker }

enum _WorkerStep { email, login, setup }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  _LoginType _loginType = _LoginType.admin;
  _WorkerStep _workerStep = _WorkerStep.email;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchType(_LoginType type) {
    setState(() {
      _loginType = type;
      _workerStep = _WorkerStep.email;
      _error = null;
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _workerContinue() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final invite = await _authService.getWorkerInvite(_emailController.text);
      setState(() {
        _workerStep = invite != null ? _WorkerStep.setup : _WorkerStep.login;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_loginType == _LoginType.admin) {
        await _authService.signIn(
          _emailController.text,
          _passwordController.text,
        );
      } else if (_workerStep == _WorkerStep.setup) {
        await _authService.completeWorkerRegistration(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _authService.signIn(
          _emailController.text,
          _passwordController.text,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.sizeOf(context).width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [LanguageSelector()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SideMenu(
                        loginType: _loginType,
                        onSelect: _switchType,
                        adminLabel: l10n.adminLogin,
                        workerLabel: l10n.workerLogin,
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: _buildForm(l10n)),
                    ],
                  )
                : Column(
                    children: [
                      SegmentedButton<_LoginType>(
                        segments: [
                          ButtonSegment(value: _LoginType.admin, label: Text(l10n.adminLogin)),
                          ButtonSegment(value: _LoginType.worker, label: Text(l10n.workerLogin)),
                        ],
                        selected: {_loginType},
                        onSelectionChanged: (s) => _switchType(s.first),
                      ),
                      const SizedBox(height: 24),
                      Expanded(child: _buildForm(l10n)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final isWorker = _loginType == _LoginType.worker;
    final showPassword = !isWorker || _workerStep != _WorkerStep.email;
    final isSetup = isWorker && _workerStep == _WorkerStep.setup;

    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          Icon(Icons.construction, size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            isWorker ? l10n.workerLogin : l10n.adminLogin,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (isSetup) ...[
            const SizedBox(height: 8),
            Text(l10n.firstLoginHint, textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.email),
            keyboardType: TextInputType.emailAddress,
            readOnly: isWorker && _workerStep != _WorkerStep.email,
            validator: (v) => v == null || v.trim().isEmpty ? l10n.email : null,
          ),
          if (showPassword) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: isSetup ? l10n.setPassword : l10n.password,
              ),
              obscureText: true,
              validator: (v) {
                if (v == null || v.length < 6) return l10n.password;
                return null;
              },
            ),
          ],
          if (isSetup) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: l10n.confirmPassword),
              obscureText: true,
              validator: (v) {
                if (v != _passwordController.text) return l10n.confirmPassword;
                return null;
              },
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading
                  ? null
                  : () {
                      if (isWorker && _workerStep == _WorkerStep.email) {
                        _workerContinue();
                      } else {
                        _submit();
                      }
                    },
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isWorker && _workerStep == _WorkerStep.email
                          ? l10n.continueBtn
                          : (isSetup ? l10n.setPassword : l10n.login),
                    ),
            ),
          ),
          if (isWorker && _workerStep != _WorkerStep.email) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _workerStep = _WorkerStep.email;
                _passwordController.clear();
                _confirmPasswordController.clear();
                _error = null;
              }),
              child: Text(l10n.email),
            ),
          ],
        ],
      ),
    );
  }
}

class _SideMenu extends StatelessWidget {
  const _SideMenu({
    required this.loginType,
    required this.onSelect,
    required this.adminLabel,
    required this.workerLabel,
  });

  final _LoginType loginType;
  final ValueChanged<_LoginType> onSelect;
  final String adminLabel;
  final String workerLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MenuTile(
            icon: Icons.admin_panel_settings,
            label: adminLabel,
            selected: loginType == _LoginType.admin,
            onTap: () => onSelect(_LoginType.admin),
          ),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.engineering,
            label: workerLabel,
            selected: loginType == _LoginType.worker,
            onTap: () => onSelect(_LoginType.worker),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    );
  }
}
