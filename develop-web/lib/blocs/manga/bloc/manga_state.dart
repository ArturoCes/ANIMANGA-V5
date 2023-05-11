part of 'manga_bloc.dart';

abstract class MangaState extends Equatable {
  const MangaState();
  
  @override
  List<Object> get props => [];
}

class MangaInitial extends MangaState {}

class MangaFetched extends MangaState {
  final Manga manga;
  

  const MangaFetched(this.manga);

  @override
  List<Object> get props => [manga];
}

class MangaFetchError extends MangaState {
  final String message;
  const MangaFetchError(this.message);

  @override
  List<Object> get props => [message];
}
