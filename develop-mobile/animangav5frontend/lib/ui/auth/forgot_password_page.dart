import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories.dart';
import '../widgets/common.dart';
import 'auth_layout.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await context.read<AuthRepository>().forgotPassword(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: true,
      title: 'Recupera tu contraseña',
      subtitle: _sent
          ? 'Si hay una cuenta con ese email, recibirás un enlace para elegir una contraseña nueva. Revisa también la carpeta de spam.'
          : 'Te enviaremos un enlace para elegir una contraseña nueva.',
      child: _sent
          ? FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Volver al inicio de sesión'))
          : Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                  onFieldSubmitted: (_) => _send(),
                  validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '')
                      ? null
                      : 'Introduce un email válido',
                ),
                const SizedBox(height: 20),
                FilledButton(onPressed: _sending ? null : _send, child: Text(_sending ? 'Enviando…' : 'Enviar enlace')),
              ]),
            ),
    );
  }
}
