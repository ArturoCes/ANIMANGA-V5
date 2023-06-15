part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class DoSearchEvent extends SearchEvent {
  final SearchDto searchDto;

  const DoSearchEvent(this.searchDto);
}