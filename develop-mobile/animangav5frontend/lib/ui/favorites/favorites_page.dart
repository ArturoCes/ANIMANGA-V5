import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state/favorites_cubit.dart';
import '../catalog/manga_card.dart';
import '../widgets/common.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.loading && state.mangas.isEmpty) return const Center(child: CircularProgressIndicator());
          if (state.error != null && state.mangas.isEmpty) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'No se pudieron cargar tus favoritos',
              message: state.error,
              action: 'Reintentar',
              onAction: context.read<FavoritesCubit>().load,
            );
          }
          if (state.mangas.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'Aún no tienes favoritos',
              message: 'Pulsa el corazón de un manga para guardarlo aquí.',
            );
          }
          return RefreshIndicator(
            onRefresh: context.read<FavoritesCubit>().load,
            child: ContentWidth(
              child: LayoutBuilder(builder: (context, constraints) {
                final columns = (constraints.maxWidth / 190).floor().clamp(2, 6);
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.52,
                  ),
                  itemCount: state.mangas.length,
                  itemBuilder: (_, i) => MangaCard(manga: state.mangas[i]),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
