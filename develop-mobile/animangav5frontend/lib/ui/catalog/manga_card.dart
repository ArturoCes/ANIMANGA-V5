import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/favorites_cubit.dart';
import '../widgets/common.dart';
import 'manga_detail_page.dart';

class MangaCard extends StatelessWidget {
  const MangaCard({super.key, required this.manga});
  final MangaSummary manga;

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
                  child: Hero(tag: 'cover-${manga.id}', child: CoverImage(manga.coverImage, radius: 14)),
                ),
                if (!manga.inStock)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(99)),
                      child: const Text('Agotado', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: theme.colorScheme.surface.withValues(alpha: 0.9),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: favorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(favorite ? Icons.favorite : Icons.favorite_border,
                          color: favorite ? Colors.pink : theme.colorScheme.outline),
                      onPressed: () => requireLogin(context, () async {
                        try {
                          await context.read<FavoritesCubit>().toggle(manga);
                        } catch (e) {
                          if (context.mounted) showMessage(context, e.toString(), error: true);
                        }
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(manga.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text(manga.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  price == null ? 'Próximamente' : 'Desde ${formatPrice(price)}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                ),
              ),
              if (manga.ratingCount > 0) ...[
                const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
                Text(manga.ratingAverage.toStringAsFixed(1), style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
