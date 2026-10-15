import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api_client.dart';
import '../../data/repositories.dart';
import '../../state/auth_cubit.dart';
import '../widgets/common.dart';
import 'edit_profile_page.dart';
import 'orders_page.dart';
import 'password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _uploading = false;

  Future<void> _changeAvatar() async {
    final auth = context.read<AuthCubit>();
    final repo = context.read<ProfileRepository>();
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final file = UploadFile(bytes: await picked.readAsBytes(), filename: picked.name);
      await auth.updateUser(await repo.updateAvatar(auth.user!.id, file));
      if (mounted) showMessage(context, 'Foto de perfil actualizada');
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salir')),
        ],
      ),
    );
    if (ok == true && mounted) context.read<AuthCubit>().logout();
  }

  void _open(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.select((AuthCubit c) => c.user);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ContentWidth(
        maxWidth: 640,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        UserAvatar(url: user.image, name: user.fullName, radius: 38),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: IconButton.filled(
                            tooltip: 'Cambiar foto',
                            iconSize: 16,
                            visualDensity: VisualDensity.compact,
                            onPressed: _uploading ? null : _changeAvatar,
                            icon: _uploading
                                ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.photo_camera),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                          Text('@${user.username}',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                          Text(user.email,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _Tile(icon: Icons.receipt_long, label: 'Mis pedidos', onTap: () => _open(const OrdersPage())),
                  const Divider(height: 1),
                  _Tile(icon: Icons.edit_outlined, label: 'Editar datos', onTap: () => _open(const EditProfilePage())),
                  const Divider(height: 1),
                  _Tile(
                      icon: Icons.lock_outline, label: 'Cambiar contraseña', onTap: () => _open(const PasswordPage())),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: _Tile(icon: Icons.logout, label: 'Cerrar sesión', danger: true, onTap: _logout),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap, this.danger = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: danger ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
