part of 'mangas_bloc.dart';

abstract class MangasEvent extends Equatable {
  const MangasEvent();

  @override
  List<Object> get props => [];
}

class FindAllMangas extends MangasEvent {
  final int startIndex;
  const FindAllMangas(this.startIndex);

  @override
  List<Object> get props => [startIndex];
}


class FindAllCategories extends MangasEvent {}

class FindAllMangasByCat extends MangasEvent {
  final String name;
  const FindAllMangasByCat(this.name);
  @override
  List<Object> get props => [name];
}
class FindAllMangasFavorite extends MangasEvent{

  final String username;
  const FindAllMangasFavorite(this.username);
  @override
  List<Object> get props => [username];
}
