import 'dart:ui';

import 'package:animangav4frontend/blocs/cart/cart_bloc.dart';
import 'package:animangav4frontend/models/volumen.dart';
import 'package:animangav4frontend/pages/app_bar.dart';
import 'package:animangav4frontend/rest/rest_client.dart';
import 'package:animangav4frontend/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import '../utils/styles.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late UserService userService;
  late CartBloc _cartbloc;
  final box = GetStorage();

  @override
  void initState() {
    userService = GetIt.instance<UserService>();
    _cartbloc = CartBloc(userService)..add(FetchCart(box.read("idCart")));
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 249, 249, 249),
        appBar:HomeAppBar(),
        body: RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: _createBody(context),
          ),
        ),
      );
  }

  Widget _createBody(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      bloc: _cartbloc,
      builder: (context, state) {
        if (state is CartInitial) {
          return Container();
        } else if (state is CartFetchError) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
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
                         Navigator.pushNamed(context, '/purchase');
                      },
                      child: Text(
                        'Proceder Al Pago',
                        style: AnimangaStyle.textCustom(
                            Color.fromARGB(255, 255, 253, 253),
                            AnimangaStyle.textSizeThree),
                        textAlign: TextAlign.center,
                      )),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          );
        } else if (state is ItemsToCart) {
          return Column(
            children: [
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
                         Navigator.pushNamed(context, '/purchase');
                      },
                      child: Text(
                        'Proceder Al Pago',
                        style: AnimangaStyle.textCustom(
                            Color.fromARGB(255, 255, 253, 253),
                            AnimangaStyle.textSizeThree),
                        textAlign: TextAlign.center,
                      )),
                ),
              ListView.builder(
                  itemCount: state.items.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    Volumen volume = state.items[index].volumen;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 8.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF690A8A), // Color lila
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    ApiConstants.imageBaseUrl + volume.posterPath,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    volume.nombre,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Precio: ${volume.precio} Cantidad: ${volume.cantidad} ISBN: ${volume.isbn}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          );
        } else {
          return const Text('Error al cargar la lista');
        }
      },
    );
  }
}
