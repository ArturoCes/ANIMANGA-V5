import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories.dart';
import '../state/auth_cubit.dart';
import '../state/cart_cubit.dart';
import '../state/favorites_cubit.dart';
import 'cart/cart_page.dart';
import 'catalog/catalog_page.dart';
import 'favorites/favorites_page.dart';
import 'profile/profile_page.dart';

/// Pantalla principal tras iniciar sesión. Crea los cubits ligados al usuario.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().user!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CartCubit(context.read<ShopRepository>(), user)..load().ignore()),
        BlocProvider(create: (context) => FavoritesCubit(context.read<CatalogRepository>(), user)..load()),
      ],
      child: const _ShellView(),
    );
  }
}

class _ShellView extends StatefulWidget {
  const _ShellView();

  @override
  State<_ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<_ShellView> {
  int _index = 0;

  static const _pages = [CatalogPage(), FavoritesPage(), CartPage(), ProfilePage()];

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select((CartCubit c) => c.state.count);
    final cartIcon = Badge(
      isLabelVisible: cartCount > 0,
      label: Text('$cartCount'),
      child: const Icon(Icons.shopping_bag_outlined),
    );
    final cartIconSelected = Badge(
      isLabelVisible: cartCount > 0,
      label: Text('$cartCount'),
      child: const Icon(Icons.shopping_bag),
    );
    final body = IndexedStack(index: _index, children: _pages);

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 900) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _select,
                labelType: NavigationRailLabelType.all,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset('assets/images/logo-mark.png', width: 40),
                ),
                destinations: [
                  const NavigationRailDestination(
                      icon: Icon(Icons.auto_stories_outlined),
                      selectedIcon: Icon(Icons.auto_stories),
                      label: Text('Tienda')),
                  const NavigationRailDestination(
                      icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: Text('Favoritos')),
                  NavigationRailDestination(
                      icon: cartIcon, selectedIcon: cartIconSelected, label: const Text('Carrito')),
                  const NavigationRailDestination(
                      icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Perfil')),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        );
      }
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            const NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories), label: 'Tienda'),
            const NavigationDestination(
                icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
            NavigationDestination(icon: cartIcon, selectedIcon: cartIconSelected, label: 'Carrito'),
            const NavigationDestination(
                icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      );
    });
  }
}
