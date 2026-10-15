import 'package:flutter/material.dart';

import '../../core/config.dart';

/// Portada de un manga o volumen con esquinas redondeadas y estado de carga/error.
class CoverImage extends StatelessWidget {
  const CoverImage(this.path, {super.key, this.width, this.height, this.radius = 12});

  final String? path;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.imageUrl(path);
    final placeholder = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.outline),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? placeholder
          : Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
              loadingBuilder: (_, child, progress) => progress == null ? child : placeholder,
            ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.url, required this.name, this.radius = 24});

  final String url;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(RegExp(r'\s+')).take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundImage: url.isEmpty ? null : NetworkImage(AppConfig.imageUrl(url)),
      // Si la imagen no carga se quedan las iniciales
      onForegroundImageError: url.isEmpty ? null : (_, __) {},
      child: Text(initials, style: TextStyle(fontSize: radius * 0.7, fontWeight: FontWeight.w600)),
    );
  }
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

/// Etiqueta de stock: verde, naranja (pocas unidades) o rojo (agotado).
class StockBadge extends StatelessWidget {
  const StockBadge(this.stock, {super.key});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (stock) {
      <= 0 => ('Agotado', const Color(0xFFC62828)),
      <= 5 => ('Últimas $stock uds.', const Color(0xFFB26A00)),
      _ => ('En stock', const Color(0xFF2E7D32)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

void showMessage(BuildContext context, String message, {bool error = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? scheme.error : null,
    ));
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
