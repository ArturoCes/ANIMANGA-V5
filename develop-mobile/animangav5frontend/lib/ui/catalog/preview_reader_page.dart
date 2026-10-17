import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/cart_cubit.dart';
import '../widgets/common.dart';

void openPreview(BuildContext context, Volume volume) => Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => PreviewReaderPage(volume: volume),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    ));

/// Lo que se ve de una vez: una página (móvil) o dos (libro abierto en pantallas anchas).
/// [far] es la primera en orden de lectura y queda junto al lomo por el lado contrario al que se pasa;
/// [near] es la que se levanta al pasar. `null` = hueco vacío.
class _View {
  const _View({this.far, this.near});
  final int? far;
  final int? near;

  List<int> get pages => [if (far != null) far!, if (near != null) near!]..sort();
}

/// Lector del avance como un tomo de verdad: la página se levanta y gira sobre el lomo,
/// orden japonés (derecha a izquierda) u occidental y doble página en pantallas anchas.
class PreviewReaderPage extends StatefulWidget {
  const PreviewReaderPage({super.key, required this.volume});
  final Volume volume;

  @override
  State<PreviewReaderPage> createState() => _PreviewReaderPageState();
}

class _PreviewReaderPageState extends State<PreviewReaderPage> with SingleTickerProviderStateMixin {
  static const _prefsKey = 'reader.rightToLeft';
  static const _thumbWidth = 64.0;
  static const _thumbGap = 8.0;
  static const _pageAspect = 2 / 3;

  late final AnimationController _turn = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  final _thumbs = ScrollController();
  final _zoom = TransformationController();
  final _focus = FocusNode();

  /// Orden japonés: se avanza hacia la izquierda y la página se pasa desde el lado izquierdo.
  bool _rtl = true;
  bool? _spreadChoice; // null = automático según el ancho
  bool _chrome = true;
  bool _zoomed = false;
  TapDownDetails? _doubleTap;

  int _view = 0;

  /// Paso de página en curso: de la vista [_from] a la [_from] + 1, con [_turn] de 0 a 1.
  int? _from;
  bool _dragging = false;
  double _turnWidth = 1;

  List<String> get _images => widget.volume.previewPages;
  int get _endPage => _images.length; // página final "¿Quieres seguir leyendo?"

