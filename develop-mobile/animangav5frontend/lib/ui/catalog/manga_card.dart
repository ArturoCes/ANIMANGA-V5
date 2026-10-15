import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/favorites_cubit.dart';
import '../widgets/common.dart';
import 'manga_detail_page.dart';

class MangaCard extends StatelessWidget {
  const MangaCard({super.key, required this.manga});
  final Manga manga;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favorite = context.select((FavoritesCubit c) => c.state.contains(manga.id));
    final price = manga.minPrice;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => openMangaDetail(context, manga.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Hero(tag: 'cover-${manga.id}', child: CoverImage(manga.posterPath, radius: 14)),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: favorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(favorite ? Icons.favorite : Icons.favorite_border,
                          color: favorite ? Colors.pink : theme.colorScheme.outline),
                      onPressed: () => context.read<FavoritesCubit>().toggle(manga).catchError(
                            (Object e) => showMessage(context, e.toString(), error: true),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(manga.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(manga.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 4),
          Text(
            price == null ? 'Próximamente' : 'Desde ${formatPrice(price)}',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
