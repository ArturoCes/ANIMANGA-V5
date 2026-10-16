import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/auth_cubit.dart';
import '../auth/login_page.dart';

/// Portada o imagen de la API con caché en disco (móvil) o del navegador (web).
class CoverImage extends StatelessWidget {
  const CoverImage(this.name, {super.key, this.width, this.height, this.radius = 12});

  final String? name;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.imageUrl(name);
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: width,
      height: height,
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      alignment: Alignment.center,
      child: Icon(Icons.menu_book_rounded, color: scheme.primary.withValues(alpha: 0.5)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? placeholder
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder: (_, __) => placeholder,
              errorWidget: (_, __, ___) => placeholder,
            ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.avatar, required this.name, this.radius = 24});

  final String? avatar;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(RegExp(r'\s+')).take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundImage: CachedNetworkImageProvider(AppConfig.avatarUrl(avatar, name)),
      // Si la imagen no carga se quedan las iniciales
      onForegroundImageError: (_, __) {},
      child: Text(initials, style: TextStyle(fontSize: radius * 0.7, fontWeight: FontWeight.w600)),
    );
  }
}

/// Estrellas de solo lectura.
class RatingStars extends StatelessWidget {
  const RatingStars(this.rating, {super.key, this.size = 16});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              rating >= i
                  ? Icons.star_rounded
                  : (rating >= i - 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
              size: size,
              color: AppColors.star,
            ),
        ],
      );
}

/// Mensaje centrado para listas vacías o errores, con acción opcional.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action, this.onAction});

  final IconData icon;
  final String title;
  final String? message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(icon, size: 34, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(onPressed: onAction, child: Text(action!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pantalla de "inicia sesión para continuar" para las pestañas que requieren cuenta.
class LoginRequired extends StatelessWidget {
  const LoginRequired({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => EmptyState(
        icon: icon,
        title: 'Inicia sesión para continuar',
        message: message,
        action: 'Iniciar sesión',
        onAction: () => openLogin(context),
      );
}

/// Abre el login. Devuelve `true` si al volver hay sesión iniciada.
Future<bool> openLogin(BuildContext context) async {
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
  return context.mounted && context.read<AuthCubit>().state.isLoggedIn;
}

/// Ejecuta [action] si hay sesión; si no, pide iniciarla primero.
Future<void> requireLogin(BuildContext context, Future<void> Function() action) async {
  if (context.read<AuthCubit>().state.isLoggedIn || await openLogin(context)) {
    await action();
  }
}

/// Etiqueta de stock: verde, naranja (pocas unidades) o rojo (agotado).
class StockBadge extends StatelessWidget {
  const StockBadge(this.stock, {super.key});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (stock) {
      <= 0 => ('Agotado', const Color(0xFFE53935)),
      <= 5 => ('Últimas $stock uds.', const Color(0xFFF57C00)),
      _ => ('En stock', const Color(0xFF43A047)),
    };
    return _Pill(label: label, color: color);
  }
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge(this.status, {super.key});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.paid => Theme.of(context).colorScheme.primary,
      OrderStatus.shipped => const Color(0xFF1E88E5),
      OrderStatus.delivered => const Color(0xFF43A047),
      OrderStatus.cancelled => const Color(0xFFE53935),
    };
    return _Pill(label: status.label, color: color);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(99)),
        child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

void showMessage(BuildContext context, String message, {bool error = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), backgroundColor: error ? scheme.error : null));
}

/// Limita el ancho del contenido en pantallas grandes (web/tablet).
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 1100});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) =>
      Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}
