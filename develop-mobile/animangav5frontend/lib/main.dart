import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/api_client.dart';
import 'core/theme.dart';
import 'data/repositories.dart';
import 'state/auth_cubit.dart';
import 'state/cart_cubit.dart';
import 'state/favorites_cubit.dart';
import 'state/theme_cubit.dart';
import 'ui/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
  runApp(AnimangaApp(api: ApiClient()));
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (c) => AuthCubit(api, c.read<AuthRepository>())..restore()),
          BlocProvider(create: (_) => ThemeCubit()..restore()),
          BlocProvider(create: (c) => CartCubit(c.read<ShopRepository>())),
          BlocProvider(create: (c) => FavoritesCubit(c.read<CatalogRepository>())),
        ],
        // Al iniciar o cerrar sesión se recargan (o vacían) el carrito y los favoritos
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (a, b) => a.user?.id != b.user?.id,
          listener: (context, state) {
            if (state.isLoggedIn) {
              context.read<CartCubit>().load().ignore();
              context.read<FavoritesCubit>().load();
            } else {
              context.read<CartCubit>().cleared();
              context.read<FavoritesCubit>().clear();
            }
          },
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) => MaterialApp(
              title: 'Animanga',
              debugShowCheckedModeBanner: false,
              theme: buildTheme(Brightness.light),
              darkTheme: buildTheme(Brightness.dark),
              themeMode: mode,
              locale: const Locale('es', 'ES'),
              supportedLocales: const [Locale('es', 'ES')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (a, b) => a.loading != b.loading,
                builder: (context, state) => state.loading
                    ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                    : const HomeShell(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
