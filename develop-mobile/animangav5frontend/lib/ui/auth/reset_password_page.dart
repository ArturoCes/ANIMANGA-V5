import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories.dart';
import '../widgets/common.dart';
import 'auth_layout.dart';
import 'login_page.dart';

/// Se abre desde el enlace del email (`/?reset=TOKEN`).
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.token});
  final String token;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthRepository>().resetPassword(widget.token, _password.text);
      if (!mounted) return;
      showMessage(context, 'Contraseña cambiada. Ya puedes iniciar sesión.');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: true,
      title: 'Elige una contraseña nueva',
      subtitle: 'Al cambiarla se cerrará la sesión en tus otros dispositivos.',
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nueva contraseña', prefixIcon: Icon(Icons.lock_outline)),
            validator: (v) => (v?.length ?? 0) < 8 ? 'Mínimo 8 caracteres' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _repeat,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Repite la contraseña', prefixIcon: Icon(Icons.lock_outline)),
            onFieldSubmitted: (_) => _save(),
            validator: (v) => v != _password.text ? 'Las contraseñas no coinciden' : null,
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Guardando…' : 'Cambiar contraseña')),
        ]),
      ),
    );
  }
}
