part of 'manga_favorite_bloc.dart';

abstract class MangaFavoriteState extends Equatable {
  const MangaFavoriteState();
  
  @override
  List<Object> get props => [];
}

class MangaFavoriteInitial extends MangaFavoriteState {}


class MangaFavorite extends MangaFavoriteState {
  final Manga manga;

  const MangaFavorite(this.manga);

  @override
  List<Object> get props => [manga];
}

class MangaFavoriteError extends MangaFavoriteState {
  final String message;
  const MangaFavoriteError(this.message);

  @override
  List<Object> get props => [message];
}

class MangaRemoveFavorite extends MangaFavoriteState {
  final Manga manga;

  const MangaRemoveFavorite(this.manga);

  @override
  List<Object> get props => [manga];
}