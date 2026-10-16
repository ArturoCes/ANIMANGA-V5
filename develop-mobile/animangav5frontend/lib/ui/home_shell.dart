import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories.dart';
import '../state/auth_cubit.dart';
import '../state/cart_cubit.dart';
import 'auth/reset_password_page.dart';
import 'cart/cart_page.dart';
import 'catalog/catalog_page.dart';
import 'favorites/favorites_page.dart';
import 'home/home_page.dart';
import 'profile/profile_page.dart';
import 'widgets/common.dart';

/// Pantalla principal con navegación inferior (o lateral en pantallas anchas).
/// Se puede usar sin cuenta: favoritos, carrito y perfil piden iniciar sesión.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// Permite que otras pantallas cambien de pestaña (p. ej. "Ver todo" → catálogo).
  static void goTo(BuildContext context, int tab) => context.findAncestorStateOfType<_HomeShellState>()?._select(tab);

  static const tabHome = 0;
  static const tabCatalog = 1;
  static const tabCart = 3;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [HomePage(), CatalogPage(), FavoritesPage(), CartPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleLinks());
  }

  /// Enlaces de los emails: /?verify=TOKEN y /?reset=TOKEN (web).
  Future<void> _handleLinks() async {
    if (!kIsWeb) return;
    final params = Uri.base.queryParameters;
    final verify = params['verify'];
    final reset = params['reset'];
    if (verify != null) {
      try {
        final user = await context.read<AuthRepository>().verifyEmail(verify);
        if (!mounted) return;
        final auth = context.read<AuthCubit>();
        if (auth.user?.id == user.id) await auth.updateUser(user);
        if (mounted) showMessage(context, '¡Email confirmado! Gracias, ${user.fullName.split(' ').first}.');
      } catch (e) {
        if (mounted) showMessage(context, e.toString(), error: true);
      }
    } else if (reset != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResetPasswordPage(token: reset)));
    }
  }

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final message = context.select((AuthCubit c) => c.state.message);
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMessage(context, message);
        context.read<AuthCubit>().consumeMessage();
      });
    }

    final count = context.select((CartCubit c) => c.state.cart.totalItems);
    Widget cartIcon(bool selected) => Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: Icon(selected ? Icons.shopping_bag : Icons.shopping_bag_outlined),
        );
    final destinations = [
      (const Icon(Icons.home_outlined), const Icon(Icons.home), 'Inicio'),
      (const Icon(Icons.search), const Icon(Icons.manage_search), 'Catálogo'),
      (const Icon(Icons.favorite_border), const Icon(Icons.favorite), 'Favoritos'),
      (cartIcon(false), cartIcon(true), 'Carrito'),
      (const Icon(Icons.person_outline), const Icon(Icons.person), 'Perfil'),
    ];
    final body = IndexedStack(index: _index, children: _pages);

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 900) {
        return Scaffold(
          body: Row(children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.asset('assets/images/logo-mark.png', width: 40),
              ),
              destinations: [
                for (final (icon, selected, label) in destinations)
                  NavigationRailDestination(icon: icon, selectedIcon: selected, label: Text(label)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ]),
        );
      }
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            for (final (icon, selected, label) in destinations)
              NavigationDestination(icon: icon, selectedIcon: selected, label: label),
          ],
        ),
      );
    });
  }
}
