// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:animangav4frontend/repositories/AuthenticationRepository.dart'
    as _i4;
import 'package:animangav4frontend/repositories/mangasRepository.dart' as _i5;
import 'package:animangav4frontend/repositories/user_repository.dart' as _i8;
import 'package:animangav4frontend/rest/rest_client.dart' as _i3;
import 'package:animangav4frontend/services/authentication_service.dart' as _i6;
import 'package:animangav4frontend/services/mangas_service.dart' as _i7;
import 'package:animangav4frontend/services/user_service.dart' as _i9;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart'
    as _i2; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
extension GetItInjectableX on _i1.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i3.RestClient>(_i3.RestClient());
    gh.singleton<_i4.AuthenticationRepository>(_i4.AuthenticationRepository());
    gh.singleton<_i5.MangasRepository>(_i5.MangasRepository());
    gh.singleton<_i6.JwtAuthenticationService>(_i6.JwtAuthenticationService());
    gh.singleton<_i7.MangaService>(_i7.MangaService());
    gh.singleton<_i8.UserRepository>(_i8.UserRepository());
    gh.singleton<_i9.UserService>(_i9.UserService());
    return this;
  }
}
