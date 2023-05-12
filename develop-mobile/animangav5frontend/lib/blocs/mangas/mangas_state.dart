part of 'mangas_bloc.dart';

abstract class MangasState extends Equatable {
  const MangasState();
  
  @override
  List<Object> get props => [];
}

class MangasInitial extends MangasState {}

class FindAllMangasSuccess extends MangasState {
  final List<Manga> mangas;
  final int pagesize; 

  const FindAllMangasSuccess(this.mangas, this.pagesize);

  @override
  List<Object> get props => [mangas,pagesize];
}

class FindAllMangasError extends MangasState {
  final String message;
  const FindAllMangasError(this.message);

  @override
  List<Object> get props => [message];
}