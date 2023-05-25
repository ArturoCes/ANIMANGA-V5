import 'package:animangav4frontend/models/manga.dart';
import 'package:animangav4frontend/services/mangas_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_storage/get_storage.dart';

part 'manga_event.dart';
part 'manga_state.dart';

class MangaBloc extends Bloc<MangaEvent, MangaState> {
  final MangasService _mangasService;
  final box = GetStorage();

  MangaBloc(this._mangasService) : super(MangaInitial()) {
    on<FetchManga>(_MangaFetched);
  }

  void _MangaFetched(FetchManga event, Emitter<MangaState> emit) async {
    try {
      final manga = await _mangasService.findMangaById(box.read("idManga"));
      emit(MangaFetched(manga));
      return;
    } on Exception catch (e) {
      emit(MangaFetchError(e.toString()));
    }
  }
  
}
