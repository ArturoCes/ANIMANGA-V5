import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/api_client.dart';
import 'core/theme.dart';
import 'data/repositories.dart';
import 'state/auth_cubit.dart';
import 'ui/auth/login_page.dart';
import 'ui/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');

  final api = ApiClient();
  runApp(AnimangaApp(api: api));
}

class AnimangaApp extends StatelessWidget {
  const AnimangaApp({super.key, required this.api});

  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: api),
        RepositoryProvider(create: (_) => AuthRepository(api)),
        RepositoryProvider(create: (_) => CatalogRepository(api)),
        RepositoryProvider(create: (_) => ShopRepository(api)),
        RepositoryProvider(create: (_) => ProfileRepository(api)),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(api, context.read<AuthRepository>())..restore(),
        child: MaterialApp(
          title: 'Animanga',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          locale: const Locale('es', 'ES'),
          supportedLocales: const [Locale('es', 'ES')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (prev, next) => prev.runtimeType != next.runtimeType,
            builder: (context, state) => switch (state) {
              AuthLoading() => const Scaffold(body: Center(child: CircularProgressIndicator())),
              Unauthenticated() => const LoginPage(),
              // La clave fuerza a recrear la sesión si cambia de usuario
              Authenticated(:final user) => HomeShell(key: ValueKey(user.id)),
            },
          ),
        ),
      ),
    );
  }
}
