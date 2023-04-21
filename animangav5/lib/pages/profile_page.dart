import 'dart:convert';

import 'package:animangav4frontend/blocs/image/image_bloc.dart';
import 'package:animangav4frontend/blocs/profile/profile_bloc.dart';
import 'package:animangav4frontend/models/user.dart';
import 'package:animangav4frontend/pages/error_page.dart';
import 'package:animangav4frontend/pages/profile_edit_page.dart';
import 'package:animangav4frontend/services/authentication_service.dart';
import 'package:animangav4frontend/services/services.dart';

import 'package:animangav4frontend/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<XFile>? _imageFileList;
  late UserServiceI userService;
  late ProfileBloc _profileBloc;
  final box = GetStorage();

  set _imageFile(XFile? value) {
    _imageFileList = value == null ? [] : <XFile>[value];
  }

  @override
  void initState() {
    userService = GetIt.instance<UserService>();
    _profileBloc = ProfileBloc(userService)..add(const FetchUserLogged());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _profileBloc),
        BlocProvider(create: (context) => ImagePickBloc(userService))
      ],
      child: Scaffold(
        backgroundColor: AnimangaStyle.whiteColor,
        body: RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: _createBody(context),
          ),
        ),
      ),
    );
  }

  Widget _createBody(BuildContext context) {
    return Column(
      children: [
        BlocProvider(
          create: (context) {
            return ImagePickBloc(userService);
          },
          child: BlocConsumer<ImagePickBloc, ImagePickState>(
              listenWhen: (context, state) {
                return state is ImageSelectedSuccessState;
              },
              listener: (context, state) {},
              buildWhen: (context, state) {
                return state is ImagePickInitial ||
                    state is ImageSelectedSuccessState;
              },
              builder: (context, state) {
                if (state is ImageSelectedSuccessState) {
                  return buildProfile(context, state);
                }
                return buildProfile(context, state);
              }),
        ),
        BlocBuilder<ProfileBloc, ProfileState>(
          bloc: _profileBloc,
          builder: (context, state) {
            if (state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserLoggedFetchError) {
              return ErrorPage(
                  message: state.message,
                  retry: () {
                    context.watch<ProfileBloc>().add(const FetchUserLogged());
                  });
            } else if (state is UserLoggedFetched) {
              return _userItem(state.userLogged);
            } else {
              return const Text('No se pudo cargar los datos');
            }
          },
        ),
      ],
    );
  }

  Widget _userItem(User userLogged) {
    box.write('idUser', userLogged.id);
    return Column(
      children: [
        Center(
          child: Center(
            child: Text(
              utf8.decode(userLogged.username.codeUnits),
              style: TextStyle(
                color: Color.fromARGB(255, 148, 3, 139),
                fontSize: AnimangaStyle.textSizeThree,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileEditPage(
                      fullName: userLogged.fullName,
                      email: userLogged.email,
                      username: userLogged.username,
                      id: userLogged.id,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.edit,
                color: Color.fromARGB(255, 148, 3, 139),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 40,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AnimangaStyle.greyBoxColor1,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Nombre:",
                  style: TextStyle(
                    color: Color.fromARGB(255, 148, 3, 139),
                    fontSize: AnimangaStyle.textSizeTwo,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  userLogged.fullName,
                  style: TextStyle(
                    color: Color.fromARGB(255, 148, 3, 139),
                    fontSize: AnimangaStyle.textSizeTwo,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 40,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AnimangaStyle.greyBoxColor1,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Nombre de usuario:",
                  style: TextStyle(
                    color: Color.fromARGB(255, 148, 3, 139),
                    fontSize: AnimangaStyle.textSizeTwo,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  utf8.decode(userLogged.username.codeUnits),
                  style: TextStyle(
                    color: Color.fromARGB(255, 148, 3, 139),
                    fontSize: AnimangaStyle.textSizeTwo,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 40,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AnimangaStyle.greyBoxColor1,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Correo electrónico:",
                  style: TextStyle(
                    color: Color.fromARGB(255, 148, 3, 139),
                    fontSize: AnimangaStyle.textSizeTwo,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(utf8.decode(userLogged.email.codeUnits),
                    style: AnimangaStyle.textCustom(
                        Color.fromARGB(255, 148, 3, 139),
                        AnimangaStyle.textSizeTwo)),
              )
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AnimangaStyle.formColor,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                    color: Color.fromARGB(255, 131, 0, 146), width: 2),
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 15.0,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/changepassword');
            },
            child: Text(
              "Cambiar contraseña",
              style: AnimangaStyle.textCustom(
                  Color.fromARGB(255, 245, 245, 245),
                  AnimangaStyle.textSizeTwo),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(8, 50, 8, 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AnimangaStyle.redColor,
              elevation: 15.0,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        backgroundColor: Color.fromARGB(207, 112, 2, 112),
                        title: const Text(
                          "Cerrar sesión",
                          style: TextStyle(
                            color: AnimangaStyle.whiteColor,
                          ),
                        ),
                        content: const Text(
                          '¿Estas seguro que quieres salir?',
                          style: TextStyle(
                            color: AnimangaStyle.whiteColor,
                          ),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  'No',
                                  style: TextStyle(
                                    color: AnimangaStyle.whiteColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => {
                                  box.erase(),
                                  Navigator.pushNamed(context, '/login'),
                                },
                                child: const Text(
                                  'Si',
                                  style: TextStyle(
                                    color: AnimangaStyle.whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ));
            },
            child: Text(
              "Cerrar sesión",
              style: AnimangaStyle.textCustom(
                  AnimangaStyle.whiteColor, AnimangaStyle.textSizeThree),
            ),
          ),
        ),
      ],
    );
  }

  Widget image(String imageUrl) {
    return Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(
                  box.read("image")!,
                  /*  headers: {
                            'Authorization':
                                'Bearer ${PreferenceUtils.getString('token')}'
                          }, */
                ))));
  }

  Widget buildProfile(BuildContext context, state) {
    return SizedBox(
      height: 180,
      child: Column(
        children: [
          Center(
            child: Text("MI PERFIL",
                style: AnimangaStyle.textCustom(
                    Color.fromARGB(255, 148, 3, 139),
                    AnimangaStyle.textSizeFive)),
          ),
          GestureDetector(
              onTap: () {
                BlocProvider.of<ImagePickBloc>(context)
                    .add(const SelectImageEvent(ImageSource.gallery));
              },
              child: image(box.read('image'))),
        ],
      ),
    );
  }
}
