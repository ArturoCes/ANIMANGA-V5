import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/cart_cubit.dart';
import '../../state/favorites_cubit.dart';
import '../widgets/common.dart';

/// Abre el detalle conservando los cubits de la sesión (las rutas nuevas no los heredan).
void openMangaDetail(BuildContext context, String mangaId) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<CartCubit>()),
        BlocProvider.value(value: context.read<FavoritesCubit>()),
      ],
      child: MangaDetailPage(mangaId: mangaId),
    ),
  ));
}

class MangaDetailPage extends StatefulWidget {
  const MangaDetailPage({super.key, required this.mangaId});
  final String mangaId;

  @override
  State<MangaDetailPage> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends State<MangaDetailPage> {
  late Future<(Manga, List<Character>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(Manga, List<Character>)> _load() async {
    final repo = context.read<CatalogRepository>();
    final results = await Future.wait([repo.manga(widget.mangaId), repo.characters(widget.mangaId)]);
    return (results[0] as Manga, results[1] as List<Character>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: EmptyState(
                icon: Icons.cloud_off,
                title: 'No se pudo cargar el manga',
                message: snapshot.error.toString(),
                action: 'Reintentar',
                onAction: () => setState(() => _future = _load()),
              ),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final (manga, characters) = snapshot.data!;
          return _DetailView(manga: manga, characters: characters);
        },
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.manga, required this.characters});
  final Manga manga;
  final List<Character> characters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favorite = context.select((FavoritesCubit c) => c.state.contains(manga.id));
    final wide = MediaQuery.sizeOf(context).width >= 760;

    final header = Flex(
      direction: wide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Hero(
          tag: 'cover-${manga.id}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10))
              ],
            ),
            child: CoverImage(manga.posterPath, width: wide ? 240 : 180, height: wide ? 360 : 270, radius: 16),
          ),
        ),
        SizedBox(width: wide ? 32 : 0, height: wide ? 0 : 24),
        Flexible(
          fit: wide ? FlexFit.tight : FlexFit.loose,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(manga.name, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                [
                  manga.author,
                  if (manga.publisher.isNotEmpty) manga.publisher,
                  if (manga.releaseDate != null) DateFormat.y('es_ES').format(manga.releaseDate!),
                ].join(' · '),
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in manga.categories) Chip(label: Text(c.name), visualDensity: VisualDensity.compact)
                ],
              ),
              const SizedBox(height: 16),
              Text(manga.description, style: theme.textTheme.bodyLarge?.copyWith(height: 1.55)),
            ],
          ),
        ),
      ],
    );

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(manga.name),
          actions: [
            IconButton(
              tooltip: favorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
              icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? Colors.pink : null),
              onPressed: () => context
                  .read<FavoritesCubit>()
                  .toggle(manga)
                  .catchError((Object e) => showMessage(context, e.toString(), error: true)),
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: ContentWidth(
            maxWidth: 1000,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 32),
                  Text('Volúmenes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (manga.volumenes.isEmpty)
                    const Text('Todavía no hay volúmenes a la venta.')
                  else
                    for (final v in manga.volumenes) _VolumeTile(volumen: v),
                  if (characters.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text('Personajes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: characters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (_, i) => _CharacterCard(character: characters[i]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VolumeTile extends StatelessWidget {
  const _VolumeTile({required this.volumen});
  final Volumen volumen;

  Future<void> _add(BuildContext context) async {
    try {
      await context.read<CartCubit>().add(volumen);
      if (context.mounted) showMessage(context, '${volumen.nombre} añadido al carrito');
    } catch (e) {
      if (context.mounted) showMessage(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartCubit>().state;
    final inCart = cart.quantityOf(volumen.id);
    final busy = cart.busyVolumen == volumen.id;
    final canAdd = !volumen.soldOut && inCart < volumen.cantidad;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CoverImage(volumen.posterPath, width: 56, height: 80, radius: 8),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(volumen.nombre, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(formatPrice(volumen.precio),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(children: [
                    StockBadge(volumen.cantidad),
                    if (inCart > 0) ...[
                      const SizedBox(width: 8),
                      Text('$inCart en el carrito', style: theme.textTheme.bodySmall),
                    ],
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            busy
                ? const SizedBox.square(
                    dimension: 40,
                    child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)))
                : FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                    onPressed: canAdd ? () => _add(context) : null,
                    icon: const Icon(Icons.add_shopping_cart, size: 20),
                    label: Text(volumen.soldOut ? 'Agotado' : 'Añadir'),
                  ),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 130,
      child: Column(
        children: [
          ClipOval(child: CoverImage(character.imageUrl, width: 96, height: 96, radius: 48)),
          const SizedBox(height: 8),
          Text(character.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(character.description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}
