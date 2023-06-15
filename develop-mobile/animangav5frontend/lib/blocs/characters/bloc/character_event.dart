part of 'character_bloc.dart';



abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

class FetchCharacters extends CharacterEvent {

  final String id;

  const FetchCharacters(this.id);

  @override
  List<Object> get props => [id];
}
