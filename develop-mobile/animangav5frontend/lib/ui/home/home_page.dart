import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/auth_cubit.dart';
import '../catalog/catalog_page.dart';
import '../catalog/manga_card.dart';
import '../catalog/image_search_page.dart';
import '../widgets/common.dart';

/// Portada de la tienda: buscador, categorías y secciones destacadas.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<(HomeSections, List<Category>)> _future;
  String? _loadedFor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Las recomendaciones dependen del usuario: se recarga al iniciar o cerrar sesión
    final userId = context.watch<AuthCubit>().state.user?.id ?? '';
    if (_loadedFor != userId) {
      _loadedFor = userId;
      _future = _load();
    }
  }

  Future<(HomeSections, List<Category>)> _load() async {
    final repo = context.read<CatalogRepository>();
    final results = await Future.wait([repo.home(), repo.categories()]);
    return (results[0] as HomeSections, results[1] as List<Category>);
  }

  void _openCatalog(CatalogFilter filter, String title) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogPage(initialFilter: filter, title: title)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.select((AuthCubit c) => c.state.user);

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyState(
                icon: Icons.cloud_off,
                title: 'No se pudo cargar la tienda',
                message: snapshot.error.toString(),
                action: 'Reintentar',
                onAction: () => setState(() => _future = _load()),
              );
            }
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final (home, categories) = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _future = _load());
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  ContentWidth(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user == null ? 'Bienvenido a Animanga' : 'Hola, ${user.fullName.split(' ').first}',
                              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                          const SizedBox(height: 4),
                          Text('¿Qué vas a leer hoy?',
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 16),
                          TextField(
                            readOnly: true,
                            onTap: () => _openCatalog(const CatalogFilter(), 'Buscar'),
                            decoration: const InputDecoration(
                              hintText: 'Buscar por título o autor',
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: ImageSearchButton(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (final c in categories)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ActionChip(
                                      label: Text(c.name),
                                      onPressed: () => _openCatalog(CatalogFilter(category: c.name), c.name),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (user != null && home.recommended.isNotEmpty)
                    _Section(
                      title: 'Recomendado para ti',
                      subtitle: 'Según tus favoritos y compras',
                      mangas: home.recommended,
                      onSeeAll: () => _openCatalog(const CatalogFilter(sort: 'rating'), 'Mejor valorados'),
                    ),
                  _Section(
                    title: 'Novedades',
                    mangas: home.latest,
                    onSeeAll: () => _openCatalog(const CatalogFilter(sort: 'newest'), 'Novedades'),
                  ),
                  _Section(
                    title: 'Los más vendidos',
                    mangas: home.bestSellers,
                    onSeeAll: () => _openCatalog(const CatalogFilter(sort: 'bestselling'), 'Más vendidos'),
                  ),
                  _Section(
                    title: 'Mejor valorados',
                    mangas: home.topRated,
                    onSeeAll: () => _openCatalog(const CatalogFilter(sort: 'rating'), 'Mejor valorados'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.mangas, required this.onSeeAll, this.subtitle});

  final String title;
  final String? subtitle;
  final List<MangaSummary> mangas;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (mangas.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return ContentWidth(
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        if (subtitle != null)
                          Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                      ],
                    ),
                  ),
                  TextButton(onPressed: onSeeAll, child: const Text('Ver todo')),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: mangas.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => SizedBox(width: 150, child: MangaCard(manga: mangas[i])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
