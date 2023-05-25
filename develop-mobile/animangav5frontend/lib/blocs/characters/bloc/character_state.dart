part of 'character_bloc.dart';

abstract class CharacterState extends Equatable{
  const CharacterState();

   @override
  List<Object> get props => [];
}

class CharacterInitial extends CharacterState {}

class CharactersFetched extends CharacterState {
  final CharacterResponse characters;

  CharactersFetched({required this.characters});
}

class CharactersIsLoadinng extends CharacterState{}

class CharacterFetchError extends CharacterState {
  final ErrorResponse error;

  const CharacterFetchError(this.error);

  @override
  List<Object> get props => [error];
}
