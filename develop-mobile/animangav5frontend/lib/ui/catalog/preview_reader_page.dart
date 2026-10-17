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
  static const _hintKey = 'reader.hintShown';
  static const _thumbWidth = 40.0;
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
  bool _hint = false; // ayuda de "desliza para pasar página" la primera vez
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
      if (!mounted) return;
      final firstTime = !(prefs.getBool(_hintKey) ?? false);
      setState(() {
        _rtl = prefs.getBool(_prefsKey) ?? true;
        _hint = firstTime;
      });
      if (firstTime) {
        prefs.setBool(_hintKey, true);
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _hint = false);
        });
      }
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
      _hint = false;
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

  static const _paper = Color(0xFFFBF8F1);
  static const _topInset = 64.0;
  static const _bottomInset = 104.0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildTheme(Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0B10),
        body: DecoratedBox(
          // Luz de lectura: el centro más claro y los bordes en penumbra
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.1),
              radius: 1.1,
              colors: [Color(0xFF2E2838), Color(0xFF15131B), Color(0xFF0A090D)],
              stops: [0, 0.55, 1],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(builder: (context, outer) {
              final spread = _spread(outer.biggest);
              final views = _views(spread);
              if (_view >= views.length) _view = views.length - 1;
              final current = views[_view];
              final onEnd = current.far == -1 || current.far == _endPage;
              final wide = outer.maxWidth >= 700;
              final progress = views.length <= 1 ? 1.0 : _view / (views.length - 1);
              return Focus(
                focusNode: _focus,
                autofocus: true,
                onKeyEvent: (_, e) => _onKey(views, e),
                child: Stack(
                  children: [
                    // Sin controles la página crece hasta ocupar la pantalla (modo inmersivo)
                    Positioned.fill(
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.only(top: _chrome ? _topInset : 8, bottom: _chrome ? _bottomInset : 8),
                        child: _book(views, spread),
                      ),
                    ),
                    if (wide && !_zoomed) ...[
                      _Arrow(
                        alignment: Alignment.centerLeft,
                        icon: Icons.arrow_back_rounded,
                        tooltip: _rtl ? 'Página siguiente' : 'Página anterior',
                        onPressed: (_rtl ? _view < views.length - 1 : _view > 0)
                            ? () => _rtl ? _next(views) : _previous(views)
                            : null,
                      ),
                      _Arrow(
                        alignment: Alignment.centerRight,
                        icon: Icons.arrow_forward_rounded,
                        tooltip: _rtl ? 'Página anterior' : 'Página siguiente',
                        onPressed: (_rtl ? _view > 0 : _view < views.length - 1)
                            ? () => _rtl ? _previous(views) : _next(views)
                            : null,
                      ),
                    ],
                    _Slide(
                      visible: _chrome,
                      fromTop: true,
                      child: _TopBar(
                        title: widget.volume.title,
                        counter: onEnd ? 'Fin del avance' : 'Página ${_counter(current)}',
                        progress: progress,
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
                    ),
                    _Slide(visible: _chrome, fromTop: false, child: _thumbStrip(views)),
                    if (_hint) _Hint(rtl: _rtl, onClose: () => setState(() => _hint = false)),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String _counter(_View v) {
    final pages = v.pages.where((p) => p >= 0 && p < _images.length).map((p) => p + 1).toList();
    final label = pages.length == 2 ? '${pages[0]}-${pages[1]}' : '${pages.firstOrNull ?? ''}';
    return '$label de ${_images.length}';
  }

  /// El libro: tamaño de página según el hueco y, encima, la hoja que se está pasando.
  Widget _book(List<_View> views, bool spread) {
    return LayoutBuilder(builder: (context, c) {
      const pad = 16.0;
      final maxW = (c.maxWidth - pad * 2 - 12) / (spread ? 2 : 1);
      final maxH = c.maxHeight - pad * 2;
      final pageW = math.max(1.0, math.min(maxW, maxH * _pageAspect));
      final pageH = pageW / _pageAspect;
      final page = Size(pageW, pageH);
      _turnWidth = pageW * (spread ? 2 : 1);
      final bookW = pageW * (spread ? 2 : 1);
      // En doble página puede haber un lado vacío (portada sola o página final): ahí no hay sombra ni canto
      var hasLeft = true, hasRight = true;
      if (spread) {
        final shown = [views[_view], if (_from != null) views[_from!], if (_from != null) views[_from! + 1]];
        bool occupied(bool left) => shown.any((v) =>
            (v.far != null && (_left(false, page, true) == 0) == left) ||
            (v.near != null && (_left(true, page, true) == 0) == left));
        hasLeft = occupied(true);
        hasRight = occupied(false);
      }

      final book = Stack(
        clipBehavior: Clip.none,
        children: [
          // Sombra del tomo sobre la mesa
          Positioned(
            left: hasLeft ? 10 : pageW + 10,
            right: hasRight ? 10 : pageW + 10,
            top: 14,
            bottom: -6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Color(0xAA000000), blurRadius: 42, offset: Offset(0, 22)),
                  BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
            ),
          ),
          ..._pageEdges(views, page, spread, hasLeft: hasLeft, hasRight: hasRight),
          SizedBox(
            width: bookW,
            height: pageH,
            child: _from == null ? _static(views[_view], page, spread) : _turning(views, page, spread),
          ),
        ],
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
          child: Center(child: SizedBox(width: bookW, height: pageH, child: book)),
        ),
      );
    });
  }

  /// Canto del tomo: finas capas de papel a cada lado según las páginas que quedan por leer y las leídas.
  List<Widget> _pageEdges(List<_View> views, Size page, bool spread, {bool hasLeft = true, bool hasRight = true}) {
    final total = math.max(1, views.length - 1);
    final read = (_view / total).clamp(0.0, 1.0);
    // En orden japonés lo leído se acumula a la derecha
    final leftShare = _rtl ? 1 - read : read;
    final rightShare = 1 - leftShare;
    Widget edge({required bool left, required double share}) {
      final layers = (share * 4).ceil().clamp(0, 4);
      return Positioned(
        left: left ? 0 : null,
        right: left ? null : 0,
        top: 0,
        bottom: 0,
        child: Stack(clipBehavior: Clip.none, children: [
          for (var i = layers; i >= 1; i--)
            Transform.translate(
              offset: Offset((left ? -1.6 : 1.6) * i, 1.0 * i),
              child: Container(
                width: page.width,
                height: page.height,
                decoration: BoxDecoration(
                  color: Color.lerp(_paper, const Color(0xFFBDB6A8), i / 5),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(left ? 3 : 0),
                    right: Radius.circular(left ? 0 : 3),
                  ),
                ),
              ),
            ),
        ]),
      );
    }

    if (!spread) return [edge(left: _rtl, share: 1 - read)];
    return [
      if (hasLeft) edge(left: true, share: leftShare),
      if (hasRight) edge(left: false, share: rightShare),
    ];
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

  /// ¿El lomo de una hoja en la posición x queda a su izquierda?
  bool _spineOnLeft(double left, bool spread) => spread ? left > 0 : _rtl == false;

  Widget _static(_View v, Size page, bool spread) {
    if (!spread) return _sheet(v.far, page, spineOnLeft: !_rtl);
    final farLeft = _left(false, page, true);
    final nearLeft = _left(true, page, true);
    return Stack(children: [
      Positioned(left: farLeft, top: 0, child: _sheet(v.far, page, spineOnLeft: _spineOnLeft(farLeft, true))),
      Positioned(left: nearLeft, top: 0, child: _sheet(v.near, page, spineOnLeft: _spineOnLeft(nearLeft, true))),
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
      final spineLeft = !_rtl;
      return Stack(children: [
        _sheet(b.far, page, spineOnLeft: spineLeft),
        // Sombra que la hoja levantada proyecta sobre la siguiente, más intensa junto al lomo
        _castShadow(page, fromLeft: spineLeft, strength: 1 - t),
        _rotating(_sheet(a.far, page, spineOnLeft: spineLeft), angle: t * math.pi / 2, pivotOnLeft: spineLeft),
      ]);
    }

    final nearLeft = _left(true, page, true);
    final farLeft = _left(false, page, true);
    final nearPivotLeft = _spineOnLeft(nearLeft, true);
    final firstHalf = t < 0.5;
    return Stack(children: [
      Positioned(left: farLeft, top: 0, child: _sheet(a.far, page, spineOnLeft: !nearPivotLeft)),
      Positioned(left: nearLeft, top: 0, child: _sheet(b.near, page, spineOnLeft: nearPivotLeft)),
      if (firstHalf)
        Positioned(
          left: nearLeft,
          top: 0,
          child: _castShadow(page, fromLeft: nearPivotLeft, strength: 1 - t * 2),
        )
      else
        Positioned(
          left: farLeft,
          top: 0,
          child: _castShadow(page, fromLeft: !nearPivotLeft, strength: (t - 0.5) * 2),
        ),
      if (firstHalf)
        Positioned(
          left: nearLeft,
          top: 0,
          child: _rotating(_sheet(a.near, page, spineOnLeft: nearPivotLeft),
              angle: t * math.pi, pivotOnLeft: nearPivotLeft),
        )
      else
        Positioned(
          left: farLeft,
          top: 0,
          child: _rotating(_sheet(b.far, page, spineOnLeft: !nearPivotLeft),
              angle: (1 - t) * math.pi, pivotOnLeft: !nearPivotLeft),
        ),
    ]);
  }

  Widget _castShadow(Size page, {required bool fromLeft, required double strength}) => IgnorePointer(
        child: SizedBox.fromSize(
          size: page,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: fromLeft ? Alignment.centerLeft : Alignment.centerRight,
                end: fromLeft ? Alignment.centerRight : Alignment.centerLeft,
                colors: [
                  Colors.black.withValues(alpha: 0.55 * strength),
                  Colors.black.withValues(alpha: 0.15 * strength),
                ],
              ),
            ),
          ),
        ),
      );

  /// Gira una hoja sobre el eje vertical de uno de sus bordes, con perspectiva, sombra y un brillo
  /// en el borde libre que imita el papel curvándose.
  Widget _rotating(Widget sheet, {required double angle, required bool pivotOnLeft}) {
    final a = angle.clamp(0.0, math.pi / 2);
    final lift = math.sin(a);
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateY(pivotOnLeft ? -a : a);
    final fromSpine = pivotOnLeft ? Alignment.centerLeft : Alignment.centerRight;
    final toEdge = pivotOnLeft ? Alignment.centerRight : Alignment.centerLeft;
    return Transform(
      alignment: fromSpine,
      transform: transform,
      child: Stack(children: [
        sheet,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: fromSpine,
                  end: toEdge,
                  stops: const [0, 0.7, 0.86, 1],
                  colors: [
                    Colors.black.withValues(alpha: 0.35 * lift),
                    Colors.black.withValues(alpha: 0.12 * lift),
                    Colors.white.withValues(alpha: 0.22 * lift),
                    Colors.black.withValues(alpha: 0.25 * lift),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  /// Una hoja de papel: la imagen de la página, la página final o un hueco vacío.
  /// Junto al lomo lleva la sombra del pliegue, como un tomo abierto.
  Widget _sheet(int? index, Size size, {required bool spineOnLeft}) {
    if (index == null) return SizedBox.fromSize(size: size);
    final end = index == -1 || index == _endPage;
    final radius = BorderRadius.horizontal(
      left: Radius.circular(spineOnLeft ? 0 : 4),
      right: Radius.circular(spineOnLeft ? 4 : 0),
    );
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size.width,
        height: size.height,
        color: end ? null : _paper,
        child: end
            ? _EndPage(volume: widget.volume)
            : Stack(fit: StackFit.expand, children: [
                Image(
                  image: imageProvider(AppConfig.imageUrl(_images[index])),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  // Mezcla la página con el tono del papel para que no parezca una pantalla en blanco puro
                  color: _paper,
                  colorBlendMode: BlendMode.multiply,
                  frameBuilder: (_, child, frame, sync) => sync || frame != null
                      ? child
                      : const Center(
                          child: SizedBox.square(
                              dimension: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black26))),
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image_outlined, color: Colors.black26, size: 44)),
                ),
                // Pliegue del lomo
                Positioned(
                  left: spineOnLeft ? 0 : null,
                  right: spineOnLeft ? null : 0,
                  top: 0,
                  bottom: 0,
                  width: size.width * 0.09,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: spineOnLeft ? Alignment.centerLeft : Alignment.centerRight,
                          end: spineOnLeft ? Alignment.centerRight : Alignment.centerLeft,
                          colors: [Colors.black.withValues(alpha: 0.30), Colors.black.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
      ),
    );
  }

  Widget _thumbStrip(List<_View> views) {
    final scheme = Theme.of(context).colorScheme;
    final visible = views[_view].pages.toSet();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 96,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          color: const Color(0xCC17151D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Center(
          child: ListView.separated(
            controller: _thumbs,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            // En orden japonés la página 1 queda a la derecha, como en el tomo
            reverse: _rtl,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            itemCount: _images.length,
            separatorBuilder: (_, __) => const SizedBox(width: _thumbGap),
            itemBuilder: (_, i) {
              final selected = visible.contains(i);
              return Semantics(
                button: true,
                selected: selected,
                label: 'Página ${i + 1}',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _jumpTo(views, i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _thumbWidth,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border:
                                Border.all(color: selected ? scheme.primary : Colors.white12, width: selected ? 2 : 1),
                            boxShadow: selected
                                ? [BoxShadow(color: scheme.primary.withValues(alpha: 0.45), blurRadius: 12)]
                                : const [],
                          ),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: selected ? 1 : 0.5,
                            child: CoverImage(_images[i], width: _thumbWidth, height: 60, radius: 4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                              color: selected ? Colors.white : Colors.white38,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Muestra u oculta los controles deslizándolos fuera de la pantalla.
class _Slide extends StatelessWidget {
  const _Slide({required this.visible, required this.fromTop, required this.child});
  final bool visible;
  final bool fromTop;
  final Widget child;

  @override
  Widget build(BuildContext context) => Positioned(
        left: 0,
        right: 0,
        top: fromTop ? 0 : null,
        bottom: fromTop ? null : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            offset: visible ? Offset.zero : Offset(0, fromTop ? -1.2 : 1.2),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: visible ? 1 : 0,
              child: child,
            ),
          ),
        ),
      );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.counter,
    required this.progress,
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
  final double progress;
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
    final scheme = theme.colorScheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xEE0C0B10), Color(0x000C0B10)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Cerrar',
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 1),
                    Text('Avance · $counter',
                        maxLines: 1, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60)),
                  ],
                ),
              ),
              _Pill(
                tooltip: rtl
                    ? 'Lectura japonesa (derecha a izquierda). Toca para cambiar'
                    : 'Lectura occidental (izquierda a derecha). Toca para cambiar',
                onPressed: onDirection,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(rtl ? Icons.arrow_back : Icons.arrow_forward, size: 15, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(rtl ? '日本' : 'ES'),
                ]),
              ),
              if (canSpread) ...[
                const SizedBox(width: 6),
                _Pill(
                  tooltip: spread ? 'Ver una página' : 'Ver doble página, como un libro abierto',
                  onPressed: onSpread,
                  child: Text(spread ? '2 págs.' : '1 pág.'),
                ),
              ],
              IconButton(
                tooltip: zoomed ? 'Quitar zoom' : 'Ampliar',
                icon: Icon(zoomed ? Icons.zoom_out_rounded : Icons.zoom_in_rounded, color: Colors.white),
                onPressed: onZoom,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progreso de lectura del avance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: const Duration(milliseconds: 300),
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  minHeight: 3,
                  backgroundColor: Colors.white12,
                  color: scheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.tooltip, required this.onPressed, required this.child});
  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white.withValues(alpha: 0.08),
          shape: const StadiumBorder(side: BorderSide(color: Colors.white24)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                child: child,
              ),
            ),
          ),
        ),
      );
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.alignment, required this.icon, required this.tooltip, this.onPressed});

  final Alignment alignment;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: AnimatedOpacity(
            opacity: onPressed == null ? 0 : 1,
            duration: const Duration(milliseconds: 150),
            child: IconButton(
              tooltip: tooltip,
              iconSize: 26,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                fixedSize: const Size(52, 52),
              ),
              icon: Icon(icon),
              onPressed: onPressed,
            ),
          ),
        ),
      );
}

