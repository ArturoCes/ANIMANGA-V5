import 'package:animangav4frontend/blocs/register/bloc/register_dto.dart';
import 'package:animangav4frontend/models/errors.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_storage/get_storage.dart';

import '../../../services/authentication_service.dart';


part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthenticationService _authenticationService;
  final box = GetStorage();
  RegisterBloc(
      AuthenticationService authenticationService)
     : assert(authenticationService != null),
        _authenticationService = authenticationService,
        super(RegisterInitial()) {
    on<RegisterWithUsernameButtonPressed>(__onRegisterButtonPressed);
  }

  __onRegisterButtonPressed(
    RegisterWithUsernameButtonPressed event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      //print('ButtonPressed: ' + event.username);
      final user = await _authenticationService
      .register(event.registerDto);
      if (user != null) {
        emit(RegisterSuccess());
      }
    } on ErrorResponse catch (e) {
      emit(RegisterFailure(error: e));
    }
  }
}
