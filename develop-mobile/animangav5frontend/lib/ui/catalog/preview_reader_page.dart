import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/cart_cubit.dart';
import '../widgets/common.dart';

void openPreview(BuildContext context, Volume volume) => Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => PreviewReaderPage(volume: volume),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    ));

/// Lector del avance de un volumen: páginas a pantalla completa, zoom, miniaturas y teclado.
class PreviewReaderPage extends StatefulWidget {
  const PreviewReaderPage({super.key, required this.volume});
  final Volume volume;

  @override
  State<PreviewReaderPage> createState() => _PreviewReaderPageState();
}

class _PreviewReaderPageState extends State<PreviewReaderPage> {
  static const _thumbWidth = 64.0;
  static const _thumbGap = 8.0;

  final _pages = PageController();
  final _thumbs = ScrollController();
  final _zoom = TransformationController();
  final _focus = FocusNode();
  int _index = 0;
  bool _zoomed = false;
  bool _chrome = true;
  TapDownDetails? _doubleTap;

  List<String> get _images => widget.volume.previewPages;

  /// Las páginas del avance más una final con la llamada a la compra.
  int get _count => _images.length + 1;
  bool get _onEndPage => _index == _images.length;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(() {
      final zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01;
      if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
    });
    // Precarga de las primeras páginas para que pasar de página sea instantáneo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final name in _images.take(3)) {
        precacheImage(imageProvider(AppConfig.imageUrl(name)), context);
      }
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    _thumbs.dispose();
    _zoom.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= _count) return;
    _pages.animateToPage(index, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    _zoom.value = Matrix4.identity();
    if (index + 1 < _images.length) precacheImage(imageProvider(AppConfig.imageUrl(_images[index + 1])), context);
    // Mantiene la miniatura actual centrada en la tira
    if (_thumbs.hasClients) {
      final target = index * (_thumbWidth + _thumbGap) - (_thumbs.position.viewportDimension - _thumbWidth) / 2;
      _thumbs.animateTo(target.clamp(0, _thumbs.position.maxScrollExtent),
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _toggleZoom() {
    if (_zoomed) {
      _zoom.value = Matrix4.identity();
      return;
    }
    const scale = 2.5;
    final p = _doubleTap?.localPosition ?? Offset(context.size!.width / 2, context.size!.height / 2);
    _zoom.value = Matrix4.identity()
      ..translateByDouble(-p.dx * (scale - 1), -p.dy * (scale - 1), 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
        _goTo(_index + 1);
      case LogicalKeyboardKey.arrowLeft:
        _goTo(_index - 1);
      case LogicalKeyboardKey.escape:
        Navigator.of(context).maybePop();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;
    return Theme(
      data: buildTheme(Brightness.dark),
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  title: widget.volume.title,
                  counter: _onEndPage ? 'Fin del avance' : '${_index + 1} / ${_images.length}',
                  zoomed: _zoomed,
                  visible: _chrome,
                  onZoom: _onEndPage ? null : _toggleZoom,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pages,
                        itemCount: _count,
                        // Con zoom el gesto sirve para moverse por la página, no para pasarla
                        physics: _zoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
                        onPageChanged: _onPageChanged,
                        itemBuilder: (_, i) => i == _images.length ? _EndPage(volume: widget.volume) : _page(i),
                      ),
                      if (!_zoomed) ...[
                        _Arrow(
                          alignment: Alignment.centerLeft,
                          icon: Icons.arrow_back_rounded,
                          tooltip: 'Página anterior',
                          large: wide,
                          onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                        ),
                        _Arrow(
                          alignment: Alignment.centerRight,
                          icon: Icons.arrow_forward_rounded,
                          tooltip: 'Página siguiente',
                          large: wide,
                          onPressed: _index < _count - 1 ? () => _goTo(_index + 1) : null,
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _chrome ? _thumbStrip() : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _page(int i) {
    final image = Image(
      image: imageProvider(AppConfig.imageUrl(_images[i])),
      fit: BoxFit.contain,
      gaplessPlayback: true,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 48)),
    );
    final content = Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Center(child: image));
    // Solo la página visible lleva el controlador de zoom (se reinicia al cambiar)
    if (i != _index) return content;
    return GestureDetector(
      onTap: () => setState(() => _chrome = !_chrome),
      onDoubleTapDown: (d) => _doubleTap = d,
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _zoom,
        minScale: 1,
        maxScale: 4,
        child: content,
      ),
    );
  }

  Widget _thumbStrip() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 112,
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.separated(
        controller: _thumbs,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _images.length,
        separatorBuilder: (_, __) => const SizedBox(width: _thumbGap),
        itemBuilder: (_, i) {
          final selected = i == _index;
          return Semantics(
            button: true,
            selected: selected,
            label: 'Página ${i + 1}',
            child: GestureDetector(
              onTap: () => _goTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _thumbWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: selected ? scheme.primary : Colors.transparent, width: 2.5),
                ),
                child: Opacity(
                  opacity: selected ? 1 : 0.55,
                  child: CoverImage(_images[i], width: _thumbWidth, height: 92, radius: 4),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.counter, required this.zoomed, required this.visible, this.onZoom});

  final String title;
  final String counter;
  final bool zoomed;
  final bool visible;
  final VoidCallback? onZoom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !visible,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Cerrar',
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('LEER AVANCE',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white54, letterSpacing: 1.2)),
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Text(counter, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              IconButton(
                tooltip: zoomed ? 'Quitar zoom' : 'Ampliar',
                icon: Icon(zoomed ? Icons.zoom_out_rounded : Icons.zoom_in_rounded, color: Colors.white),
                onPressed: onZoom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.alignment, required this.icon, required this.tooltip, required this.large, this.onPressed});

  final Alignment alignment;
  final IconData icon;
  final String tooltip;
  final bool large;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedOpacity(
            opacity: onPressed == null ? 0 : 1,
            duration: const Duration(milliseconds: 150),
            child: IconButton.filledTonal(
              tooltip: tooltip,
              iconSize: large ? 28 : 22,
              style: IconButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
              icon: Icon(icon),
              onPressed: onPressed,
            ),
          ),
        ),
      );
}

/// Última página: invita a comprar el tomo completo.
class _EndPage extends StatelessWidget {
  const _EndPage({required this.volume});
  final Volume volume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartCubit>().state;
    final busy = cart.busyVolume == volume.id;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CoverImage(volume.coverImage, width: 150, height: 214),
            const SizedBox(height: 24),
            Text('¿Quieres seguir leyendo?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('${volume.title} · ${formatPrice(volume.price)}',
                textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70)),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(220, 48)),
              onPressed: volume.soldOut || busy
                  ? null
                  : () => requireLogin(context, () async {
                        try {
                          await context.read<CartCubit>().add(volume);
                          if (context.mounted) showMessage(context, '${volume.title} añadido al carrito');
                        } catch (e) {
                          if (context.mounted) showMessage(context, e.toString(), error: true);
                        }
                      }),
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(volume.soldOut ? 'Agotado' : 'Añadir al carrito'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Volver a la ficha', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
