part of 'manga_favorite_bloc.dart';

abstract class MangaFavoriteEvent extends Equatable {
  const MangaFavoriteEvent();

  @override
  List<Object> get props => [];
}
class AddMangaFavorite extends MangaFavoriteEvent{
  const AddMangaFavorite();

  @override
  List<Object> get props => [];
}

class RemoveMangaFavorite extends MangaFavoriteEvent{
  const RemoveMangaFavorite();

  @override
  List<Object> get props => [];
}