import 'package:animangav4frontend/blocs/password/password_bloc.dart';
import 'package:animangav4frontend/models/errors.dart';
import 'package:animangav4frontend/models/password_dto.dart';
import 'package:animangav4frontend/pages/navigation_bard.dart';
import 'package:animangav4frontend/repositories/user_repository.dart';
import 'package:animangav4frontend/services/user_service.dart';
import 'package:animangav4frontend/utils/styles.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({Key? key}) : super(key: key);

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password2Controller = TextEditingController();
  TextEditingController password3Controller = TextEditingController();
 late UserServiceI userService;

  @override
  void initState() {
 userService = GetIt.instance<UserService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChangePasswordBloc(userService)),
      ],
      child: Scaffold(
        backgroundColor: AnimangaStyle.whiteColor,
        appBar: AppBar(
          title: Text(
            "CAMBIAR CONTRASEÑA",
            style: AnimangaStyle.textCustom(
                AnimangaStyle.whiteColor, AnimangaStyle.textSizeFive),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 84, 0, 118),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            child: _createBody(context),
          ),
        ),
      ),
    );
  }

  Widget _createBody(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
      listenWhen: (context, state) {
        return state is ChangePasswordSuccessState ||
            state is ChangePasswordErrorState;
      },
      listener: (context, state) {
        if (state is ChangePasswordSuccessState) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          );
          _createDialog(context);
        } else if (state is ChangePasswordErrorState) {
          _showSnackbar(context, state.error);
        }
      },
      buildWhen: (context, state) {
        return state is ChangePasswordInitial ||
            state is ChangePasswordSuccessState;
      },
      builder: (context, state) {
        if (state is ChangePasswordSuccessState) {
          return buildF(context);
        }
        return buildF(context);
      },
    );
  }

  AwesomeDialog _createDialog(context) {
    return AwesomeDialog(
      context: context,
      dialogBackgroundColor: Color.fromARGB(255, 244, 244, 244),
      btnOkColor: AnimangaStyle.primaryColor,
      dialogType: DialogType.SUCCES,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Correcto',
      desc: 'La contraseña se ha guardado correctamente',
      titleTextStyle:
          AnimangaStyle.textCustom(AnimangaStyle.whiteColor, AnimangaStyle.textSizeFour),
      descTextStyle: AnimangaStyle.textCustom(
          Color.fromARGB(255, 129, 0, 134), AnimangaStyle.textSizeThree),
      btnOkText: "Aceptar",
      btnOkOnPress: () {},
    )..show();
  }

  void _showSnackbar(BuildContext context, ErrorResponse error) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 4),
      content: SizedBox(
        height: 150,
        child: Column(
          children: [for (SubErrores e in error.subErrores) Text(e.mensaje)],
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildF(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 500,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: 50,
                margin: const EdgeInsets.all(10),
                child: TextFormField(
                  style: AnimangaStyle.textCustom(
                      Color.fromARGB(255, 118, 4, 136), AnimangaStyle.textSizeTwo),
                  controller: passwordController,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AnimangaStyle.greyBoxColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    hintStyle: AnimangaStyle.textCustom(
                        AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                    hintText: 'Contraseña actual:',
                  ),
                  onSaved: (String? value) {},
                  validator: (String? value) {
                    return (value == null)
                        ? 'Introduzca su contraseña actual'
                        : null;
                  },
                ),
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.all(10),
                child: TextFormField(
                  style: AnimangaStyle.textCustom(
                      Color.fromARGB(255, 135, 9, 131), AnimangaStyle.textSizeTwo),
                  controller: password2Controller,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AnimangaStyle.greyBoxColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    hintStyle: AnimangaStyle.textCustom(
                        AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                    hintText: 'Nueva contraseña:',
                  ),
                  onSaved: (String? value) {},
                  validator: (String? value) {
                    return (value == null)
                        ? 'Introduzca su nueva contraseña'
                        : null;
                  },
                ),
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.all(10),
                child: TextFormField(
                  style: AnimangaStyle.textCustom(
                      Color.fromARGB(255, 109, 0, 115), AnimangaStyle.textSizeTwo),
                  controller: password3Controller,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AnimangaStyle.greyBoxColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    hintStyle: AnimangaStyle.textCustom(
                        AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                    hintText: 'Confirmar contraseña nueva:',
                  ),
                  onSaved: (String? value) {},
                  validator: (String? value) {
                    return (value == null)
                        ? 'Repita su contraseña nueva'
                        : null;
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.fromLTRB(10, 200, 10, 8),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: AnimangaStyle.primaryColor,
                      elevation: 15.0,
                    ),
                    onPressed: () {
                      final passwordDto = PasswordDto(
                          password: passwordController.text,
                          passwordNew: password2Controller.text,
                          passwordNewVerify: password3Controller.text);
                      BlocProvider.of<ChangePasswordBloc>(context)
                          .add(ChangePassEvent(passwordDto));
                    },
                    child: Text("Guardar",
                        style: AnimangaStyle.textCustom(
                            AnimangaStyle.whiteColor, AnimangaStyle.textSizeThree))),
              )
            ],
          ),
        ),
      ),
    );
  }
}