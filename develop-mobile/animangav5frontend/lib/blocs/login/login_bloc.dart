import 'package:animangav4frontend/blocs/login/login_event.dart';
import 'package:animangav4frontend/blocs/login/login_state.dart';
import 'package:animangav4frontend/models/errors.dart';
import 'package:animangav4frontend/models/login_error.dart';
import 'package:animangav4frontend/services/authentication_service.dart';
import 'package:bloc/bloc.dart';
import 'package:get_storage/get_storage.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationService _authenticationService;
  final box = GetStorage();
  LoginBloc(AuthenticationService authenticationService)
      : assert(authenticationService != null),
        _authenticationService = authenticationService,
        super(LoginInitial()) {
    on<LoginInWithUsernameButtonPressed>(__onLogingInWithEmailButtonPressed);
  }

  __onLogingInWithEmailButtonPressed(
    LoginInWithUsernameButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await _authenticationService
          .signInWithEmailAndPassword(event.loginDto);
      if (user != null) {
        box.write('token', user.token);
        box.write('image', user.image);
        box.write('username', user.username);
        box.write('idUser', user.id);
        box.write('idCart',user.idCart);
        emit(LoginSuccess());
      }
    } on LoginError catch (err) {
      emit(LoginFailure(error: err));
    }
  }
}