/// Ayuda que aparece la primera vez: cómo se pasa página y en qué sentido.
class _Hint extends StatelessWidget {
  const _Hint({required this.rtl, required this.onClose});
  final bool rtl;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: GestureDetector(
          onTap: onClose,
          child: ColoredBox(
            color: Colors.black54,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                builder: (_, v, child) =>
                    Transform.scale(scale: 0.9 + 0.1 * v, child: Opacity(opacity: v.clamp(0, 1), child: child)),
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1A24),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_stories_outlined, color: Colors.white, size: 34),
                      const SizedBox(height: 12),
                      const Text('Se lee como un tomo',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        rtl
                            ? 'Orden japonés: desliza hacia la derecha o toca el borde izquierdo para pasar página.'
                            : 'Desliza hacia la izquierda o toca el borde derecho para pasar página.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Text('Toca en el centro para ocultar los controles.',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
                      const SizedBox(height: 14),
                      Icon(rtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded, color: Colors.white54),
                      const SizedBox(height: 8),
                      FilledButton(onPressed: onClose, child: const Text('Entendido')),
                    ],
                  ),
                ),
              ),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.colorScheme.primary.withValues(alpha: 0.35), const Color(0xFF15121B)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('FIN DEL AVANCE',
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.white60, letterSpacing: 2)),
              const SizedBox(height: 14),
              Transform.rotate(
                angle: -0.04,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))],
                  ),
                  child: CoverImage(volume.coverImage, width: 112, height: 160, radius: 8),
                ),
              ),
              const SizedBox(height: 18),
              Text('¿Quieres seguir leyendo?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(volume.title,
                  textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(99)),
                child: Text(formatPrice(volume.price),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(190, 44)),
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
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Volver a la ficha', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
