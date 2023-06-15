import 'package:animangav4frontend/models/character.dart';
import 'package:animangav4frontend/models/errors.dart';
import 'package:animangav4frontend/services/mangas_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'character_event.dart';
part 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final MangasService _characterService;

  CharacterBloc(MangasService characterService)
      : assert(characterService != null),
        _characterService = characterService,
        super(CharacterInitial()) {
    on<FetchCharacters>(_showCharacters);
  }

  void _showCharacters(
      FetchCharacters event, Emitter<CharacterState> emit) async {
    try {
      var characters =
          await _characterService.findCharactersByMangaId(event.id);

      emit(CharactersFetched(characters: characters));
    } on ErrorResponse catch (e) {
      emit(CharacterFetchError(e));
    }
  }
}