  @override
  void initState() {
    super.initState();
    _zoom.addListener(() {
      final zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01;
      if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
    });
    _turn.addListener(() => setState(() {}));
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) setState(() => _rtl = prefs.getBool(_prefsKey) ?? true);
    });
  }

  @override
  void dispose() {
    _turn.dispose();
    _thumbs.dispose();
    _zoom.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ Vistas

  bool _spread(Size size) => _spreadChoice ?? (size.width >= 820 && size.width > size.height * 1.1);

  List<_View> _views(bool spread) {
    if (!spread) return [for (var i = 0; i <= _endPage; i++) _View(far: i)];
    // Como un tomo: la portada sola en el lado que se pasa y después parejas
    final views = <_View>[_View(near: 0)];
    var i = 1;
    while (i < _images.length) {
      final second = i + 1 < _images.length ? i + 1 : null;
      views.add(_View(far: i, near: second));
      i += 2;
    }
    views.add(const _View(far: -1)); // -1 = página final
    return views;
  }

  int _viewOf(List<_View> views, int page) =>
      views.indexWhere((v) => v.far == page || v.near == page).clamp(0, views.length - 1);

  // ------------------------------------------------------------------ Navegación

  void _next(List<_View> views) => _animateTurn(views, forward: true);
  void _previous(List<_View> views) => _animateTurn(views, forward: false);

  Future<void> _animateTurn(List<_View> views, {required bool forward}) async {
    if (_from != null || _zoomed) return;
    if (forward && _view >= views.length - 1) return;
    if (!forward && _view == 0) return;
    setState(() => _from = forward ? _view : _view - 1);
    _turn.value = forward ? 0 : 1;
    await (forward ? _turn.animateTo(1, curve: Curves.easeInOut) : _turn.animateTo(0, curve: Curves.easeInOut));
    _finishTurn(views, completed: true, forward: forward);
  }

  void _finishTurn(List<_View> views, {required bool completed, required bool forward}) {
    final from = _from;
    if (from == null) return;
    setState(() {
      if (completed) _view = forward ? from + 1 : from;
      _from = null;
    });
    _turn.value = 0;
    _afterViewChanged(views);
  }

  void _jumpTo(List<_View> views, int page) {
    if (_from != null) return;
    setState(() => _view = _viewOf(views, page));
    _zoom.value = Matrix4.identity();
    _afterViewChanged(views);
  }

  void _afterViewChanged(List<_View> views) {
    _zoom.value = Matrix4.identity();
    // Precarga de lo que viene para que el giro no muestre huecos
    for (final v in views.skip(_view).take(3)) {
      for (final p in v.pages) {
        if (p >= 0 && p < _images.length) precacheImage(imageProvider(AppConfig.imageUrl(_images[p])), context);
      }
    }
    final first = views[_view].pages.firstOrNull;
    if (_thumbs.hasClients && first != null && first >= 0) {
      final target = first * (_thumbWidth + _thumbGap) - (_thumbs.position.viewportDimension - _thumbWidth) / 2;
      _thumbs.animateTo(target.clamp(0, _thumbs.position.maxScrollExtent),
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  /// Arrastrar hacia el lado contrario al lomo pasa página; soltar a medias la deja caer.
  /// Si el gesto empezó con un dedo y sin zoom, es un arrastre de página (no un pellizco).
  bool _pageGesture = false;

  void _onDragStart(ScaleStartDetails d) {
    _dragging = false;
    _pageGesture = !_zoomed && _from == null && d.pointerCount == 1;
  }

  void _onDragUpdate(List<_View> views, ScaleUpdateDetails d) {
    if (d.pointerCount > 1 || _zoomed) _pageGesture = false;
    if (!_pageGesture) return;
    // En orden japonés se avanza arrastrando hacia la derecha
    final delta = (_rtl ? d.focalPointDelta.dx : -d.focalPointDelta.dx) / _turnWidth;
    if (!_dragging) {
      if (delta == 0) return;
      final forward = delta > 0;
      if (forward && _view >= views.length - 1) return;
      if (!forward && _view == 0) return;
      _dragging = true;
      setState(() => _from = forward ? _view : _view - 1);
      _turn.value = forward ? 0 : 1;
    }
    _turn.value = (_turn.value + delta).clamp(0.0, 1.0);
  }

  Future<void> _onDragEnd(List<_View> views, ScaleEndDetails d) async {
    _pageGesture = false;
    if (!_dragging) return;
    _dragging = false;
    final from = _from!;
    final startedForward = from == _view;
    final velocity = (_rtl ? d.velocity.pixelsPerSecond.dx : -d.velocity.pixelsPerSecond.dx) / _turnWidth;
    final toEnd = velocity.abs() > 1.2 ? velocity > 0 : _turn.value > 0.5;
    await _turn.animateTo(toEnd ? 1 : 0, curve: Curves.easeOut, duration: const Duration(milliseconds: 260));
    // Hacia delante se completa al llegar a 1; hacia atrás, al llegar a 0
    final completed = startedForward ? toEnd : !toEnd;
    _finishTurn(views, completed: completed, forward: startedForward);
  }

  void _toggleZoom() {
    if (_zoomed) {
      _zoom.value = Matrix4.identity();
      return;
    }
    const scale = 2.5;
    final size = context.size!;
    final p = _doubleTap?.localPosition ?? Offset(size.width / 2, size.height / 2);
    _zoom.value = Matrix4.identity()
      ..translateByDouble(-p.dx * (scale - 1), -p.dy * (scale - 1), 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  Future<void> _toggleDirection() async {
    setState(() => _rtl = !_rtl);
    (await SharedPreferences.getInstance()).setBool(_prefsKey, _rtl);
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          duration: const Duration(seconds: 2),
          content:
              Text(_rtl ? 'Lectura japonesa: de derecha a izquierda' : 'Lectura occidental: de izquierda a derecha'),
        ));
    }
  }

  KeyEventResult _onKey(List<_View> views, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _rtl ? _next(views) : _previous(views);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _rtl ? _previous(views) : _next(views);
    } else if (key == LogicalKeyboardKey.space) {
      _next(views);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  // ------------------------------------------------------------------ Pintado

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildTheme(Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0B0D),
        body: SafeArea(
          child: LayoutBuilder(builder: (context, outer) {
            final spread = _spread(outer.biggest);
            final views = _views(spread);
            if (_view >= views.length) _view = views.length - 1;
            final current = views[_view];
            final onEnd = current.far == -1 || current.far == _endPage;
            final wide = outer.maxWidth >= 700;
            return Focus(
              focusNode: _focus,
              autofocus: true,
              onKeyEvent: (_, e) => _onKey(views, e),
              child: Column(
                children: [
                  _TopBar(
                    title: widget.volume.title,
                    counter: onEnd ? 'Fin del avance' : _counter(current),
                    visible: _chrome,
                    rtl: _rtl,
                    zoomed: _zoomed,
                    spread: spread,
                    canSpread: outer.maxWidth >= 600,
                    onDirection: _toggleDirection,
                    onSpread: () => setState(() {
                      final first = current.pages.where((p) => p >= 0).firstOrNull ?? _endPage;
                      _spreadChoice = !spread;
                      final next = _views(!spread);
                      _view = _viewOf(next, first);
                    }),
                    onZoom: onEnd ? null : _toggleZoom,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(child: _book(views, spread)),
                        if (!_zoomed) ...[
                          _Arrow(
                            alignment: Alignment.centerLeft,
                            icon: Icons.arrow_back_rounded,
                            tooltip: _rtl ? 'Página siguiente' : 'Página anterior',
                            large: wide,
                            onPressed: (_rtl ? _view < views.length - 1 : _view > 0)
                                ? () => _rtl ? _next(views) : _previous(views)
                                : null,
                          ),
                          _Arrow(
                            alignment: Alignment.centerRight,
                            icon: Icons.arrow_forward_rounded,
                            tooltip: _rtl ? 'Página anterior' : 'Página siguiente',
                            large: wide,
                            onPressed: (_rtl ? _view > 0 : _view < views.length - 1)
                                ? () => _rtl ? _previous(views) : _next(views)
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _chrome ? _thumbStrip(views) : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  String _counter(_View v) {
    final pages = v.pages.where((p) => p >= 0 && p < _images.length).map((p) => p + 1).toList();
    final label = pages.length == 2 ? '${pages[0]}-${pages[1]}' : '${pages.firstOrNull ?? ''}';
    return '$label / ${_images.length}';
  }

  /// El libro: tamaño de página según el hueco y, encima, la hoja que se está pasando.
  Widget _book(List<_View> views, bool spread) {
    return LayoutBuilder(builder: (context, c) {
      const pad = 12.0;
      final maxW = (c.maxWidth - pad * 2) / (spread ? 2 : 1);
      final maxH = c.maxHeight - pad * 2;
      final pageW = math.min(maxW, maxH * _pageAspect);
      final pageH = pageW / _pageAspect;
      final page = Size(pageW, pageH);
      _turnWidth = pageW * (spread ? 2 : 1);

      final book = SizedBox(
        width: pageW * (spread ? 2 : 1),
        height: pageH,
        child: _from == null ? _static(views[_view], page, spread) : _turning(views, page, spread),
      );

      final turning = _from != null;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: turning || _zoomed ? null : (d) => _onTap(views, d.localPosition.dx, c.maxWidth),
        onDoubleTapDown: (d) => _doubleTap = d,
        onDoubleTap: _toggleZoom,
        child: InteractiveViewer(
          transformationController: _zoom,
          minScale: 1,
          maxScale: 4,
          panEnabled: _zoomed,
          // El visor de zoom recibe todos los gestos: con un dedo y sin zoom se usan para pasar página
          onInteractionStart: _onDragStart,
          onInteractionUpdate: (d) => _onDragUpdate(views, d),
          onInteractionEnd: (d) => _onDragEnd(views, d),
          child: Center(child: book),
        ),
      );
    });
  }

  /// Toque en el borde: pasa página como en los lectores de manga; en el centro, oculta los controles.
  void _onTap(List<_View> views, double x, double width) {
    if (x < width * 0.28) {
      _rtl ? _next(views) : _previous(views);
    } else if (x > width * 0.72) {
      _rtl ? _previous(views) : _next(views);
    } else {
      setState(() => _chrome = !_chrome);
    }
  }

  /// Posición horizontal de un lado del libro (el lado que se pasa es el izquierdo en orden japonés).
  double _left(bool near, Size page, bool spread) {
    if (!spread) return 0;
    final nearOnLeft = _rtl;
    return (near == nearOnLeft) ? 0 : page.width;
  }

  Widget _static(_View v, Size page, bool spread) {
    if (!spread) return _sheet(v.far, page);
    return Stack(children: [
      Positioned(left: _left(false, page, true), top: 0, child: _sheet(v.far, page)),
      Positioned(left: _left(true, page, true), top: 0, child: _sheet(v.near, page)),
      _spine(page),
    ]);
  }

  /// Paso de página de la vista A a la B con t = 0..1.
  /// Una página: A gira sobre su lomo hasta ponerse de canto y deja ver B debajo.
  /// Doble página: la hoja "near" de A gira 90º hasta el lomo y sigue cayendo como la "far" de B.
  Widget _turning(List<_View> views, Size page, bool spread) {
    final a = views[_from!];
    final b = views[_from! + 1];
    final t = _turn.value;

    if (!spread) {
      return Stack(children: [
        _sheet(b.far, page),
        // Sombra que proyecta la hoja que se levanta
        Positioned.fill(child: IgnorePointer(child: ColoredBox(color: Colors.black.withValues(alpha: 0.45 * (1 - t))))),
        _rotating(_sheet(a.far, page), angle: t * math.pi / 2, pivotOnLeft: !_rtl),
      ]);
    }

    final nearLeft = _left(true, page, true);
    final farLeft = _left(false, page, true);
    // El lomo de la hoja "near" está en su lado interior
    final nearPivotLeft = nearLeft > 0; // si está a la derecha, gira sobre su borde izquierdo
    final firstHalf = t < 0.5;
    return Stack(children: [
      Positioned(left: farLeft, top: 0, child: _sheet(a.far, page)),
      Positioned(left: nearLeft, top: 0, child: _sheet(b.near, page)),
      Positioned(
          left: nearLeft,
          top: 0,
          child: IgnorePointer(
              child: SizedBox.fromSize(
                  size: page,
                  child: ColoredBox(color: Colors.black.withValues(alpha: firstHalf ? 0.4 * (1 - t * 2) : 0))))),
      Positioned(
        left: farLeft,
        top: 0,
        child: IgnorePointer(
            child: SizedBox.fromSize(
                size: page,
                child: ColoredBox(color: Colors.black.withValues(alpha: firstHalf ? 0 : 0.4 * (t - 0.5) * 2)))),
      ),
      _spine(page),
      if (firstHalf)
        Positioned(
          left: nearLeft,
          top: 0,
          child: _rotating(_sheet(a.near, page), angle: t * math.pi, pivotOnLeft: nearPivotLeft),
        )
      else
        Positioned(
          left: farLeft,
          top: 0,
          child: _rotating(_sheet(b.far, page), angle: (1 - t) * math.pi, pivotOnLeft: !nearPivotLeft),
        ),
    ]);
  }

  /// Gira una hoja sobre el eje vertical de uno de sus bordes, con perspectiva y sombreado.
  Widget _rotating(Widget sheet, {required double angle, required bool pivotOnLeft}) {
    final a = angle.clamp(0.0, math.pi / 2);
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0011)
      ..rotateY(pivotOnLeft ? -a : a);
    return Transform(
      alignment: pivotOnLeft ? Alignment.centerLeft : Alignment.centerRight,
      transform: transform,
      child: Stack(children: [
        sheet,
        // Cuanto más de canto, más oscura: da sensación de papel que se curva
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: pivotOnLeft ? Alignment.centerLeft : Alignment.centerRight,
                  end: pivotOnLeft ? Alignment.centerRight : Alignment.centerLeft,
                  colors: [
                    Colors.black.withValues(alpha: 0.05 + 0.25 * math.sin(a)),
                    Colors.black.withValues(alpha: 0.55 * math.sin(a)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _spine(Size page) => Positioned(
        left: page.width - 14,
        top: 0,
        child: IgnorePointer(
          child: Container(
            width: 28,
            height: page.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.28),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      );

  /// Una hoja de papel: la imagen de la página, la página final o un hueco vacío.
  Widget _sheet(int? index, Size size) {
    Widget child;
    if (index == null) {
      return SizedBox.fromSize(size: size);
    } else if (index == -1 || index == _endPage) {
      child = _EndPage(volume: widget.volume);
    } else {
      child = Image(
        image: imageProvider(AppConfig.imageUrl(_images[index])),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image_outlined, color: Colors.black38, size: 48)),
      );
    }
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: index == -1 || index == _endPage ? const Color(0xFF17151C) : const Color(0xFFF7F4EE),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }

  Widget _thumbStrip(List<_View> views) {
    final scheme = Theme.of(context).colorScheme;
    final visible = views[_view].pages.toSet();
    return Container(
      height: 112,
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.separated(
        controller: _thumbs,
        scrollDirection: Axis.horizontal,
        // En orden japonés la página 1 queda a la derecha, como en el tomo
        reverse: _rtl,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _images.length,
        separatorBuilder: (_, __) => const SizedBox(width: _thumbGap),
        itemBuilder: (_, i) {
          final selected = visible.contains(i);
          return Semantics(
            button: true,
            selected: selected,
            label: 'Página ${i + 1}',
            child: GestureDetector(
              onTap: () => _jumpTo(views, i),
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
  const _TopBar({
    required this.title,
    required this.counter,
    required this.visible,
    required this.rtl,
    required this.zoomed,
    required this.spread,
    required this.canSpread,
    required this.onDirection,
    required this.onSpread,
    this.onZoom,
  });

  final String title;
  final String counter;
  final bool visible;
  final bool rtl;
  final bool zoomed;
  final bool spread;
  final bool canSpread;
  final VoidCallback onDirection;
  final VoidCallback onSpread;
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
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Cerrar',
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('LEER AVANCE · $counter',
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white54, letterSpacing: 1.1)),
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Tooltip(
                message: rtl ? 'Lectura japonesa (derecha a izquierda)' : 'Lectura occidental (izquierda a derecha)',
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8)),
                  onPressed: onDirection,
                  icon: Icon(rtl ? Icons.arrow_back : Icons.arrow_forward, size: 18),
                  label: Text(rtl ? '日本' : 'ES'),
                ),
              ),
              if (canSpread)
                Tooltip(
                  message: spread ? 'Ver una página' : 'Ver doble página, como un libro abierto',
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    onPressed: onSpread,
                    child: Text(spread ? '2 págs.' : '1 pág.'),
                  ),
                ),
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
  const _Arrow(
      {required this.alignment, required this.icon, required this.tooltip, required this.large, this.onPressed});

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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CoverImage(volume.coverImage, width: 120, height: 172),
            const SizedBox(height: 20),
            Text('¿Quieres seguir leyendo?',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('${volume.title} · ${formatPrice(volume.price)}',
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(200, 46)),
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
            const SizedBox(height: 6),
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
