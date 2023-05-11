import 'dart:io';

import 'package:animangav4frontend/blocs/register/bloc/register_bloc.dart';
import 'package:animangav4frontend/blocs/register/bloc/register_dto.dart';
import 'package:animangav4frontend/config/locator.dart';
import 'package:animangav4frontend/models/errors.dart';
import 'package:animangav4frontend/pages/login_page.dart';
import 'package:animangav4frontend/services/authentication_service.dart';
import 'package:animangav4frontend/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController verifyPasswordController = TextEditingController();

  late AuthenticationService authenticationService;
  bool _obscureText = true;
  Icon iconpass = const Icon(Icons.remove_red_eye_outlined);
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    authenticationService = getIt<JwtAuthenticationService>();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            content: const Text(
              '¿Deseas salir de la aplicación?',
              style: TextStyle(
                color: AnimangaStyle.whiteColor,
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'No',
                      style: TextStyle(
                        color: Color.fromARGB(255, 127, 1, 143),
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () => exit(0),
                      child: const Text(
                        'Si',
                        style: TextStyle(
                          color: Color.fromARGB(255, 127, 1, 143),
                        ),
                      )),
                ],
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) {
          return RegisterBloc(authenticationService);
        },
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              body: RefreshIndicator(
                  onRefresh: () async {},
                  child: SingleChildScrollView(child: _createBody(context)))),
        ));
  }

  Widget _createBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70.0),
      child: Column(children: [
        BlocConsumer<RegisterBloc, RegisterState>(listenWhen: (context, state) {
          return state is RegisterSuccess || state is RegisterFailure;
        }, listener: (context, state) {
          if (state is RegisterSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else if (state is RegisterFailure) {
            _showSnackbar(context, state.error);
          }
        }, buildWhen: (context, state) {
          return state is RegisterInitial || state is RegisterLoading;
        }, builder: (ctx, state) {
          if (state is RegisterInitial) {
            return buildF(ctx);
          } else if (state is RegisterLoading) {
            return buildF(ctx);
          } else {
            return buildF(ctx);
          }
        }),
      ]),
    );
  }

  void _showSnackbar(BuildContext context, ErrorResponse error) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 4),
      content: SizedBox(
        height: 150,
        child: Column(
          children: [
            Text(error.mensaje),
            for (SubErrores e in error.subErrores) Text(e.mensaje)
          ],
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
      if (_obscureText) {
        iconpass = const Icon(Icons.remove_red_eye_outlined);
      } else {
        iconpass = const Icon(Icons.remove_red_eye);
      }
    });
  }

  Widget buildF(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 5),
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    style: AnimangaStyle.textCustom(
                        Color.fromARGB(255, 140, 14, 154),
                        AnimangaStyle.textSizeTwo),
                    controller: usernameController,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AnimangaStyle.greyBoxColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      hintStyle: AnimangaStyle.textCustom(
                          AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                      hintText: 'Nombre de usuario',
                    ),
                    onSaved: (String? value) {},
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Escribe un nombre de usuario'
                          : null;
                    },
                  ),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    style: AnimangaStyle.textCustom(
                        Color.fromARGB(255, 140, 14, 154),
                        AnimangaStyle.textSizeTwo),
                    controller: nameController,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AnimangaStyle.greyBoxColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      hintStyle: AnimangaStyle.textCustom(
                          AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                      hintText: 'Nombre',
                    ),
                    onSaved: (String? value) {},
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Escribe tu nombre'
                          : null;
                    },
                  ),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    style: AnimangaStyle.textCustom(
                        Color.fromARGB(255, 140, 14, 154),
                        AnimangaStyle.textSizeTwo),
                    controller: emailController,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AnimangaStyle.greyBoxColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      hintStyle: AnimangaStyle.textCustom(
                          AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                      hintText: 'correo electrónico',
                    ),
                    onSaved: (String? value) {},
                    validator: (String? value) {
                      return (value == null || !value.contains('@'))
                          ? 'El correo debe contener una @'
                          : null;
                    },
                  ),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    style: AnimangaStyle.textCustom(
                        Color.fromARGB(255, 140, 14, 154),
                        AnimangaStyle.textSizeTwo),
                    controller: passwordController,
                    obscureText: _obscureText,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AnimangaStyle.greyBoxColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            _toggle();
                          },
                          child: iconpass),
                      suffixIconColor: Colors.white,
                      hintStyle: AnimangaStyle.textCustom(
                          AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                      hintText: 'Contraseña',
                    ),
                    onSaved: (String? value) {},
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Escribe una contraseña'
                          : null;
                    },
                  ),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    style: AnimangaStyle.textCustom(
                        Color.fromARGB(255, 140, 14, 154),
                        AnimangaStyle.textSizeTwo),
                    controller: verifyPasswordController,
                    obscureText: _obscureText,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AnimangaStyle.greyBoxColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            _toggle();
                          },
                          child: iconpass),
                      suffixIconColor: Colors.white,
                      hintStyle: AnimangaStyle.textCustom(
                          AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                      hintText: 'Confirmar contraseña',
                    ),
                    onSaved: (String? value) {},
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Escribe tu contraseña nuevamente'
                          : null;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: 300,
                  height: 80,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: AnimangaStyle.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 15.0,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final registerDto = RegisterDto(
                            username: usernameController.text,
                            fullName: nameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                            verifyPassword: verifyPasswordController.text,
                          );
                          BlocProvider.of<RegisterBloc>(context).add(
                              RegisterWithUsernameButtonPressed(registerDto));
                        }
                      },
                      child: Text(
                        'Registrarse',
                        style: AnimangaStyle.textCustom(
                            AnimangaStyle.whiteColor,
                            AnimangaStyle.textSizeThree),
                        textAlign: TextAlign.center,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    child: Text(
                      '¿Tienes una cuenta? Inicia sesión',
                      style: AnimangaStyle.textCustom(
                          Color.fromARGB(255, 140, 14, 154),
                          AnimangaStyle.textSizeThree),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
