import 'dart:io';
import 'package:animangav4frontend/blocs/blocs.dart';
import 'package:animangav4frontend/blocs/cart/cart_bloc.dart';
import 'package:animangav4frontend/models/errors.dart';
import 'package:animangav4frontend/models/login_error.dart';
import 'package:animangav4frontend/models/purchaseDto.dart';
import 'package:animangav4frontend/models/purchaseResponse.dart';
import 'package:animangav4frontend/pages/navigation_bard.dart';
import 'package:animangav4frontend/services/authentication_service.dart';
import 'package:animangav4frontend/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';
import '../blocs/login/login_dto.dart';
import '../config/locator.dart';
import '../utils/styles.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({Key? key}) : super(key: key);

  @override
  _PurchasePageState createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController cardController = TextEditingController();
  TextEditingController dateCardController = TextEditingController();
  TextEditingController cvvCardController = TextEditingController();
  late UserService userService;
  final box = GetStorage();

  @override
  void initState() {
    userService = GetIt.instance<UserService>();
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
          return CartBloc(userService);
        },
        child: _createBody(context));
  }

  Widget _createBody(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: Center(
          child: Container(
              padding: const EdgeInsets.all(20),
              child: BlocConsumer<CartBloc, CartState>(
                  listenWhen: (context, state) {
                return state is Purchased || state is PurchasedError;
              }, listener: (context, state) {
                if (state is Purchased) {
                 Navigator.pushReplacementNamed(context,"/");     
                } else if (state is PurchasedError) {
                  _showSnackbar(context, state.error);
                }
              }, buildWhen: (context, state) {
                return state is CartInitial || state is CartIsLoading;
              }, builder: (ctx, state) {
                if (state is CartInitial) {
                  return buildForm(ctx);
                } else if (state is CartIsLoading) {
                  return buildForm(ctx);
                } else {
                  return buildForm(ctx);
                }
              })),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, ErrorResponse response) {
    final snackBar = SnackBar(
      content: Text(response.mensaje),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
              // Campo del nombre en la tarjeta
              Container(
                height: 50,
                margin: const EdgeInsets.only(top: 70),
                child: TextFormField(
                  style: AnimangaStyle.textCustom(
                      Color.fromARGB(255, 168, 16, 238),
                      AnimangaStyle.textSizeTwo),
                  controller: nameController,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AnimangaStyle.greyBoxColor,
                    border: OutlineInputBorder(
                        gapPadding: AnimangaStyle.bodyPadding),
                    hintStyle: AnimangaStyle.textCustom(
                        AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                    suffixIconColor: Color.fromARGB(255, 160, 37, 172),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(Icons.person),
                    ),
                    hintText: 'Nombre del titular',
                  ),
                  onSaved: (String? value) {},
                  validator: (value) {
                    return (value == null || value.isEmpty)
                        ? 'Escribe el nombre del titular'
                        : null;
                  },
                ),
              ),
              // Campo del número de tarjeta
              Container(
                height: 50,
                margin: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  style: AnimangaStyle.textCustom(
                      Color.fromARGB(255, 168, 16, 238),
                      AnimangaStyle.textSizeTwo),
                  controller: cardController,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AnimangaStyle.greyBoxColor,
                    border: OutlineInputBorder(
                        gapPadding: AnimangaStyle.bodyPadding),
                    hintStyle: AnimangaStyle.textCustom(
                        AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                    suffixIconColor: Color.fromARGB(255, 160, 37, 172),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(Icons.credit_card),
                    ),
                    hintText: 'Número de tarjeta',
                  ),
                  onSaved: (String? value) {},
                  validator: (value) {
                    return (value == null || value.isEmpty)
                        ? 'Escribe el número de tarjeta'
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
                    controller: dateCardController,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AnimangaStyle.greyBoxColor,
                      border: OutlineInputBorder(
                          gapPadding: AnimangaStyle.bodyPadding),
                      hintStyle: AnimangaStyle.textCustom(
                          AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                      suffixIconColor: Color.fromARGB(255, 160, 37, 172),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.date_range),
                      ),
                      hintText: 'Fecha de caducidad (MM/AA)',
                    ),
                    onTap: () async {
                      final selectedDate = await showMonthPicker(
                        context: context,
                        firstDate: DateTime(DateTime.now().year - 5, 1),
                        lastDate: DateTime(DateTime.now().year + 5, 12),
                        initialDate: DateTime.now(),
                        locale: Locale("es"),
                      );

                      if (selectedDate != null) {
                        dateCardController.text = DateFormat('MM/yy').format(selectedDate);
                        // Cerrar el teclado virtual
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    },
                    onSaved: (String? value) {},
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Escribe la fecha de caducidad'
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
                    controller: cvvCardController,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AnimangaStyle.greyBoxColor,
                      border: OutlineInputBorder(
                          gapPadding: AnimangaStyle.bodyPadding),
                      hintStyle: AnimangaStyle.textCustom(
                          AnimangaStyle.formColor, AnimangaStyle.textSizeTwo),
                      suffixIconColor: Color.fromARGB(255, 160, 37, 172),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.security),
                      ),
                      hintText: 'Código CVV',
                    ),
                    onSaved: (String? value) {},
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Escribe el código CVV'
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
                          final purchaseDto = PurchaseDto(
                            idCart: box.read("idCart"),
                           numCreditCard: cardController.text
                              );
                          BlocProvider.of<CartBloc>(context)
                              .add(PurchaseEvent(purchaseDto));
                        }
                      },
                      child: Text(
                        'Pagar',
                        style: AnimangaStyle.textCustom(
                            Color.fromARGB(255, 255, 253, 253),
                            AnimangaStyle.textSizeThree),
                        textAlign: TextAlign.center,
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
