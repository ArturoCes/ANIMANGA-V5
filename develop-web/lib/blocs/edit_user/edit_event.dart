part of 'edit_bloc.dart';

abstract class EditUserEvent extends Equatable {
  const EditUserEvent();

  @override
  List<Object> get props => [];
}

class EditOneUserEvent extends EditUserEvent {
  final EditUserDto editUserDto;
  final String id;

  const EditOneUserEvent(this.editUserDto, this.id);

  @override
  List<Object> get props => [editUserDto, id];
}
