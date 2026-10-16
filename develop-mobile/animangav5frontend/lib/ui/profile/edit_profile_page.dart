import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories.dart';
import '../../state/auth_cubit.dart';
import '../widgets/common.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final _fullName = TextEditingController(text: context.read<AuthCubit>().user?.fullName);
  late final _email = TextEditingController(text: context.read<AuthCubit>().user?.email);
  bool _saving = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthCubit>();
    setState(() => _saving = true);
    try {
      final updated =
          await context.read<ProfileRepository>().update(fullName: _fullName.text.trim(), email: _email.text.trim());
      await auth.updateUser(updated);
      if (!mounted) return;
      showMessage(
          context, updated.emailVerified ? 'Datos actualizados' : 'Datos actualizados. Confirma tu nuevo email.');
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
      appBar: AppBar(title: const Text('Editar datos')),
      body: ContentWidth(
        maxWidth: 520,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty ? 'Introduce tu nombre' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '')
                    ? null
                    : 'Introduce un email válido',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Guardando…' : 'Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
