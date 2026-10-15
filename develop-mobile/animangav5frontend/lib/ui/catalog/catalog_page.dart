import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/auth_cubit.dart';
import '../widgets/common.dart';
import 'manga_card.dart';

/// Catálogo con búsqueda por título y filtro por categoría.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _search = TextEditingController();
  Timer? _debounce;

  List<Category> _categories = [];
  String? _category;
  List<Manga> _mangas = [];
  bool _loading = true;
  String? _error;

  CatalogRepository get _repo => context.read<CatalogRepository>();

  @override
  void initState() {
    super.initState();
    _repo.categories().then((c) => mounted ? setState(() => _categories = c) : null).catchError((_) {});
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final term = _search.text.trim();
      final page = term.isNotEmpty
          ? await _repo.search(term, size: 60)
          : _category != null
              ? await _repo.byCategory(_category!, size: 60)
              : await _repo.mangas(size: 60);
      var mangas = page.content;
      // La búsqueda por texto y la categoría se combinan en cliente
      if (term.isNotEmpty && _category != null) {
        mangas = mangas.where((m) => m.categories.any((c) => c.name == _category)).toList();
      }
      if (mounted) setState(() => _mangas = mangas);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit c) => c.user);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola, ${user?.fullName.split(' ').first ?? ''} 👋',
                            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                        const SizedBox(height: 4),
                        Text('¿Qué vas a leer hoy?',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _search,
                          onChanged: _onSearch,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Buscar por título',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Limpiar',
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _search.clear();
                                      _load();
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _CategoryChip(
                                label: 'Todos',
                                selected: _category == null,
                                onTap: () {
                                  setState(() => _category = null);
                                  _load();
                                },
                              ),
                              for (final c in _categories)
                                _CategoryChip(
                                  label: c.name,
                                  selected: _category == c.name,
                                  onTap: () {
                                    setState(() => _category = _category == c.name ? null : c.name);
                                    _load();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                      icon: Icons.cloud_off,
                      title: 'No se pudo cargar el catálogo',
                      message: _error,
                      action: 'Reintentar',
                      onAction: _load),
                )
              else if (_mangas.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                      icon: Icons.search_off, title: 'Sin resultados', message: 'Prueba con otro título o categoría.'),
                )
              else
                SliverLayoutBuilder(builder: (context, constraints) {
                  // Mismo ancho máximo y margen que la cabecera (ContentWidth)
                  final total = constraints.crossAxisExtent;
                  final side = total > 1100 ? (total - 1100) / 2 + 20 : 20.0;
                  final columns = ((total - side * 2) / 190).floor().clamp(2, 6);
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(side, 8, side, 24),
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.52,
                      ),
                      itemCount: _mangas.length,
                      itemBuilder: (_, i) => MangaCard(manga: _mangas[i]),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
      );
}
