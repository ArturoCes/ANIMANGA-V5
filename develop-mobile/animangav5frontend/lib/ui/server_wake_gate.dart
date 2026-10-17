import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../core/theme.dart';

/// La demo usa el plan gratuito de Render, que duerme la API tras un rato sin visitas.
/// Antes de arrancar la app se comprueba que la API responde; si tarda, se explica que se está despertando.
/// La app (sesión, carrito, portada…) no se crea hasta que la API contesta, así nada falla por el camino.
class ServerWakeGate extends StatefulWidget {
  const ServerWakeGate({super.key, required this.child});
  final Widget child;

  @override
  State<ServerWakeGate> createState() => _ServerWakeGateState();
}

enum _Wake { checking, waking, ready }

class _ServerWakeGateState extends State<ServerWakeGate> {
  _Wake _state = _Wake.checking;
  final _started = DateTime.now();
  Timer? _ticker;
  Timer? _showAfter;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    // Solo se avisa si la primera respuesta tarda: con el servidor despierto no se ve nada
    _showAfter = Timer(const Duration(milliseconds: 1500), () {
      if (_state == _Wake.checking) setState(() => _state = _Wake.waking);
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state == _Wake.waking) setState(() {});
    });
    _poll();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    _showAfter?.cancel();
    super.dispose();
  }

  /// Reintenta hasta que la API conteste (el proxy de Netlify corta las peticiones largas).
  Future<void> _poll() async {
    final url = Uri.parse('${AppConfig.apiUrl}/actuator/health');
    while (!_disposed) {
      try {
        final res = await http.get(url).timeout(const Duration(seconds: 15));
        if (res.statusCode == 200) break;
      } catch (_) {
        // dormida o arrancando: se vuelve a intentar
      }
      await Future<void>.delayed(const Duration(seconds: 3));
    }
    if (_disposed) return;
    _ticker?.cancel();
    _showAfter?.cancel();
    setState(() => _state = _Wake.ready);
  }

  @override
  Widget build(BuildContext context) {
    if (_state == _Wake.ready) return widget.child;
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(brightness),
      home: Scaffold(
        body: Center(
          child: _state == _Wake.checking
              ? const CircularProgressIndicator()
              : _WakingCard(seconds: DateTime.now().difference(_started).inSeconds),
        ),
      ),
    );
  }
}

class _WakingCard extends StatelessWidget {
  const _WakingCard({required this.seconds});
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bedtime_outlined, size: 42, color: scheme.primary),
                const SizedBox(height: 12),
                Text('Despertando el servidor…',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                  'Esta demo está en un servidor gratuito que se duerme cuando nadie la usa. '
                  'La primera vez tarda hasta un minuto en arrancar; después va normal.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.outline, height: 1.45),
                ),
                const SizedBox(height: 20),
                ClipRRect(borderRadius: BorderRadius.circular(99), child: const LinearProgressIndicator(minHeight: 5)),
                const SizedBox(height: 10),
                Text('$seconds s', style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
