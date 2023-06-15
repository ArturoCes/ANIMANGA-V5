import 'package:animangav4frontend/blocs/manga/bloc/manga_bloc.dart';
import 'package:animangav4frontend/models/category.dart';
import 'package:animangav4frontend/services/services.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/manga.dart';

part 'mangas_event.dart';
part 'mangas_state.dart';

class MangasBloc extends Bloc<MangasEvent, MangasState> {
  final MangasService _mangasService;
  MangasBloc(MangasService mangaService)
      : assert(mangaService != null),
        _mangasService = mangaService,
        super(MangasInitial()) {
    on<FindAllMangas>(_findAllMangas);
    on<FindAllMangasByCat>(_findAllMangasCat);
    on<FindAllMangasFavorite>(_findAllMangasFavorite);
  }

  _findAllMangas(FindAllMangas event, Emitter<MangasState> emit) async {
    try {
      final mangas = await _mangasService.findAll(event.startIndex);
      emit(FindAllMangasSuccess(mangas.content, mangas.totalElements));
      return;
    } on Exception catch (e) {
      emit(FindAllMangasError(e.toString()));
    }
  }

  _findAllMangasCat(FindAllMangasByCat event, Emitter<MangasState> emit) async {
    try {
      final mangas = await _mangasService.findAllCategoriesManga(event.name);


      emit(FindAllMangasSuccess(mangas.content, mangas.totalElements));
      return;
    } on Exception catch (e) {
      emit(FindAllMangasError(e.toString()));
    }
  }

  _findAllMangasFavorite(FindAllMangasFavorite event, Emitter<MangasState>emit)async{
    try {
      final mangas = await _mangasService.findAllFavoritesMangas(event.username);


      emit(FindAllMangasSuccess(mangas.content, mangas.totalElements));
      return;
    } on Exception catch (e) {
      emit(FindAllMangasError(e.toString()));
    }
  }
}
