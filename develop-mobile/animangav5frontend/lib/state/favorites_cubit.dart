import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models.dart';
import '../data/repositories.dart';

class FavoritesState {
  const FavoritesState({this.mangas = const [], this.loading = false, this.error});

  final List<Manga> mangas;
  final bool loading;
  final String? error;

  bool contains(String mangaId) => mangas.any((m) => m.id == mangaId);
}

/// Lista de favoritos compartida por el catálogo, el detalle y la pestaña de favoritos.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repo, this._user) : super(const FavoritesState());

  final CatalogRepository _repo;
  final User _user;

  Future<void> load() async {
    emit(FavoritesState(mangas: state.mangas, loading: true));
    try {
      emit(FavoritesState(mangas: await _repo.favorites(_user.username)));
    } catch (e) {
      emit(FavoritesState(mangas: state.mangas, error: e.toString()));
    }
  }

  Future<void> toggle(Manga manga) async {
    final wasFavorite = state.contains(manga.id);
    // Actualización optimista: la UI responde al instante
    emit(FavoritesState(
      mangas: wasFavorite ? state.mangas.where((m) => m.id != manga.id).toList() : [...state.mangas, manga],
    ));
    try {
      await _repo.setFavorite(manga.id, !wasFavorite);
    } catch (_) {
      await load();
      rethrow;
    }
  }
}
