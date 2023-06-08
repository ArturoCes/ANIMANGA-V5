part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoadingState extends SearchState {}

class SearchSuccessState extends SearchState {
  final List<Manga> mangas;

  const SearchSuccessState(this.mangas);

  @override
  List<Object> get props => [mangas];
}

class SearchErrorState extends SearchState {
  final String message;

  const SearchErrorState(this.message);

  @override
  List<Object> get props => [message];
}