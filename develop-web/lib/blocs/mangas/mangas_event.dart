part of 'mangas_bloc.dart';

abstract class MangasEvent extends Equatable {
  const MangasEvent();

  @override
  List<Object> get props => [];
}

class FindAllMangas extends MangasEvent {
  final int startIndex;
  const FindAllMangas(this.startIndex);

  @override
  List<Object> get props => [startIndex];
}