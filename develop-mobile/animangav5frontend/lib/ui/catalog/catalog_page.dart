import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../widgets/common.dart';
import 'manga_card.dart';

const _sortOptions = {
  'title': 'Título (A-Z)',
  'newest': 'Más recientes',
  'bestselling': 'Más vendidos',
  'rating': 'Mejor valorados',
  'price_asc': 'Precio: de menor a mayor',
  'price_desc': 'Precio: de mayor a menor',
};

/// Catálogo con búsqueda, filtros, ordenación y scroll infinito.
/// Se usa como pestaña y también como pantalla independiente (con un filtro inicial).
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, this.initialFilter = const CatalogFilter(), this.title});

  final CatalogFilter initialFilter;

  /// Si se indica, la página se muestra con barra superior y botón de volver.
  final String? title;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  static const _pageSize = 12;

  late CatalogFilter _filter = widget.initialFilter;
  late final _search = TextEditingController(text: widget.initialFilter.q);
  final _scroll = ScrollController();
  Timer? _debounce;

  final List<MangaSummary> _items = [];
  int _page = 0;
  int _total = 0;
  bool _last = false;
  bool _loading = false;
  String? _error;
  int _request = 0;

  CatalogRepository get _repo => context.read<CatalogRepository>();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) _loadMore();
    });
    _reload();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _items.clear();
      _page = 0;
      _last = false;
      _error = null;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || _last) return;
    final request = ++_request;
    setState(() => _loading = true);
    try {
      final result = await _repo.search(_filter, page: _page, size: _pageSize);
      if (!mounted || request != _request) return; // respuesta de una búsqueda anterior
      setState(() {
        _items.addAll(result.content);
        _total = result.totalElements;
        _last = result.last;
        _page++;
      });
    } catch (e) {
      if (mounted && request == _request) setState(() => _error = e.toString());
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  void _apply(CatalogFilter filter) {
    _filter = filter;
    _request++; // invalida peticiones en curso
    _loading = false;
    _reload();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _apply(_filter.copyWith(q: text)));
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<CatalogFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => _FiltersSheet(filter: _filter, repo: _repo),
    );
    if (result != null) _apply(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final standalone = widget.title != null;

    final header = ContentWidth(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, standalone ? 0 : 20, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!standalone) ...[
              Text('Catálogo', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _search,
              autofocus: standalone && widget.title == 'Buscar',
              onChanged: _onSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por título o autor',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          _apply(_filter.copyWith(q: ''));
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Badge(
                  isLabelVisible: _filter.activeCount > 0,
                  label: Text('${_filter.activeCount}'),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                    onPressed: _openFilters,
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Filtros'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PopupMenuButton<String>(
                    tooltip: 'Ordenar',
                    initialValue: _filter.sort,
                    onSelected: (sort) => _apply(_filter.copyWith(sort: sort)),
                    itemBuilder: (_) => [
                      for (final e in _sortOptions.entries) PopupMenuItem(value: e.key, child: Text(e.value)),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.sort, size: 18),
                          const SizedBox(width: 6),
                          Flexible(child: Text(_sortOptions[_filter.sort]!, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_items.isNotEmpty || !_loading)
              Text('$_total resultados', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );

    Widget body;
    if (_error != null && _items.isEmpty) {
      body = EmptyState(
          icon: Icons.cloud_off,
          title: 'No se pudo cargar el catálogo',
          message: _error,
          action: 'Reintentar',
          onAction: _reload);
    } else if (_items.isEmpty && _loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_items.isEmpty) {
      body = EmptyState(
        icon: Icons.search_off,
        title: 'Sin resultados',
        message: 'Prueba con otra búsqueda o quita algún filtro.',
        action: _filter.activeCount > 0 ? 'Quitar filtros' : null,
        onAction: () => _apply(CatalogFilter(q: _filter.q, sort: _filter.sort)),
      );
    } else {
      body = LayoutBuilder(builder: (context, constraints) {
        final total = constraints.maxWidth;
        final side = total > 1100 ? (total - 1100) / 2 + 20 : 20.0;
        final columns = ((total - side * 2) / 190).floor().clamp(2, 6);
        return RefreshIndicator(
          onRefresh: _reload,
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(side, 8, side, 16),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (_, i) => MangaCard(manga: _items[i]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: _loading
                        ? const CircularProgressIndicator()
                        : _last
                            ? Text('Has llegado al final', style: TextStyle(color: theme.colorScheme.outline))
                            : TextButton(onPressed: _loadMore, child: const Text('Cargar más')),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      appBar: standalone ? AppBar(title: Text(widget.title!)) : null,
      body: SafeArea(child: Column(children: [header, Expanded(child: body)])),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.filter, required this.repo});
  final CatalogFilter filter;
  final CatalogRepository repo;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String? _category = widget.filter.category;
  late String? _publisher = widget.filter.publisher;
  late double _maxPrice = widget.filter.maxPrice ?? 15;
  late bool _priceEnabled = widget.filter.maxPrice != null;
  late bool _inStock = widget.filter.inStock;
  List<Category> _categories = [];
  List<String> _publishers = [];

  @override
  void initState() {
    super.initState();
    widget.repo.categories().then((c) => mounted ? setState(() => _categories = c) : null).ignore();
    widget.repo.publishers().then((p) => mounted ? setState(() => _publishers = p) : null).ignore();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Text('Categoría', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in _categories)
                FilterChip(
                  label: Text(c.name),
                  selected: _category == c.name,
                  onSelected: (s) => setState(() => _category = s ? c.name : null),
                ),
            ]),
            const SizedBox(height: 20),
            Text('Editorial', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final p in _publishers)
                FilterChip(
                  label: Text(p),
                  selected: _publisher == p,
                  onSelected: (s) => setState(() => _publisher = s ? p : null),
                ),
            ]),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Precio máximo: ${formatPrice(_maxPrice)}'),
              value: _priceEnabled,
              onChanged: (v) => setState(() => _priceEnabled = v),
            ),
            Slider(
              value: _maxPrice,
              min: 5,
              max: 15,
              divisions: 20,
              label: formatPrice(_maxPrice),
              onChanged: _priceEnabled ? (v) => setState(() => _maxPrice = v) : null,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Solo con stock'),
              value: _inStock,
              onChanged: (v) => setState(() => _inStock = v),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, CatalogFilter(q: widget.filter.q, sort: widget.filter.sort)),
                  child: const Text('Quitar filtros'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    widget.filter.copyWith(
                      category: () => _category,
                      publisher: () => _publisher,
                      maxPrice: () => _priceEnabled ? _maxPrice : null,
                      inStock: _inStock,
                    ),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
