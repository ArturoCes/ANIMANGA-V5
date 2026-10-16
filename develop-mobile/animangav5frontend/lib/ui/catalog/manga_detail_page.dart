import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/auth_cubit.dart';
import '../../state/cart_cubit.dart';
import '../../state/favorites_cubit.dart';
import '../widgets/common.dart';

void openMangaDetail(BuildContext context, String mangaId) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MangaDetailPage(mangaId: mangaId)));

class MangaDetailPage extends StatefulWidget {
  const MangaDetailPage({super.key, required this.mangaId});
  final String mangaId;

  @override
  State<MangaDetailPage> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends State<MangaDetailPage> {
  MangaDetail? _manga;
  String? _error;
  final List<Review> _reviews = [];
  bool _moreReviews = false;
  int _reviewPage = 0;

  CatalogRepository get _repo => context.read<CatalogRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final manga = await _repo.manga(widget.mangaId);
      final reviews = await _repo.reviews(widget.mangaId);
      if (!mounted) return;
      setState(() {
        _manga = manga;
        _error = null;
        _reviews
          ..clear()
          ..addAll(reviews.content);
        _moreReviews = !reviews.last;
        _reviewPage = 0;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _loadMoreReviews() async {
    final page = await _repo.reviews(widget.mangaId, page: _reviewPage + 1);
    if (!mounted) return;
    setState(() {
      _reviewPage++;
      _reviews.addAll(page.content);
      _moreReviews = !page.last;
    });
  }

  Future<void> _writeReview() => requireLogin(context, () async {
        final saved = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          constraints: const BoxConstraints(maxWidth: 560),
          builder: (_) => _ReviewSheet(manga: _manga!, repo: _repo),
        );
        if (saved == true) {
          await _load();
          if (mounted) showMessage(context, '¡Gracias por tu valoración!');
        }
      });

  @override
  Widget build(BuildContext context) {
    if (_error != null && _manga == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
            icon: Icons.cloud_off,
            title: 'No se pudo cargar el manga',
            message: _error,
            action: 'Reintentar',
            onAction: _load),
      );
    }
    final manga = _manga;
    if (manga == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 10))
              ],
            ),
            child: CoverImage(manga.coverImage, width: wide ? 240 : 180, height: wide ? 360 : 270, radius: 16),
          ),
        ),
        SizedBox(width: wide ? 32 : 0, height: wide ? 0 : 24),
        Flexible(
          fit: wide ? FlexFit.tight : FlexFit.loose,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(manga.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                [
                  manga.author,
                  if (manga.publisher.isNotEmpty) manga.publisher,
                  if (manga.releaseDate != null) DateFormat.y('es_ES').format(manga.releaseDate!),
                ].join(' · '),
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _writeReview,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    RatingStars(manga.ratingAverage, size: 20),
                    const SizedBox(width: 8),
                    Text(manga.ratingCount == 0
                        ? 'Sin valoraciones'
                        : '${manga.ratingAverage.toStringAsFixed(1)} · ${manga.ratingCount} reseñas'),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final c in manga.categories) Chip(label: Text(c), visualDensity: VisualDensity.compact),
              ]),
              const SizedBox(height: 16),
              Text(manga.synopsis, style: theme.textTheme.bodyLarge?.copyWith(height: 1.55)),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text(manga.title),
              actions: [
                IconButton(
                  tooltip: favorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
                  icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? Colors.pink : null),
                  onPressed: () => requireLogin(context, () async {
                    try {
                      await context.read<FavoritesCubit>().toggle(manga);
                    } catch (e) {
                      if (context.mounted) showMessage(context, e.toString(), error: true);
                    }
                  }),
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
                      _Title('Volúmenes'),
                      if (manga.volumes.isEmpty)
                        const Text('Todavía no hay volúmenes a la venta.')
                      else
                        for (final v in manga.volumes) _VolumeTile(volume: v),
                      if (manga.characters.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _Title('Personajes'),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: manga.characters.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (_, i) => _CharacterCard(character: manga.characters[i]),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      Row(children: [
                        const Expanded(child: _Title('Reseñas')),
                        TextButton.icon(
                          onPressed: _writeReview,
                          icon: const Icon(Icons.rate_review_outlined),
                          label: Text(manga.myRating == null ? 'Escribir reseña' : 'Editar mi reseña'),
                        ),
                      ]),
                      if (_reviews.isEmpty)
                        Text('Nadie ha valorado este manga todavía. ¡Sé el primero!',
                            style: TextStyle(color: theme.colorScheme.outline))
                      else
                        for (final r in _reviews) _ReviewTile(review: r),
                      if (_moreReviews)
                        Center(child: TextButton(onPressed: _loadMoreReviews, child: const Text('Ver más reseñas'))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      );
}

class _VolumeTile extends StatelessWidget {
  const _VolumeTile({required this.volume});
  final Volume volume;

  Future<void> _add(BuildContext context) => requireLogin(context, () async {
        try {
          await context.read<CartCubit>().add(volume);
          if (context.mounted) showMessage(context, '${volume.title} añadido al carrito');
        } catch (e) {
          if (context.mounted) showMessage(context, e.toString(), error: true);
        }
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartCubit>().state;
    final loggedIn = context.select((AuthCubit c) => c.state.isLoggedIn);
    final inCart = cart.cart.quantityOf(volume.id);
    final busy = cart.busyVolume == volume.id;
    final canAdd = !volume.soldOut && (!loggedIn || inCart < volume.stock);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CoverImage(volume.coverImage, width: 56, height: 80, radius: 8),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(volume.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(formatPrice(volume.price),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(children: [
                    StockBadge(volume.stock),
                    if (inCart > 0) ...[
                      const SizedBox(width: 8),
                      Flexible(child: Text('$inCart en el carrito', style: theme.textTheme.bodySmall)),
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
                    label: Text(volume.soldOut ? 'Agotado' : 'Añadir'),
                  ),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character});
  final MangaCharacter character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 130,
      child: Column(
        children: [
          ClipOval(child: CoverImage(character.image, width: 96, height: 96, radius: 48)),
          const SizedBox(height: 8),
          Text(character.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(character.description ?? '',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(avatar: review.authorAvatar, name: review.authorName, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(review.authorName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    RatingStars(review.rating.toDouble(), size: 15),
                    if (review.verifiedPurchase)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.verified, size: 14, color: AppColors.success),
                        const SizedBox(width: 2),
                        Text('Compra verificada',
                            style: theme.textTheme.labelSmall?.copyWith(color: AppColors.success)),
                      ]),
                  ],
                ),
                Text(DateFormat.yMMMd('es_ES').format(review.createdAt.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                if (review.comment != null) ...[
                  const SizedBox(height: 4),
                  Text(review.comment!, style: const TextStyle(height: 1.45)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.manga, required this.repo});
  final MangaDetail manga;
  final CatalogRepository repo;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late int _rating = widget.manga.myRating ?? 0;
  final _comment = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_rating == 0) return showMessage(context, 'Elige de 1 a 5 estrellas', error: true);
    setState(() => _saving = true);
    try {
      await widget.repo.rate(widget.manga.id, _rating, _comment.text.trim().isEmpty ? null : _comment.text.trim());
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tu valoración de ${widget.manga.title}',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: '$i estrellas',
                  iconSize: 40,
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.star),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comment,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(labelText: 'Comentario (opcional)', alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Guardando…' : 'Publicar valoración')),
        ],
      ),
    );
  }
}
