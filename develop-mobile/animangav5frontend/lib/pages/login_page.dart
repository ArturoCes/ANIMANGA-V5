import 'dart:io';
import 'package:animangav4frontend/blocs/blocs.dart';
import 'package:animangav4frontend/models/errors.dart';
import 'package:animangav4frontend/models/login_error.dart';
import 'package:animangav4frontend/pages/navigation_bard.dart';
import 'package:animangav4frontend/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/login/login_dto.dart';
import '../config/locator.dart';
import '../utils/styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late AuthenticationService authenticationService;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  Icon iconpass = const Icon(Icons.remove_red_eye_outlined);

  @override
  void initState() {
    authenticationService = getIt<JwtAuthenticationService>();
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            content: const Text(
              '¿Deseas salir de la aplicación?',
              style: TextStyle(
                color: Color.fromARGB(255, 189, 72, 224),
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
                      style:
                          TextStyle(color: Color.fromARGB(255, 211, 26, 211)),
                    ),
                  ),
                  TextButton(
                      onPressed: () => exit(0),
                      child: const Text(
                        'Si',
                        style: TextStyle(
                          color: Color.fromARGB(255, 170, 2, 170),
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
          return LoginBloc(authenticationService);
        },
        child: _createBody(context));
  }

  Widget _createBody(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: Center(
          child: Container(
              padding: const EdgeInsets.all(20),
              child: BlocConsumer<LoginBloc, LoginState>(
                  listenWhen: (context, state) {
                return state is LoginSuccess || state is LoginFailure;
              }, listener: (context, state) {
                if (state is LoginSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const BottomNavBar()),
                  );
                } else if (state is LoginFailure) {
                  _showSnackbar(context, state.error);
                }
              }, buildWhen: (context, state) {
                return state is LoginInitial || state is LoginLoading;
              }, builder: (ctx, state) {
                if (state is LoginInitial) {
                  return buildForm(ctx);
                } else if (state is LoginLoading) {
                  return buildForm(ctx);
                } else {
                  return buildForm(ctx);
                }
              })),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, LoginError loginError) {
    final snackBar = SnackBar(
      content: Text(loginError.message),
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

  Widget buildForm(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: const EdgeInsets.only(top: 140),
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
                  margin: const EdgeInsets.only(top: 70),
                  child: TextFormField(
                    style: AnimangaStyle.textCustom(
                        Color.fromARGB(255, 168, 16, 238),
                        AnimangaStyle.textSizeTwo),
                    controller: emailController,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AnimangaStyle.greyBoxColor,
                      border: OutlineInputBorder(
                          gapPadding: AnimangaStyle.bodyPadding),
                      hintStyle: AnimangaStyle.textCustom(
                          AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.person),
                      ),
                      hintText: 'Nombre de usuario',
                    ),
                    onSaved: (String? value) {},
                    validator: (String? value) {
                      return (value == null)
                          ? 'Introduzca su correo nombre de usuario'
                          : null;
                    },
                  ),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    style: AnimangaStyle.textCustom(
                        Color.fromARGB(255, 168, 16, 238),
                        AnimangaStyle.textSizeTwo),
                    controller: passwordController,
                    obscureText: _obscureText,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AnimangaStyle.greyBoxColor,
                      border: OutlineInputBorder(
                          gapPadding: AnimangaStyle.bodyPadding),
                      hintStyle: AnimangaStyle.textCustom(
                          AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            _toggle();
                          },
                          child: iconpass),
                      suffixIconColor: Color.fromARGB(255, 160, 37, 172),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.lock_clock_rounded),
                      ),
                      hintText: 'Contraseña',
                    ),
                    onSaved: (String? value) {},
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Escribe tu contraseña'
                          : null;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(100)),
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
                          final loginDto = LoginDto(
                              username: emailController.text,
                              password: passwordController.text);
                          BlocProvider.of<LoginBloc>(context)
                              .add(LoginInWithUsernameButtonPressed(loginDto));
                        }
                      },
                      child: Text(
                        'Iniciar Sesión',
                        style: AnimangaStyle.textCustom(
                            Color.fromARGB(255, 255, 253, 253),
                            AnimangaStyle.textSizeThree),
                        textAlign: TextAlign.center,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    child: Text(
                      'Registrarse',
                      style: AnimangaStyle.textCustom(
                          Color.fromARGB(255, 134, 12, 123),
                          AnimangaStyle.textSizeThree),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
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
