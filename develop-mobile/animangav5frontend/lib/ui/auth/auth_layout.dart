import 'package:flutter/material.dart';

/// Estructura común de login y registro: ilustración a la izquierda en pantallas anchas.
class AuthLayout extends StatelessWidget {
  const AuthLayout(
      {super.key, required this.title, required this.subtitle, required this.child, this.showBack = false});

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final form = SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.png', height: 64, alignment: Alignment.centerLeft),
                const SizedBox(height: 28),
                Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 28),
                child,
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showBack ? AppBar(backgroundColor: Colors.white) : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) return form;
          return Row(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/images/login-art.jpg'), fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(width: 520, child: form),
            ],
          );
        },
      ),
    );
  }
}
