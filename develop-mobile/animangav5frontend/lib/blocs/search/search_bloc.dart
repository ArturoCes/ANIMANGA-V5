import 'package:animangav4frontend/models/SearchDto.dart';
import 'package:animangav4frontend/models/manga.dart';
import 'package:animangav4frontend/services/mangas_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MangaService mangaService;
  
  SearchBloc(this.mangaService) : super(SearchInitial()) {
    on<DoSearchEvent>(_doSearchEvent);
  }

  void _doSearchEvent(DoSearchEvent event, Emitter<SearchState> emit) async {
    try {
      final search = await mangaService.findMangaByName(event.searchDto);
      emit(SearchSuccessState(search.content));
      return;
    } on Exception catch (e) {
      emit(SearchErrorState(e.toString()));
    }
  }
}