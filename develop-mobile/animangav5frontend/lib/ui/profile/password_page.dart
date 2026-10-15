import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories.dart';
import '../widgets/common.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<ProfileRepository>().changePassword(_current.text, _new.text);
      if (!mounted) return;
      showMessage(context, 'Contraseña actualizada');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: ContentWidth(
        maxWidth: 520,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _current,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña actual'),
                validator: (v) => v == null || v.isEmpty ? 'Introduce tu contraseña actual' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _new,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva contraseña', helperText: 'Mínimo 8 caracteres'),
                validator: (v) => (v?.length ?? 0) < 8 ? 'Mínimo 8 caracteres' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _repeat,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Repite la nueva contraseña'),
                validator: (v) => v != _new.text ? 'Las contraseñas no coinciden' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                  onPressed: _saving ? null : _save, child: Text(_saving ? 'Guardando…' : 'Cambiar contraseña')),
            ],
          ),
        ),
      ),
    );
  }
}
