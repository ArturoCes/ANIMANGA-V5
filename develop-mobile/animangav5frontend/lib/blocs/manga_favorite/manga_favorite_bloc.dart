import 'package:animangav4frontend/models/manga.dart';
import 'package:animangav4frontend/services/services.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_storage/get_storage.dart';

part 'manga_favorite_event.dart';
part 'manga_favorite_state.dart';

class MangaFavoriteBloc extends Bloc<MangaFavoriteEvent, MangaFavoriteState> {
  final MangasService _mangasService;
  final box = GetStorage();

  MangaFavoriteBloc(this._mangasService) : super(MangaFavoriteInitial()){
    on<AddMangaFavorite>(_AddMangaFavorite);
    on<RemoveMangaFavorite>(_removeMangaFavorite);
    
    }
    void _AddMangaFavorite(AddMangaFavorite event, Emitter<MangaFavoriteState>emit)async {
      try{
        final manga = await _mangasService.addMangaFavorite(box.read('idManga'));
        emit(MangaFavorite(manga));
        return;
      }on Exception catch(e){
        emit(MangaFavoriteError(e.toString()));
      }
    }
    void _removeMangaFavorite(RemoveMangaFavorite event, Emitter<MangaFavoriteState>emit)async{
      try{
        final manga = await _mangasService.removeMangaFavorite(box.read('idManga'));
         emit(MangaRemoveFavorite(manga));
        return;
      }on Exception catch(e){
        emit(MangaFavoriteError(e.toString()));
      }
    }
  }



