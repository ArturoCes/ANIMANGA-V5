import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models.dart';
import '../data/repositories.dart';

class FavoritesState {
  const FavoritesState({this.mangas = const [], this.loading = false, this.error});

  final List<MangaSummary> mangas;
  final bool loading;
  final String? error;

  bool contains(String mangaId) => mangas.any((m) => m.id == mangaId);
}

/// Favoritos compartidos por portada, catálogo, ficha y pestaña de favoritos.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repo) : super(const FavoritesState());

  final CatalogRepository _repo;

  Future<void> load() async {
    emit(FavoritesState(mangas: state.mangas, loading: true));
    try {
      emit(FavoritesState(mangas: await _repo.favorites()));
    } catch (e) {
      emit(FavoritesState(mangas: state.mangas, error: e.toString()));
    }
  }

  void clear() => emit(const FavoritesState());

  Future<void> toggle(MangaSummary manga) async {
    final wasFavorite = state.contains(manga.id);
    // Actualización optimista: la interfaz responde al momento
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
